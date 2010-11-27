package renderers {
	import flash.display.BitmapData;
	import org.flixel.FlxSprite;
	import particles.FluidParticle;
	import particles.FluidParticles;
	
	/**
	 * Renderer based on Sbat's Gluey
	 */
	public class MBRendererSbat extends Renderer {

		private var pSprite:FlxSprite;
		private var bitmapData:BitmapData;

		public function MBRendererSbat(Width:uint, Height:uint, texSize:int) {
			super(Width, Height);

			initPSprite(texSize);
			bitmapData = new BitmapData(width, height, true, 0);
		}

		private function initPSprite(radius:int) : void {
			var size:int = radius * 2;
			pSprite = new FlxSprite().createGraphic(size, size);
			var bitmapData:BitmapData = pSprite.pixels;

			for (var y:int = 0; y < size; y++) {
				for (var x:int = 0; x < size;x++) {
                    var distx:Number = (x - radius);
                    var disty:Number = (y - radius);
                    var influence:Number = (distx * distx + disty * disty) / radiusSq;
					influence = (influence < 1) ? (1 - influence) * (1 - influence):0;
					bitmapData.setPixel32(x, y, getARGB(255 * influence, 255, 255, 255));
                }
            }
        }

		override public function drawParticles(Particles:FluidParticles):void {
			_framePixels.fillRect(_flashRect, 0);
			bitmapData.fillRect(_flashRect, 0);

			//iterate through every metaball
			for each (var particle:FluidParticle in Particles.List) {
				var px:Number = xToScreen(particle.position.x);
				var py:Number = yToScreen(particle.position.y);
				draw(pSprite, px - pSprite.width / 2, py - pSprite.height / 2);
			}

			bitmapData.threshold(_framePixels, _flashRect, _flashPointZero, ">", 85, 0xffffffff, 255);
			_framePixels.copyPixels(bitmapData, _flashRect, _flashPointZero);
		}

	}

}