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

		public var filter:int = 2; // 0: no filter, 1:pixel bender, 2:bitmapData.threshold()
		private var pbFilter:ShaderFilter;
		
		private var bitmapData:BitmapData;

		public var alpha1:Number = 0.38;
		public var alpha2:Number = 0.56;
		
		public var color1:Array = [0, 0, 0, 0];
		public var color2:Array = [0, 0.33, 0.97, 1];
		public var color3:Array = [0, 0, 0.7, 1];
		
		//{ Initialization
		public function SbatRenderer(Width:uint, Height:uint, texSize:int) {
			super(Width, Height);
			radius = texSize;

			initPSprite();

			bitmapData = new BitmapData(width, height, true);
			
			initPbFilter();
		}
			
		private function initPbFilter():void {
			var s:Shader = new Shader(new PBFilter());
			s.data.alpha1.value = [alpha1];
			s.data.alpha2.value = [alpha2];
			s.data.color1.value = color1;
			s.data.color2.value = color2;
			s.data.color3.value = color3;
			s.precisionHint = ShaderPrecision.FAST;

			pbFilter = new ShaderFilter(s);
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
		//}
		
		override public function drawParticles(Particles:FluidParticles):void {
			_framePixels.fillRect(_flashRect, 0);

			//iterate through every metaball
			_framePixels.lock();
			for each (var particle:FluidParticle in Particles.List) {
				drawParticle(particle);
			}
			_framePixels.unlock();

			if (filter == 1) {
				_framePixels.applyFilter(_framePixels, _flashRect, _flashPointZero, pbFilter);
			} else if (filter == 2) {
				bitmapData.fillRect(_flashRect, float4ToARGB(color1));
				bitmapData.threshold(_framePixels, _flashRect, _flashPointZero, ">", Math.floor(alpha1 * 255), float4ToARGB(color2), 255);
				bitmapData.threshold(_framePixels, _flashRect, _flashPointZero, ">", Math.floor(alpha2 * 255), float4ToARGB(color3), 255);
				_framePixels.copyPixels(bitmapData, _flashRect, _flashPointZero, null, null, false);
			}
		}

		protected function drawParticle(particle:FluidParticle):void {
			var px:Number = xToScreen(particle.position.x) - pSprite.width / 2;
			var py:Number = yToScreen(particle.position.y) - pSprite.height / 2;
			draw(pSprite, px, py);
		}
		
		private function float4ToARGB(color:Array):uint {
			return Math.floor(color[3] * 255) << 24 | Math.floor(color[0] * 255) << 16 | Math.floor(color[1] * 255) << 8 | Math.floor(color[2] * 255);
		}
	}

}