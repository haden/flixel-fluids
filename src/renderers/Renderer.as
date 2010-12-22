package renderers {
	import flx.HakSprite;
	import particles.FluidParticles;

	/**
	 * Abstract renderer
	 */
	public class Renderer extends HakSprite {

		protected var radiusSq:Number;
		private var _radius:Number;
		public function get radius():Number { return _radius; }
		public function set radius(r:Number):void {
			_radius = r;
			radiusSq = r * r;
		}

		public var minThreshold:Number = 3.5;
		public var maxThreshold:Number = Number.MAX_VALUE;

		public function Renderer(Width:Number, Height:Number) {
			super();
			createGraphic(Width, Height);
			radius = 20;
		}
		
		public function beginDraw():void {
			_framePixels.fillRect(_flashRect, 0x0);
		}

		public function drawParticle(x:Number, y:Number, color:uint):void { }
		
		public function drawParticleM(x:Number, y:Number, material:uint):void { }
		
		public function endDraw():void { }
		
		protected function equation(px:int, py:int, tx:int, ty:int):Number {
			return radiusSq / ((px - tx) * (px - tx) + (py - ty) * (py - ty));
		}

		override public function render():void {
			if (!visible) return;
			super.render();
		}

		public static function getARGB(alpha:uint, red:uint , green:uint , blue:uint):uint {
			return (Math.min(alpha, 255) << 24 | Math.min(red, 255) << 16 | Math.min(green, 255) << 8 | Math.min(blue, 255));
		}

		public static function getRGBf(red:Number, green:Number, blue:Number):uint {
			return getARGB(255, red * 255, green * 255, blue * 255);
		}
		
	}

}