package particles {
	/**
	 * ...
	 * @author Saladin
	 */
	public class ParticleSystem{
		//{ Members

		private var wasMaxReached:Boolean;

		//}
		
		//{ Properties

		private var _particles:FluidParticles;
		public function get Particles():FluidParticles { return _particles; }

		private var emitters:Vector.<ParticleEmitter>;
		public function get Emitters():Vector.<ParticleEmitter> { return emitters; }

		public function get HasEmitters():Boolean { return emitters != null && emitters.length > 0; }

		private var consumers:Vector.<ParticleConsumer>;
		public function get Consumers():Vector.<ParticleConsumer> { return consumers; }

		public function get HasConsumers():Boolean { return consumers != null && consumers.length > 0; }
		
		public var MaxLife:int;

		public var MaxParticles:int;
		
		public var DoRebirth:Boolean;
		
		public var TestMaxLife:Boolean;

		//}

		//{ Constructor
		
		public function ParticleSystem() {
         emitters = new Vector.<ParticleEmitter>();
         consumers = new Vector.<ParticleConsumer>();
         MaxLife = 1024;
         MaxParticles = 4096;
         DoRebirth = true;
         TestMaxLife = true;
         Reset();
		}
		
		//}
		
		//{ Methods

		/**
		 * Resets this instance.
		 */
		private function Reset():void {
			_particles = new FluidParticles();
			wasMaxReached = false;
		}

		/// <summary>
		/// Updates the particles (remove, emit, ...).
		/// </summary>
		/// <param name="dTime">The delta time.</param>
		public function Update(dTime:Number):FluidParticles {
			var emitted:FluidParticles = null;
			var consumer:ParticleConsumer;
			var emitter:ParticleEmitter;

			// Consume particles in a certain range
			if (this.HasConsumers) {
				for each (consumer in consumers) {
					consumer.Consume(this.Particles);
				}
			}

			// Remove old particles
			if (this.TestMaxLife) {
				for (var i:int = Particles.Count - 1; i >= 0; i--) {
					if (this.Particles.List[i].Life >= this.MaxLife) {
						this.Particles.List.splice(i, 1);
					}
				}
			}

			// Check if emit is allowed
			if (wasMaxReached && !this.DoRebirth) {
				// NOP
			} else if (this.Particles.Count < this.MaxParticles) {
				if (this.HasEmitters) {
					// Emit new particles
					for each (emitter in this.Emitters) {
						// TODO ne devrait il pas merge tous les emitted particles ?!!
						// if (emitted) emitter.AddRange(emitter.Emit(dTime))
						emitted = emitter.Emit(dTime);
						this.Particles.AddRange(emitted);
					}
				}
			} else {
				wasMaxReached = true;
			}

			return emitted;
		}

		//}
	}

}