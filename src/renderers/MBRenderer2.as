package renderers {
	import flx.HakSprite;
	import org.flixel.FlxSprite;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import org.flixel.FlxG;
	
	/**
	 * Faster implementation (but not that fast) that computes the influence for each pixel "arround" each metaball
	 */
	public class MBRenderer2 extends Renderer {

		public var cSize:uint = 50; // size of computation arround a metaball

		private var sums:Array/*Number*/;

		public function MBRenderer2(Width:uint, Height:uint) {
			super(Width, Height);

			sums = new Array/*Number*/;
		}

		override public function drawParticles(Particles:FluidParticles):void {
			var i:uint, x:int, y:int, tx:int,ty:int;
			var minx:uint, miny:uint, maxx:uint, maxy:uint;
			var particle:FluidParticle;
			var px:int, py:int;

			super.drawParticles(Particles);

			// reset the summation
			var len:int = sums.length;
			for (i = 0; i < len; i++) {
				sums[i] = 0;
			}

			//iterate through every metaball
			for each (particle in Particles.List) {
				px = int(xToScreen(particle.position.x));
				py = int(yToScreen(particle.position.y));

				minx = Math.max(px - cSize, 0);
				miny = Math.max(py - cSize, 0);
				maxx = Math.min(width - 1, px + cSize);
				maxy = Math.min(height - 1, py + cSize);

				for (tx = minx; tx < maxx; tx++) {
					for (ty = miny; ty < maxy; ty++) {
						sums[tx + ty * width] += equation(px, py, tx, ty);
					}
				}
			}

			// TODO use canvas.setPixels(...,ByteArray)
			//decide whether to draw a pixel
			for (tx = 0; tx < width; tx++) {
				for (ty = 0; ty < height; ty++) {
					var sum:Number = sums[tx + ty * width];
					if (sum >= minThreshold && sum <= maxThreshold) {
						_framePixels.setPixel32(tx, ty, 0xffffffff);
					}
				}
			}
		}
	}

}