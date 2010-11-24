package simulation.solvers {
	import utils.Vector2;
	/**
	 * ...
	 * @author Saladin
	 */
	public class Solver{

		//{ Properties
		
		public var Damping:Number;

		//}
		
		public function Solver(Damping:Number = 0) {
			this.Damping = Damping;
		}
		
		//{ Methods
		
		public function SolveA(position:Vector2, positionOld:Vector2, velocity:Vector2, acceleration:Vector2, timeStep:Number):void {
			throw new Error("Not Implemented");
		}

		public function Solve(position:Vector2, positionOld:Vector2, velocity:Vector2, force:Vector2, mass:Number, timeStep:Number):void {
			SolveA(position, positionOld, velocity, Vector2.mult(force, 1 / mass), timeStep);
		}
		
		//}
	}

}