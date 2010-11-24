package simulation {
	import flash.geom.Rectangle;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import simulation.sks.SKPoly6;
	import simulation.sks.SKSpiky;
	import simulation.sks.SKViscosity;
	import simulation.sks.SmoothingKernel;
	import utils.Vector2;
	
	/**
	 * ...
	 * @author Saladin
	 */
	public class SPHSimulation{

		private var grid:IndexGrid;
		
		//{ Properties

		private var cellSpace:Number;
		public function get CellSpace():Number { return cellSpace; }

		public var Domain:Rectangle;

		public var SkGeneral:SmoothingKernel;

		public var SkPressure:SmoothingKernel;

		public var SkViscosity:SmoothingKernel;

		public var Viscosity:Number;

		//}

		//{ Constructor
		
		public function SPHSimulation(cellSpace:Number, domain:Rectangle, MaxNumParticles:uint, MaxNeighborSize:uint) {
			this.cellSpace    = cellSpace;
			this.Domain       = domain;
			this.Viscosity    = Constants.VISC0SITY;
			this.SkGeneral    = new SKPoly6(cellSpace);
			this.SkPressure   = new SKSpiky(cellSpace);
			this.SkViscosity  = new SKViscosity(cellSpace);
			this.grid         = new IndexGridO(cellSpace, domain, MaxNumParticles, MaxNeighborSize);
		}

		//}
		
		//{ Methods

		/**
		 * Simulates the specified particles.
		 * @param	Particles The particles.
		 * @param	globalForce The global force.
		 * @param	dTime The time step.
		 */
		public function Calculate(Particles:FluidParticles, globalForce:Vector2, dTime:Number):void {
			//FlxFluids.Monitors.mark("sph.calculate.refresh");
			
			grid.Refresh(Particles);

			//FlxFluids.Monitors.addTimer("sph.calculate.refresh");
			//FlxFluids.Monitors.mark("sph.calculate.pressure(o)");
			
			CalculatePressureAndDensitiesO(Particles, grid);

			//FlxFluids.Monitors.addTimer("sph.calculate.pressure(o)");
			//FlxFluids.Monitors.mark("sph.calculate.forces");
			
			CalculateForces(Particles, grid, globalForce);

			//FlxFluids.Monitors.addTimer("sph.calculate.forces");
			//FlxFluids.Monitors.mark("sph.calculate.particles");
			
			UpdateParticles(Particles, dTime);

			//FlxFluids.Monitors.addTimer("sph.calculate.particles");
			//FlxFluids.Monitors.mark("sph.calculate.distance(o)");

			CheckParticleDistanceO(Particles, grid);

			//FlxFluids.Monitors.addTimer("sph.calculate.distance(o)");
		}

		/**
		 * Calculates the pressure and densities (optimized)
		 * @param	Particles The particles.
		 * @param	grid The grid.
		 */
		private function CalculatePressureAndDensitiesO(Particles:FluidParticles, grid:IndexGrid):void {
			var dist:Vector2 = new Vector2;
			var particle:FluidParticle, nParticle:FluidParticle;
			var skg:Number;
			var i:uint, j:uint, nIdx:uint;

			for (i = 0; i < Particles.Count; i++ ) {
				Particles.List[i].Density = 0;
			}

			for (i = 0; i < Particles.Count; i++ ) {
				particle = Particles.List[i];

				var neighbor:Vector.<int> = grid.getNeighbors(i);
				
				//for each (var nIdx:int in neighbor) {
				for (j = 0; j < neighbor[0]; j++) {
					nIdx = neighbor[j + 1];
					nParticle = Particles.List[nIdx];

					dist.x = particle.position.x - nParticle.position.x;
					dist.y = particle.position.y - nParticle.position.y;
					
					skg = this.SkGeneral.Calculate(dist);
					
					particle.Density += particle.Mass * skg;
					nParticle.Density += nParticle.Mass * skg;
				}

				particle.Density += 2 * particle.Mass * SkGeneral.Calculate(Vector2.Zero);
			}

			for (i = 0; i < Particles.Count; i++ ) {
				Particles.List[i].UpdatePressure();
			}
		}
		
		/**
		 * Calculates the pressure and viscosity forces.
		 * @param	Particles The particles.
		 * @param	grid the grid.
		 * @param	globalForce the global force.
		 */
		private function CalculateForces(Particles:FluidParticles, grid:IndexGrid, globalForce:Vector2):void {
			var f:Vector2, dist:Vector2;
			var scalar:Number;
			var particle:FluidParticle;
			var nParticle:FluidParticle;
			var j:int, nIdx:int;
			
			dist = new Vector2;
			f = new Vector2;
			
			var pforce:Vector2;
			var pvel:Vector2;
			var ppos:Vector2;
			var npforce:Vector2;
			var npvel:Vector2;
			var nppos:Vector2;
			
			for (var i:uint = 0; i < Particles.Count; i++) {
				particle = Particles.List[i];
				pforce = particle.force;
				pvel = particle.velocity;
				ppos = particle.position;
				
				// Add global force to every particle
				pforce.x += globalForce.x;
				pforce.y += globalForce.y;

				var neighbor:Vector.<int> = grid.getNeighbors(i);

				//for each (var nIdx:int in neighbor) {
				for (j = 0; j < neighbor[0]; j++) {
					nIdx = neighbor[j + 1];
					
					nParticle = Particles.List[nIdx];
					if (nParticle.Density > Constants.FLOAT_EPSILON) {
						npforce = nParticle.force;
						npvel = nParticle.velocity;
						nppos = nParticle.position;

						dist.x = ppos.x - nppos.x;
						dist.y = ppos.y - nppos.y;

						// pressure
						scalar   = nParticle.Mass * (particle.Pressure + nParticle.Pressure) / (2.0 * nParticle.Density);
						SkPressure.CalculateGradient(dist, f);
						f.x *= scalar;
						f.y *= scalar;

						pforce.x -= f.x;
						pforce.y -= f.y;
						npforce.x += f.x;
						npforce.y += f.y;

						// viscosity
						scalar   = nParticle.Mass * this.SkViscosity.CalculateLaplacian(dist) * this.Viscosity * 1 / nParticle.Density;
						f.x = scalar * (npvel.x - pvel.x);
						f.y = scalar * (npvel.y - pvel.y);

						pforce.x += f.x;
						pforce.y += f.y;
						npforce.x -= f.x;
						npforce.y -= f.y;
					}
				}
			}
		}

		/**
		 * Updates the particles positions using integration and clips them to the domain space.
		 * @param	Particles The particles.
		 * @param	dTime The time step.
		 */
		private function UpdateParticles(Particles:FluidParticles, dTime:Number):void {
			var r:Number = this.Domain.right;
			var l:Number = this.Domain.x;
			// Rectangle contains coordinates inverse on y
			var t:Number = this.Domain.bottom;
			var b:Number = this.Domain.y;
			var particle:FluidParticle;

			for each (particle in Particles.List) {
				// Clip positions to domain space
				if (particle.position.x < l) {
					particle.position.x = l + Constants.FLOAT_EPSILON;
				} else if (particle.position.x > r) {
					particle.position.x = r - Constants.FLOAT_EPSILON;
				} 
				if (particle.position.y < b) {
					particle.position.y = b + Constants.FLOAT_EPSILON;
				} else if (particle.position.y > t) {
					particle.position.y = t - Constants.FLOAT_EPSILON;
				}

				// Update velocity + position using forces
				particle.Update(dTime);
				// Reset force
				particle.force.x = particle.force.y = 0;
			}
		}

		/**
		 * Checks the distance between the particles and corrects it, if they are too near.
		 * @param	Particles The particles.
		 * @param	grid The grid.
		 */
		private function CheckParticleDistanceO(Particles:FluidParticles, grid:IndexGrid):void {
			var minDist:Number = 0.5 * CellSpace;
			var minDistSq:Number = minDist * minDist;

			var particle:FluidParticle;
			var nParticle:FluidParticle;

			var dx:Number, dy:Number;
			var scalar:Number;
			
			for (var i:int = 0; i < Particles.Count; i++) {
				particle = Particles.List[i];

				var neighbor:Vector.<int> = grid.getNeighbors(i);

				//for each (var nIdx:int in neighbor) {
				for (var j:int = 0; j < neighbor[0]; j++) {
					var nIdx:uint = neighbor[j + 1];
					nParticle = Particles.List[nIdx];

					dx = nParticle.position.x - particle.position.x;
					dy = nParticle.position.y - particle.position.y;

					// On ne peut utiliser GridIndex.distances ici parceque les positions des particules changent
					var distLenSq:Number = dx * dx + dy * dy;
					if (distLenSq < minDistSq) {
						if (distLenSq > Constants.FLOAT_EPSILON) {
							var distLen:Number = Math.sqrt(distLenSq);
							scalar = (distLen - minDist) / distLen;
							dx *= scalar;
							dy *= scalar;

							nParticle.position.x -= dx;
							nParticle.position.y -= dy;

							nParticle.positionOld.x -= dx;
							nParticle.positionOld.y -= dy;

							particle.position.x += dx;
							particle.position.y += dy;

							particle.positionOld.x += dx;
							particle.positionOld.y += dy;
						} else {
							nParticle.position.y -= minDist;
							nParticle.positionOld.y -= minDist;
							particle.position.y += minDist;
							particle.positionOld.y += minDist;
						}
					}
				}
			}
		}

	}

}