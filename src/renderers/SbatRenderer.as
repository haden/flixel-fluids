package renderers {
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;
	import org.flixel.FlxSprite;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import flash.display.ShaderPrecision;
	
	/**
	 * Renderer based on Sbat's Gluey
	 */
	public class SbatRenderer extends Renderer {
		[Embed(source = '../../metaball.pbj', mimeType = 'application/octet-stream')] static private const PBFilter:Class;
		private var pSprite:FlxSprite;

		private var pbFilter:ShaderFilter;

		public function SbatRenderer(Width:uint, Height:uint, texSize:int) {
			super(Width, Height);
			radius = texSize;

			initPSprite();

			var s:Shader = new Shader(new PBFilter());
			pbFilter = new ShaderFilter(s);
			pbFilter.shader.data.alpha1.value = [0.38];
			pbFilter.shader.data.alpha2.value = [0.56];
			pbFilter.shader.data.color1.value = [0, 0, 0, 0];
			pbFilter.shader.data.color2.value = [0, 0.33, 0.97, 1];
			pbFilter.shader.data.color3.value = [0, 0, 0.7, 1];
			pbFilter.shader.precisionHint = ShaderPrecision.FAST;
		}

		private function initPSprite() : void {
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

			//iterate through every metaball
			for each (var particle:FluidParticle in Particles.List) {
				var px:Number = xToScreen(particle.position.x);
				var py:Number = yToScreen(particle.position.y);
				draw(pSprite, px - pSprite.width / 2, py - pSprite.height / 2);
			}
			
			_framePixels.applyFilter(_framePixels, _flashRect, _flashPointZero, pbFilter);
		}

	}

}