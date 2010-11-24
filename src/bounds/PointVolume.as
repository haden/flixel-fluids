package bounds {
	import flash.display.Graphics;
	import utils.MinMax;
	import utils.Vector2;
	/**
	 * Point / Particle (contains only the position)
	 * 
	 * @author Saladin
	 */
	public class PointVolume extends BoundingVolume{
		//{ Properties

		override public function get Axis():Vector.<Vector2> { return null; }

		//}
		
		public function PointVolume(Position:Vector2 = null, Margin:Number = Constants.FLOAT_EPSILON) {
			super(Position, Margin);
		}
		
		//{ Methods

		/**
		 * Projects an axis of this bounding volume
		 */
		public override function Project(axis:Vector2, mm:MinMax):void  {
			mm.min = mm.max = Vector2.Dot(Position, axis);
		}

		//}

		//{ Render

		public override function Draw(graphics:Graphics, Width:Number, Height:Number):void {
			graphics.drawRect(
				(Position.x - Constants.SIM_DOMAIN.x) * Width / Constants.SIM_DOMAIN.width, 
				(Position.y -Constants.SIM_DOMAIN.y) * Height / Constants.SIM_DOMAIN.height, 4, 4);
		}

		//}
		
	}

}