package particles {
	import utils.Vector2;
	/**
	 * ...
	 * @author Saladin
	 */
	public class ParticleEmitter {
		//private var randGen:Rndm;
		private var time:Number;
		
		//{ Properties

		private var position:Vector2 = new Vector2;
		public function get Position():Vector2 { return position; }
		public function set Position(value:Vector2):void { Position.Set(value); }
		
		private var direction:Vector2 = new Vector2;
		public function get Direction():Vector2 { return direction; }
		public function set Direction(value:Vector2):void {
			direction.Set(value).Normalize();
		}

		/** distribution along the direction */
		public var Distribution:Number;

		/** minimum initial velocity of the particles */
		public var VelocityMin:Number;

		/** maximum initial velocity of the particles */
		public var VelocityMax:Number;

		/** frequency in particles per second */
		public var Frequency:Number;

		public var ParticleMass:Number;

		public var Enabled:Boolean;

		//}
		
		//{ Constructor
		
		public function ParticleEmitter() {
			//randGen = new Rndm();
			time = 0;
			VelocityMin = 0;
			VelocityMax = VelocityMin;
			Direction = Vector2.UnitY;
			Distribution = 1;
			Frequency = 128;
			ParticleMass = 1;
			Enabled = true;
		}
		
		//}
		
		//{ Methods

		/**
		 * Emits Particles
		 * @param	dTime The delta time.
		 */
		public function Emit(dTime:Number):FluidParticles {
			var Particles:FluidParticles = new FluidParticles();
			var oldPos:Vector2 = new Vector2;
			var vel:Vector2 = new Vector2;
			
			if (this.Enabled) {
				// Calc particle count based on frequency
				time += dTime;
				var nParts:int = int(this.Frequency * time);
				if (nParts > 0) {
					// Create Particles
					for (var i:uint = 0; i < nParts; i++) {
						// Calc velocity based on the distribution along the normalized direction
						//var dist:Number = randGen.random() * this.Distribution - this.Distribution * 0.5;
						var dist:Number = Math.random() * this.Distribution - this.Distribution * 0.5;
						var normal:Vector2 = this.Direction.PerpendicularRight;
						normal.Mul(dist);
						//var vel:Vector2 = Vector2.Add(this.Direction, normal);
						vel.Set(this.Direction).Inc(normal);
						vel.Normalize();
						//var velLen:Number = randGen.float(velocityMin, velocityMax);
						var velLen:Number = Math.random() * (VelocityMax - VelocityMin) + VelocityMin;
						vel.Mul(velLen);

						// Calc Oldpos (for right velocity) using simple euler
						// oldPos = this.Position - vel * m_time;
						//var oldPos:Vector2 = Vector2.Sub(this.Position, Vector2.Mult(vel, time));
						//Vector2.sub(this.Position, Vector2.Mult(vel, time), oldPos);
						oldPos.Set(this.Position).Dec(Vector2.mult(vel, time));

						Particles.List[i] = new FluidParticle(Position, oldPos, ParticleMass, vel);
					}
			
					// Reset time
					time = 0.0;
				}
			}
			
			return Particles;
		}

		//}

	}

}