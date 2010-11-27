package renderers {
	import flx.HakSprite;
	import particles.FluidParticles;

	/**
	 * Abstract renderer
	 */
	public class Renderer extends HakSprite {

		protected var radiusSq:Number;
		public function set radius(r:Number):void {
			radiusSq = r * r;
		}

		public var minThreshold:Number = 3.5;
		public var maxThreshold:Number = Number.MAX_VALUE;

		public function Renderer(Width:Number, Height:Number) {
			super();
			createGraphic(Width, Height);
			radius = 20;
		}
		
		public function drawParticles(Particles:FluidParticles):void {
			_framePixels.fillRect(_flashRect, 0x0);
		}
		
		protected function equation(px:int, py:int, tx:int, ty:int):Number {
			return radiusSq / ((px - tx) * (px - tx) + (py - ty) * (py - ty));
		}

		protected function xToScreen(x:Number):Number {
			return (x - Constants.SIM_DOMAIN.x) * width / Constants.SIM_DOMAIN.width;
		}

		protected function yToScreen(y:Number):Number {
			return (y - Constants.SIM_DOMAIN.y) * height / Constants.SIM_DOMAIN.height;
		}

		override public function render():void {
			if (!visible) return;
			super.render();
		}

		protected static function getARGB(alpha:uint, red:uint , green:uint , blue:uint):uint {
			return (Math.min(alpha, 255) << 24 | Math.min(red, 255) << 16 | Math.min(green, 255) << 8 | Math.min(blue, 255));
		}
		
	}

}