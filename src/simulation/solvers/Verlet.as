package simulation.solvers {
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