package bounds {
	import flash.display.Graphics;
	import utils.Vector2;
	import utils.MinMax;
	import utils.Penetration;
	
	/**
	 * ...
	 * @author Saladin
	 */
	public class BoundingVolume {
		
		//{ Static Members
		
		private static var ID_COUNTER:int = 0;

		//}
		
		//{ Properties

		private var position:Vector2 = new Vector2;
		public function get Position():Vector2 { return position; }
		public function set Position(value:Vector2):void { position.Set(value); }

		public function get Axis():Vector.<Vector2> { 
			throw new Error("Not Implemented");
		}

		public var IsFixed:Boolean = false;

		public var Id:int;

		/** Safety Distance */
		public var Margin:Number;

		//}
		
		//{ Constructor
		
		public function BoundingVolume(Position:Vector2 = null, Margin:Number = Constants.FLOAT_EPSILON) {
			Id = ID_COUNTER++;
			if (Position) this.Position = Position;
			this.Margin = Margin;
		}

		//}
		
		//{ Methods

		/**
		 * Projects an axis of this bounding volume.
		 * @param	axis The axis.
		 * @param	minMax The min and max.
		 */
		public function Project(axis:Vector2, minMax:MinMax):void {
			throw new Error("Not Implemented");
		}

		/**
		 *  Tests if this bounding volume intersects the other bounding volume,
		 *  using the "Separating Axis Test" (SAT).
		 * @param	other The bounding volume to test against
		 * @param	pen The penetration vector (direction of the least penetration). And Length of penetration. Can be null
		 * @return True, if the both bounding volumes intersect.
		 */
		public function Intersects(other:BoundingVolume, pen:Penetration):Boolean {
			
			if (pen) {
				pen.Normal = Vector2.Zero;
				pen.Length = Number.MAX_VALUE;
			}
			
			var axis:Vector2;
			
			// Axis of this
			if (this.Axis != null) {
				for each (axis in this.Axis) {
					if (!FindLeastPenetrating(axis, other, pen)) {
						return false;
					}
				}
			}

			// Axis of other
			if (other.Axis != null) {
				for each (axis in other.Axis) {
					// TODO ne devrait on pas tester par rapport à (axis, this, pen) ???
					if (!FindLeastPenetrating(axis, other, pen)) {
						return false;
					}
				}
			}

			// Flip penetrationDirection to point away from this
			if (pen && Vector2.Dot(Vector2.sub(other.Position, this.Position), pen.Normal) > 0.0) {
				pen.Normal.Mul(-1.0);
			}

			return true;
		}

		/**
		 * Finds a least penetrating vector
		 * @param	axis The axis.
		 * @param	other the other.
		 * @param	penetration penetration normal and length
		 * @return True, if a least penetrating vector could be found (no Axis separates the bounding volume).
		 */
		private function FindLeastPenetrating(axis:Vector2, other:BoundingVolume, /*ref*/pen:Penetration):Boolean {
			var mmThis:MinMax = new MinMax();
			var mmOther:MinMax = new MinMax();

			// Tests if separating axis exists
			if (TestSeparatingAxis(axis, other, mmThis, mmOther)) {
				return false;
			}

			// Find least penetrating axis
			var diff:Number = Math.min(mmOther.max, mmThis.max) - Math.max(mmOther.min, mmThis.min);
			// Store penetration vector
			if (pen && diff < pen.Length) {
				pen.Length    = diff;
				pen.Normal    = axis;
			}
			return true;
		}

		/**
		 * Tests if a separating axis can be found between this bounding volume and the other
		 * @param	axis The axis to test againt
		 * @param	other The bounding volume to test against
		 * @param	minMaxThis min/max of this
		 * @param	minMaxOther min/max of other
		 * @return	True, if the Axis separates the bounding volumes
		 */
		private function TestSeparatingAxis(axis:Vector2, other:BoundingVolume, /*out*/mmThis:MinMax, /*out*/mmOther:MinMax):Boolean {
			this.Project(axis, mmThis);
			other.Project(axis, mmOther);

			// Add safety margin distance
			mmThis.min  -= this.Margin;
			mmThis.max  += this.Margin;
			mmOther.min -= other.Margin;
			mmOther.max += other.Margin;

			if (mmThis.min >= mmOther.max || mmOther.min >= mmThis.max) {
				return true;
			}
			
			return false;
		}

		//}

		public function Draw(graphics:Graphics, Width:Number, Height:Number):void { 
			throw new Error("Not Implemented");
		}
	}

}