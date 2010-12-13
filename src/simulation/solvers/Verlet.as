package simulation.solvers {
	import particles.FluidParticle;
	import utils.Vector2;
	/**
	 * Ordinary differential equation solver using a basic verlet integration
	 * 
	 * @author Saladin
	 */
	public class Verlet extends Solver {
		
		public function Verlet(Damping:Number = 0) {
			super(Damping);
		}
		
		//{ Methods

		override public function SolveP(particle:FluidParticle, timeStep:Number):void {
			var t:Vector2 = new Vector2;
			var acceleration:Vector2 = Vector2.mult(particle.force, 1.0 / particle.Mass);
			var oldPos:Vector2 = particle.position.Clone();
			
			// Position = Position + (1.0f - Damping) * (Position - PositionOld) + dt * dt * a;
			acceleration.Mul(timeStep * timeStep);
			//t.Set(particle.position).Dec(particle.positionOld);
			t.x = particle.position.x - particle.positionOld.x;
			t.y = particle.position.y - particle.positionOld.y;
			
			t.Mul(1.0 - Damping);
			
			//t.Inc(acceleration);
			t.x += acceleration.x;
			t.y += acceleration.y;
			
			//position.Inc(t);
			particle.position.x += t.x;
			particle.position.y += t.y;
			
			//positionOld.Set(oldPos);
			particle.positionOld.Set(oldPos);

			// calculate velocity
			// Velocity = (Position - PositionOld) / dt;
			//t.Set(position).Dec(positionOld);
			t.x = particle.position.x - particle.positionOld.x;
			t.y = particle.position.y - particle.positionOld.y;

			//velocity.Set(t.Mul(1.0 / timeStep));
			particle.velocity.x = t.x / timeStep;
			particle.velocity.y = t.y / timeStep;
		}
		
		public override function SolveA(position:Vector2, positionOld:Vector2, velocity:Vector2, acceleration:Vector2, timeStep:Number):void {
			var t:Vector2 = new Vector2;
			var oldPos:Vector2 = position.Clone();
			
			// Position = Position + (1.0f - Damping) * (Position - PositionOld) + dt * dt * a;
			//position.Inc(Vector2.Sub(position, positionOld).Mul(1 - Damping).Inc(acceleration.Mul(timeStep * timeStep)));
			acceleration.Mul(timeStep * timeStep);
			//t = Vector2.Sub(position, positionOld);
			t.Set(position).Dec(positionOld);
			t.Mul(1.0 - Damping);
			t.Inc(acceleration);
			position.Inc(t);
			positionOld.Set(oldPos);

			// calculate velocity
			// Velocity = (Position - PositionOld) / dt;
			//t = Vector2.Sub(position, positionOld);
			t.Set(position).Dec(positionOld);
			velocity.Set(t.Mul(1.0 / timeStep));
		}

		//}
	}

}