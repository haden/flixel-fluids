package particles {
	import flash.geom.Rectangle;
	import particles.FluidParticles;
	import utils.Vector2;
	/**
	 * Implementation of a list of Fluid Particles
	 * @author Saladin
	 */
	public class FluidParticles {
		
		//{ Properties
		public function get Count():uint { return List.length; }
		
		public var list:Vector.<FluidParticle>;
		public function get List():Vector.<FluidParticle> { return list; }
		
		public function FluidParticles(size:uint = 0) {
			list = new Vector.<FluidParticle>(size);
		}
		
		//}
		
		//{ Methods

		public function AddRange(Particles:FluidParticles):void {
			var p:FluidParticle;
			for each (p in Particles.List) {
				list.push(p);
			}
		}

		/**
		 * Create particles evenly spaced on ground of the boundary
		 */
		public static function Create(nParticles:int, cellSpace:Number, domain:Rectangle, particleMass:Number):FluidParticles {
			var Particles:FluidParticles = new FluidParticles(nParticles);
			// Init. Particle positions
			var x0:Number = domain.x + cellSpace;
			var x:Number = x0;
			var y:Number = domain.y;
			for (var i:uint = 0; i < nParticles; i++)
			{
				if (x == x0) {
					y += cellSpace;
				}
				var pos:Vector2 = new Vector2(x, y);
				Particles.List[i] = new FluidParticle(pos, pos, particleMass);
				x = x + ((cellSpace < domain.width) ? (x + cellSpace) : x0);
			}

			return Particles;
		}

      //}

	}

}