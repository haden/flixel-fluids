package renderers {
	import flx.HakSprite;
	import org.flixel.FlxSprite;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import org.flixel.FlxG;
	
	/**
	 * Renderer that computes the metaballs' equation for each pixel and for each metaball
	 */
	public class MBRenderer1 extends Renderer {

		public function MBRenderer1(Width:uint, Height:uint) {
			super(Width, Height);
		}
		
		override public function drawParticles(Particles:FluidParticles):void {
			super.drawParticles(Particles);
			
			// value to act as a summation of all metaballs' fields applied to this particular pixel
			var sum:Number = 0;
			
			// iterate over every pixel in the screen
			for (var tx:int = 0; tx < width; tx++) {
				for (var ty:int = 0; ty < height; ty++) {
					// reset the summation
					sum = 0;
					
					//iterate through every metaball
					for each (var particle:FluidParticle in Particles.List) {
						var px:Number = xToScreen(particle.position.x);
						var py:Number = yToScreen(particle.position.y);
						sum += equation(px, py, tx, ty);
					}
					
					//decide whether to draw a pixel
					//trace(sum);
					if (sum >= minThreshold && sum <= maxThreshold) {
						_framePixels.setPixel32(tx, ty, 0xffffffff);
					}
				}
			}
		}

	}

}