package particles {
	import utils.Vector2;
	/**
	 * A particle consumer, which removes particles in a certain radius
	 * 
	 * @author Saladin
	 */
	public class ParticleConsumer{

		//{ Properties

		private var position:Vector2 = new Vector2;
		public function get Position():Vector2 { return position; }
		public function set Position(value:Vector2):void { position.Set(value); }

		/**
		 * Internally the squared radius is stored, 
		 * so be aware of calling the getter to often (uses Math.Sqrt(m_radiusSquared)).
		 */
		private var radiusSquared:Number;
		public function get Radius():Number { 
			return Math.sqrt(radiusSquared); 
		}
		public function set Radius(value:Number):void {
			radiusSquared = value * value;
		}
		
		private var enabled:Boolean;
		public function get Enabled():Boolean { return enabled; }
		public function set Enabled(value:Boolean):void { enabled = value; }

		//}

		//{ Constructor
		
		public function ParticleConsumer() {
			Radius = 1;
			enabled = true;
		}
		
		//}
		
		//{ Methods

		/**
		 * Consumes the specified particles if they are in the radius
		 * @param	particles The particles.
		 */
		public function Consume(Particles:FluidParticles):void {
			var ps:Vector.<FluidParticle> = Particles.List;
			var i:uint;
			
			if (this.Enabled) {
				for (i = ps.length - 1; i >= 0; i--) {
					var distSq:Number = Vector2.sub(ps[i].Position, this.Position).LengthSquared;
					if (distSq < radiusSquared) {
						ps.splice(i, 1);
					}
				}
			}
		}

		//}
		
	}

}