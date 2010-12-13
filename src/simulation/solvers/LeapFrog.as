package simulation.solvers {
	import particles.FluidParticle;
	import utils.Vector2;
	/**
	 * Ordinary differential equation solver using a basic verlet integration
	 * 
	 */
	public class LeapFrog extends Solver {
		
		public function LeapFrog(Damping:Number = 0) {
			super(Damping);
		}
		
		//{ Methods

		override public function SolveP(particle:FluidParticle, timeStep:Number):void {
			var acc:Vector2 = Vector2.mult(particle.force, 1.0 / particle.Mass);
			var old_pos:Vector2 = particle.position.Clone();

			// compute v(t + 1/2dt)
			// vel_half_next = vel_half[i] + t*acc[i]
			var vel_half_next:Vector2 = particle.half_vel.Clone().Inc(acc.Mul(timeStep));
			
			// compute r(t+ dt)
			// pos[i] = pos[i] + t*vel_half_next
			particle.position.Inc(Vector2.mult(vel_half_next, timeStep));
			// compute v(t)
			// vel[i] = 0.5*(vel_half_next + vel_half[i])
			particle.velocity.Set(vel_half_next).Inc(particle.half_vel).Mul(0.5);
			// vel_half[i] = vel_half_next
			particle.half_vel.Set(vel_half_next);
			
			particle.positionOld.Set(old_pos);
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