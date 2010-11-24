package bounds {
	import flash.display.Graphics;
	import utils.MinMax;
	import utils.Vector2;
	/**
	 * Oriented bounded box
	 * 
	 * @author Saladin
	 */
	public class OBB extends BoundingVolume {
		
		private var axis:Vector.<Vector2>;
		
		//{ Properties

		/** half width of the box */
		private var extents:Vector2 = new Vector2;
		public function get Extents():Vector2 { return extents; }
		public function set Extents(value:Vector2):void { extents.Set(value); }
		
		override public function get Axis():Vector.<Vector2> { return axis; }

		//}

		//{ Constructor
		
		public function OBB(Position:Vector2, Extents:Vector2) {
			super();
			this.Extents = Extents;
			this.Position = Position;
			
			axis = new Vector.<Vector2>(2, true);
			axis[0] = Vector2.UnitX;
			axis[1] = Vector2.UnitY;
		}
		
		//}
		
		//{ Methods

		/**
		 * Projects an axis of this bounding volume
		 * @param	axis The axis.
		 * @param	mm The min and max.
		 */
		public override function Project(axis:Vector2, /*out*/mm:MinMax):void {
			var pos:Number = Vector2.Dot(this.Position, axis);
			var radius:Number = Math.abs(Vector2.Dot(axis, this.Axis[0])) * this.Extents.x
				+ Math.abs(Vector2.Dot(axis, this.Axis[1])) * this.Extents.y;
			mm.min = pos - radius;
			mm.max = pos + radius;
		}

		/**
		 * Rotates the obb by the specified angle
		 * @param	angle The angle in radians
		 */
		public function Rotate(angle:Number):void {
			Axis[0] = RotateAxis(angle, Axis[0]);
			Axis[1] = RotateAxis(angle, Axis[1]);
		}

		/**
		 * Rotates the obb axis.
		 * @param	angle The angle in radians.
		 * @param	axis The axis.
		 * @return
		 */
		private function RotateAxis(angle:Number, axis:Vector2):Vector2 {
			var cos:Number = Math.cos(angle);
			var sin:Number = Math.sin(angle);
			return new Vector2(
				axis.x * cos + axis.y * sin,
				axis.y * cos - axis.x * sin);
		}

		//}

		//{ Render

		/// <summary>
		/// Draws this instance.
		/// </summary>
		public override function Draw(graphics:Graphics, Width:Number, Height:Number):void {
			var exX:Vector2 = Vector2.mult(this.Axis[0], this.Extents.x);
			var exY:Vector2 = Vector2.mult(this.Axis[1], this.Extents.y);

			var dx:Number = Width / Constants.SIM_DOMAIN.width;
			var dy:Number = Height / Constants.SIM_DOMAIN.height;
			
			graphics.lineStyle(1, 0xCC2200, 1);
			graphics.moveTo((Position.x + exX.x + exY.x - Constants.SIM_DOMAIN.x) * dx, (Position.y + exX.y + exY.y - Constants.SIM_DOMAIN.y) * dy);
			graphics.lineTo((Position.x - exX.x + exY.x - Constants.SIM_DOMAIN.x) * dx, (Position.y - exX.y + exY.y - Constants.SIM_DOMAIN.y) * dy);
			graphics.lineTo((Position.x - exX.x - exY.x - Constants.SIM_DOMAIN.x) * dx, (Position.y - exX.y - exY.y - Constants.SIM_DOMAIN.y) * dy);
			graphics.lineTo((Position.x + exX.x - exY.x - Constants.SIM_DOMAIN.x) * dx, (Position.y + exX.y - exY.y - Constants.SIM_DOMAIN.y) * dy);
			graphics.lineTo((Position.x + exX.x + exY.x - Constants.SIM_DOMAIN.x) * dx, (Position.y + exX.y + exY.y - Constants.SIM_DOMAIN.y) * dy);
		}

		//}
		
	}

}