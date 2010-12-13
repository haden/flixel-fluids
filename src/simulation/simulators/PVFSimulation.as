package simulation.simulators {
	import flash.geom.Rectangle;
	import particles.FluidParticle;
	import simulation.IndexGrid;
	import simulation.IndexGridO;
	import utils.Vector2;
	import particles.FluidParticles;
	/**
	 * Particle-based Viscoelastic Fluid Simulation.
	 * Based on the paper with the same name from S. Clavet, P. Beaudoin, P. Poulin
	 * 
	 */
	public class PVFSimulation extends Simulation {

		private var grid:IndexGrid;
		private var domain:Rectangle;
		private var h:Number; // kernel size
		
		public var k:Number = 1.0; // stiffness
		public var k_near:Number = 1.0;
		public var p_rest:Number = 1.0; // rest density

		public var R:Number = 0.1; // collision radius
		public var u:Number = 0.0; // friction parameter
		
		public var gamma:Number = 0.0; // viscosity's linear impulse
		public var beta:Number = 0.0; // viscosity's quadratic impulse
		
		private var springs:Vector.<Vector.<Number>>;
		
		public function PVFSimulation(cellSpace:Number, domain:Rectangle, MaxNumParticles:uint, MaxNeighborSize:uint) {
			this.grid = new IndexGridO(cellSpace, domain, MaxNumParticles, MaxNeighborSize);
			this.domain = domain;
			h = cellSpace;
			
			springs = new Vector.<Vector.<Number>>(MaxNumParticles, true);
			for (var i:uint = 0; i < MaxNumParticles - 1; i++) {
				springs[i] = new Vector.<Number>(MaxNumParticles - 1);
			}
		}
		
		override public function Calculate(Particles:FluidParticles, globalForce:Vector2, dTime:Number):void {
			globalForce.x = globalForce.y = 0;
			
			var particle:FluidParticle;

			// Start by refreshing neighboring informations
			grid.Refresh(Particles);
			
			// foreach particle i
			for each (particle in Particles.List) {
				// apply global force (probably the gravity)
				// vi += Dt * g
				particle.velocity.Inc(Vector2.mult(globalForce, dTime));
			}
			
			// modify velocities with pairwise viscosity impulses
			applyViscosity (Particles, dTime); // (Section 5.3 Viscosity)
			
			// foreach particle i
			for each (particle in Particles.List) {
				// save previous position
				// xi_prev = xi
				particle.positionOld.Set(particle.position);
				// advance to predicted position
				// xi += Dt * vi
				particle.position.Inc(Vector2.mult(particle.velocity, dTime));
			}
			
			// add and remove springs, change rest lengths
			adjustSprings(); // (Section 5.2 Plasticity)
			
			// modify positions according to springs,
			// double density relaxation, and collisions
			applySpringDisplacments(); // (Section 5.1 Elasticity)
			doubleDensityRelaxation(Particles, dTime);
			resolveCollisions(Particles); // (Section 6 Interaction with Objects)
			
			// foreach particle i
			for each (particle in Particles.List) {
				// use previous position to compute next velocity
				// vi = (xi - xi_prev)/Dt
				particle.velocity.Set(Vector2.sub(particle.position, particle.positionOld).Mul(1.0 / dTime));
			}
		}
		
		private function resolveCollisions(Particles:FluidParticles):void {
			var particle:FluidParticle;
			
			// check collisions with the ground (y = Constants.DOMAIN.height), normal = (0,-1)
			var n:Vector2 = new Vector2(0, -1); // body normal at collision point
			var vp:Vector2 = new Vector2; // body velocity at the contact point
			
			for each (particle in Particles.List) {
				//if (particle.position.y + R <= domain.height) continue; // no collision
				// compute current particle velocity
				//var v:Vector2 = Vector2.sub(particle.position, particle.positionOld);
				// compute the particle relative velocity
				//v.Dec(vp);
				// v_normal = (v dot n) * n
				//var v_norm:Vector2 = n.Clone().Mul(Vector2.Dot(v, n));
				// v_tangent = v - v_normal
				//var v_tang:Vector2 = Vector2.sub(v, v_norm);
				// compute collision impulse
				//var impulse:Vector2 = Vector2.sub(v_norm, Vector2.mult(v_tang, u));
				// apply collision impulse
				//particle.position.Inc(impulse);
				if (particle.position.y > domain.height) particle.position.y = domain.height;
			}
		}
		
		private function doubleDensityRelaxation(Particles:FluidParticles, dTime:Number):void {
			var particle:FluidParticle, particlej:FluidParticle;
			var i:uint, j:uint;
			
			var rij_vec:Vector2; // unit vector from particle i to particle j
			var rij:Number; // distance between particle i and particle j
			var q:Number;
			// foreach particle i
			for (i = 0; i < Particles.List.length; i++) {
				particle = Particles.List[i];
				
				var p:Number = 0;
				var p_near:Number = 0;
				// compute density and near-density
				// foreach particle j in neighbors(i)
				var neighbor:Vector.<int> = grid.getNeighbors(i);
				for (j = 0; j < neighbor[0]; j++) {
					particlej = Particles.List[neighbor[j + 1]];

					rij = Vector2.dist(particlej.position, particle.position);
					q = rij / h;
					if (q < 1) {
						p += (1 - q) * (1 -q);
						p_near += (1 - q) * (1 - q) * (1 - q);
					}
				}
				// compute pressure and near-pressure
				var P:Number = k * (p - p_rest);
				var P_near:Number = k_near * p_near;
				
				var dx:Vector2 = new Vector2;
				// foreach particle j in neighbors(i)
				for (j = 0; j < neighbor[0]; j++) {
					particlej = Particles.List[neighbor[j + 1]];
					
					rij_vec = Vector2.sub(particlej.position, particle.position);
					rij = Math.sqrt(rij_vec.LengthSquared);
					q = rij / h;
					if (q < 1) {
						rij_vec.Mul(1.0 / rij); // normalize rij_vec
						// apply displacements
						// D = Dt*Dt*(P*(1-q)+P_near*(1-q)^2)*rij_vec / 2
						var D:Vector2 = rij_vec.Mul(0.5 * dTime * dTime * (P * (1 - q) + P_near * (1 - q) * (1 - q)));
						particlej.position.Inc(D);
						dx.Dec(D);
					}
				}
				particle.position.Inc(dx);
			}
		}

		private function applySpringDisplacments():void {
			// foreach spring ij
			for (var i:uint = 0; i < springs.length; i++) {
				// D = Dt*Dt*k_spring*(1-Lij/h)*(Lij-rij)*rij_vec
				// xi -= D/2
				// xj += D/2
			}
		}

		private function adjustSprings():void {
			// foreach neighbor pair ij, (i<j)
				// q = rij/h
				//if q < 1
					// if there is no spring ij
						// add spring ij with rest length h
					// tolerable deformation = yield ratio * rest length
					// d = yield*Lij
					// if rij > L+d // stretch
						// Lij += Dt*alpha*(rij-L-d)
					// else if rij < L-d // compress
						// Lij -= Dt*alpha*(L-d-rij)
			// foreach spring ij
				// if Lij > h
					// remove spring ij
		}

		private function applyViscosity(Particles:FluidParticles, dTime:Number):void {
			var particle:FluidParticle, particlej:FluidParticle;
			var i:uint, j:uint;
			// foreach neighbor pair ij, (i<j)
			for (i = 0; i < Particles.Count; i++) {
				particle = Particles.List[i];
				
				var neighbor:Vector.<int> = grid.getNeighbors(i);
				for (j = 0; j < neighbor[0]; j++) {
					particlej = Particles.List[neighbor[j + 1]];
					
					var rij_vec:Vector2 = Vector2.sub(particlej.position, particle.position);
					var rij:Number = Math.sqrt(rij_vec.LengthSquared);
					var q:Number = rij / h;
					if (q < 1) {
						// inward radial velocity
						//u = (vi-vj) dot rij_vec
						var u:Number = Vector2.Dot(Vector2.sub(particle.velocity, particlej.velocity), rij_vec);
						if (u > 0) {
							// linear and quadratic impulses
							// I = Dt*(1-q)*(gamma*u+beta*u^2)*rij_vec
							var I:Vector2 = rij_vec.Mul(dTime * (1 - q) * (gamma * u + beta * u * u)  * 0.5);
							// vi -= I/2
							particle.velocity.Dec(I);
							// vj += I/2
							particlej.velocity.Inc(I);
						}
					}
				}
			}
		}
	}

}