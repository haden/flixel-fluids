package particles {
	import bounds.PointVolume;
	import simulation.solvers.Verlet;
	import utils.Vector2;
	import simulation.solvers.Solver;
	import bounds.BoundingVolume;
	/**
	 * Implementation of a fluid particle 
	 * 
	 * @author Saladin
	 */
	public class FluidParticle{
		
		//{ Members
		
		public var Life:int;
		public var Mass:Number;
		public var Density:Number;
		public var Pressure:Number;
		
		//}

		//{ Properties
		
		public var position:Vector2 = new Vector2;
		public function get Position():Vector2 { return position; }
		public function set Position(value:Vector2):void { position.Set(value); }

		public var positionOld:Vector2 = new Vector2;
		public function get PositionOld():Vector2 { return positionOld; }
		public function set PositionOld(value:Vector2):void { positionOld.Set(value); }

		public var velocity:Vector2 = new Vector2;
		public function get Velocity():Vector2 { return velocity; }
		public function set Velocity(value:Vector2):void { velocity.Set(value); }

		public var force:Vector2 = new Vector2;
		public function get Force():Vector2 { return force; }
		public function set Force(value:Vector2):void { force.Set(value); }

		private var _solver:Solver;
		public function get solver():Solver { return _solver; }
		public function set solver(value:Solver):void { _solver = value; }
		
		private var bv:BoundingVolume;
		public function get BV():BoundingVolume { return bv; }
		public function set BV(value:BoundingVolume):void { bv = value; }

		//}
		
		//{ Constructor
		
		public function FluidParticle(pos:Vector2, oldPos:Vector2, mass:Number, vel:Vector2 = null) {
			this.Life = 0;
			this.Position = pos;
			this.PositionOld = oldPos;
			this.Mass = mass;
			if (vel) this.Velocity = vel;
			this.Density = Constants.DENSITY_OFFSET;
			// update (integrate) using basic verlet with small drag
			this.solver = new Verlet(0.01);
			this.BV = new PointVolume(this.Position, Constants.CELL_SPACE * 0.25);

			this.UpdatePressure();
		}
		
		//}
		
		//{ Methods

		/**
		* @return this.Position - particle.Position
		 */
		public function VectorTo(particle:FluidParticle, out:Vector2 = null):Vector2 {
			if (!out) out = new Vector2;
			return out.Set(position).Dec(particle.position);
		}
		
		/**
		 * Updates the pressure using a modified ideal gas state equation 
		 * (see the paper "Smoothed particles: A new paradigm for animating highly deformable bodies." by Desbrun)
		 */
		public function UpdatePressure():void {
			this.Pressure = Constants.GAS_K * (this.Density - Constants.DENSITY_OFFSET);
		}

		/**
		 * Updates the particle.
		 * @param	dTime The time step.
		 */
		public function Update(dTime:Number):void {
			Life++;
			// integrate
			solver.Solve(Position, PositionOld, Velocity, Force, Mass, dTime);
			// update bounding volume
			bv.Position = Position;
		}

      //}endregion

	}

}