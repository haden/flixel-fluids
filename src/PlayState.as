package
{
	import bounds.OBB;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flx.HakSprite;
	import org.flixel.*;
	import org.flixel.data.FlxConsole;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import particles.ParticleEmitter;
	import particles.ParticleSystem;
	import simulation.CollisionResolver;
	import simulation.SPHSimulation;
	import utils.Vector2;
	import flash.utils.getTimer;

	public class PlayState extends FlxState
	{
		static private const P_RADIUS:int = 128;
		
		//{ Members
		
		private var update_interval:Number = Constants.DELTA_TIME_SEC;
		private var elapsed:Number = 0;

		// Sim
		private var fluidSim:SPHSimulation;
		private var gravity:Vector2;
		private var particleSystem:ParticleSystem;

		// BoundingVolumes
		private var collisionSolver:CollisionResolver;
		
		private var bitmapData:BitmapData;
		private var sprite:HakSprite;
		private var mbValues:Vector.<int>;
		private var pSprite:FlxSprite;

		private var _monitors_display:FlxText;
		
		//}
		
		//{ Initialization
		
		public function PlayState() {
			//this.console = FlxFluids.Instance.console;
		}
		
		override public function create():void {
			sprite = new HakSprite;
			sprite.createGraphic(FlxG.width, FlxG.height);
			add(sprite);
			
			add(_monitors_display = new FlxText(FlxG.width - 200, FlxG.height - 300, 200));
			_monitors_display.alpha = 0.5;
			_monitors_display.setFormat("system", 8, 0xffffff, "right");
			
			bitmapData = sprite.pixels;
			mbValues = new Vector.<int>(FlxG.width * FlxG.height, true);

			initPSprite(P_RADIUS, 1.0, 0.4, 0.8);
			
			initSimulation();
		}
		
		private function initPSprite(texSize:int, energy:Number, fallOff:Number, energyThreshold:Number):void {
			pSprite = new FlxSprite().createGraphic(texSize, texSize);
			var bitmap:BitmapData = pSprite.pixels;
			
			var center:int = texSize / 2;
			var centerHalfSq:Number = (center / 2.0) * fallOff;
			centerHalfSq = centerHalfSq * centerHalfSq;
			var threshMax:Number = energyThreshold - (energyThreshold * 0.1);
			
			bitmap.lock();
			var dist:Vector2 = new Vector2;
			for (var x:uint = 0; x < texSize; x++) {
				for (var y:uint = 0; y < texSize; y++) {
					// calculate the squared distance from the center of the metaball
					dist.x = x - center;
					dist.y = y - center;
					// Use gaussian as falloff function: e^-(d / (center/2))^2*energy
					var en:Number = Math.exp( -dist.LengthSquared / centerHalfSq) * energy;
					
					// clamp
					if (en < 0) en = 0;
					else if (en > threshMax) en = threshMax;
					
					bitmap.setPixel32(x, y, getARGB(int(en * 255.0), 0, 255, 255));
				}
			}
			bitmap.unlock();
		}
		
		public static function getARGB(alpha:uint, red : uint , green : uint , blue :uint):uint {
			return (Math.min(alpha, 255) << 24 | Math.min(red, 255) << 16 | Math.min(green, 255) << 8 | Math.min(blue, 255));
		}

		private function initSimulation():void {
			gravity = Vector2.mult(Constants.GRAVITY, Constants.PARTICLE_MASS);
			fluidSim = new SPHSimulation(Constants.CELL_SPACE, Constants.SIM_DOMAIN, 1000, 30);

			initCollisionSolver();
			initParticleSystem();
		}

		private function initCollisionSolver():void {
			collisionSolver = new CollisionResolver();
			collisionSolver.BVs[0] = new OBB(
				new Vector2(Constants.SIM_DOMAIN.width / 2, Constants.SIM_DOMAIN.height / 2),
				new Vector2(Constants.SIM_DOMAIN.width / 6 , Constants.SIM_DOMAIN.height / 30)
			);

			collisionSolver.Bounciness = 0.2;
			collisionSolver.Friction = 0.01;
		}
		
		private function initParticleSystem():void {
			var freq:Number = 20;
			var maxPart:int = 500;
			particleSystem = new ParticleSystem();
			
			var emitter:ParticleEmitter = new ParticleEmitter;
			emitter.Position = new Vector2(Constants.SIM_DOMAIN.x, Constants.SIM_DOMAIN.y);
			emitter.VelocityMin = Constants.PARTICLE_MASS * 0.30;
			emitter.VelocityMax = Constants.PARTICLE_MASS * 0.35;
			emitter.Direction = new Vector2(0.8, -0.25);
			emitter.Distribution = Constants.SIM_DOMAIN.width * 0.0001;
			emitter.Frequency = freq;
			emitter.ParticleMass = Constants.PARTICLE_MASS;

			particleSystem.Emitters[0] = emitter;
			
			particleSystem.MaxParticles = maxPart;
			particleSystem.MaxLife = int(maxPart / freq / Constants.DELTA_TIME_SEC);
			particleSystem.TestMaxLife = false;
		}

		//}
		
		//{ Update
		
		override public function update():void {
			simulate();
		}

		override public function postProcess():void {
			_monitors_display.text = FlxFluids.Monitors.toString();
			super.postProcess();
		}
		
		private function simulate():void {
			//elapsed += FlxG.elapsed;
			//
			//while (elapsed > update_interval) {
				//updateSim();
				//elapsed -= update_interval;
			 // }
			updateSim();
		}

		private function updateSim():void {
			FlxFluids.Monitors.mark("update.collision_solve");
			
			// Solve collisions only for obbs (not particles)
			collisionSolver.Solve();

			FlxFluids.Monitors.addTimer("update.collision_solve");
			FlxFluids.Monitors.mark("update.update");
			
			// Update particle system
			particleSystem.Update(Constants.DELTA_TIME_SEC);

			FlxFluids.Monitors.addTimer("update.update");
			FlxFluids.Monitors.mark("update.collision_solveP");
			
			// Interaction handling
			//AddInteractionForces();

			// Solve collisions only for particles
			collisionSolver.SolveP(particleSystem.Particles);

			FlxFluids.Monitors.addTimer("update.collision_solveP");
			FlxFluids.Monitors.mark("update.calculate");

			// Do simulation
			fluidSim.Calculate(particleSystem.Particles, gravity, Constants.DELTA_TIME_SEC);

			FlxFluids.Monitors.addTimer("update.calculate");
		}

		//}
		
		//{ Drawing
		
		override public function render():void {
			drawParticles(particleSystem.Particles);

			super.render();
		}
		
		private function drawParticles(Particles:FluidParticles):void {
			var pos:FlxPoint;
			
			sprite.fill(0x0);
			
			for each (var particle:FluidParticle in Particles.List) {
				pos = domainToScreen(particle.Position);
				sprite.draw(pSprite, pos.x - P_RADIUS / 2, pos.y - P_RADIUS / 2);
			}
		}
		
		private function drawMetaballs(Particles:FluidParticles):void {
			const radius:Number = 10000;
			const maxRadius:uint = 10; // pour chaque particle 20x20 pixels pour la metaball
			var x:int, y:int, i:int;
			
			// commencer par vider les valeurs precedentes
			for (i = 0; i < mbValues.length; i++) {
				mbValues[i] = 0;
			}
			
			// mettre à jour mbValues
			for each (var particle:FluidParticle in Particles.List) {
				var point:FlxPoint = domainToScreen(particle.Position);
				var px:int = int(point.x);
				var py:int = int(point.y);
				for (var xoff:int = -maxRadius; xoff <= maxRadius; xoff++) {
					for (var yoff:int = -maxRadius; yoff <= maxRadius; yoff++) {
						x = px + xoff;
						y = py + yoff;
						
						if (x > 0 && x < FlxG.width && y > 0 && y < FlxG.height) {
							mbValues[x + y * FlxG.width] += radius / (1 + getPixelValue(point, x, y));
						}
					}
				}
			}
			
			// dessiner les metaballs
			bitmapData.lock();
			for (x = 0; x < FlxG.width;x++) {
				for (y = 0; y < FlxG.height; y++) {
					bitmapData.setPixel(x, y, convertRGBColor(mbValues[x + y * FlxG.width]));
				}
			}
			bitmapData.unlock();
			//sprite.pixels = bitmapData;
			//sprite.fill(0xffffff);
			sprite.frame = 0;
		}

		private function domainToScreen(vecpos:Vector2):FlxPoint {
			return new FlxPoint(
				(vecpos.x - Constants.SIM_DOMAIN.x) * FlxG.width / Constants.SIM_DOMAIN.width,
				(vecpos.y -Constants.SIM_DOMAIN.y) * FlxG.height / Constants.SIM_DOMAIN.height);
		}

		private function getPixelValue(pos:FlxPoint, x:uint, y:uint):Number {
			var py:Number = int((pos.y - y) * (pos.y - y));
			var px:Number = int((pos.x - x) * (pos.x - x));
			return px + py;
		}
		
		private function convertRGBColor(pixelsValue:int, count:int = 1):Number {
			var rgb:int;
			switch(count% 6) {
				case 0:    rgb = getRGB(0, pixelsValue/2 , pixelsValue);                    break;
				case 1:    rgb = getRGB( pixelsValue, pixelsValue / 2, 0);     	            break;
				case 2:    rgb = getRGB( pixelsValue, pixelsValue/3, pixelsValue/2);        break;	
				case 3:    rgb = getRGB( pixelsValue/2, pixelsValue*0.8, pixelsValue/5);    break;
				case 4:    rgb = getRGB( pixelsValue*0.8, pixelsValue/4, pixelsValue/7);    break;
				case 5:    rgb = getRGB(pixelsValue/6, pixelsValue/3 , pixelsValue*0.8);    break;
			}
			return rgb;
		}
		
		public static function getRGB(red : uint , green : uint , blue :uint):uint {
			return (Math.min(red, 255)<<16 | Math.min(green, 255)<< 8 | Math.min(blue, 255));
		}

		//}

	}

}

