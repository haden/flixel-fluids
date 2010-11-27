package renderers {
	import flash.display.BitmapData;
	import flx.HakSprite;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import org.flixel.FlxG;
	import utils.Vector2;
	
	/**
	 * Renderer that computes just draws a sprite for each metaball
	 */
	public class MBRenderer0 extends Renderer {

		private var pSprite:FlxSprite;

		public function MBRenderer0(Width:uint, Height:uint, texSize:int, energy:Number, fallOff:Number, energyThreshold:Number) {
			super(Width, Height);
			initPSprite(texSize, energy, fallOff, energyThreshold);
		}

		private function initPSprite(texSize:int, energy:Number, fallOff:Number, energyThreshold:Number):void {
			pSprite = new FlxSprite().createGraphic(texSize, texSize);
			var bitmap:BitmapData = pSprite.pixels;
			
			var center:int = texSize / 2;
			var centerHalfSq:Number = (center / 2.0) * fallOff;
			centerHalfSq = centerHalfSq * centerHalfSq;
			var threshMax:Number = energyThreshold - (energyThreshold * 0.1);
			
			bitmap.lock();
			var dist:FlxPoint = new FlxPoint;
			var lenSq:Number;
			for (var x:uint = 0; x < texSize; x++) {
				for (var y:uint = 0; y < texSize; y++) {
					// calculate the squared distance from the center of the metaball
					dist.x = x - center;
					dist.y = y - center;
					lenSq = dist.x * dist.x + dist.y * dist.y;
					// Use gaussian as falloff function: e^-(d / (center/2))^2*energy
					var en:Number = Math.exp( -lenSq / centerHalfSq) * energy;
					
					// clamp
					if (en < 0) en = 0;
					else if (en > threshMax) en = threshMax;
					
					bitmap.setPixel32(x, y, getARGB(int(en * 255.0), 0, 255, 255));
				}
			}
			bitmap.unlock();
		}

		override public function drawParticles(Particles:FluidParticles):void {
			super.drawParticles(Particles);
			
			//iterate through every metaball
			for each (var particle:FluidParticle in Particles.List) {
				var px:Number = xToScreen(particle.position.x);
				var py:Number = yToScreen(particle.position.y);
				draw(pSprite, px - pSprite.width / 2, py - pSprite.height / 2);
			}
		}

	}

}