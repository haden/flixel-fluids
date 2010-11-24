package {
	import bounds.BoundingVolume;
	import bounds.OBB;
	import bounds.PointVolume;
	import com.gskinner.utils.Rndm;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import particles.ParticleConsumer;
	import particles.ParticleEmitter;
	import particles.ParticleSystem;
	import simulation.CollisionResolver;
	import simulation.IndexGrid;
	import simulation.solvers.Verlet;
	import simulation.SPHSimulation;
	import utils.Vector2;
	import flash.utils.getTimer;
	
	
	/**
	 * ...
	 * @author Saladin
	 */
	public class Main extends Sprite {
		static private const WIDTH:uint = 512;
		static private const HEIGHT:uint = 512;
		
		//{ Members

		private const updates_per_second:uint = 200;
		private var update_interval:int = 1000 / updates_per_second;
		private var prev_time:int;
		
		// Sim
		private var fluidSim:SPHSimulation;
		private var gravity:Vector2;
		private var particleSystem:ParticleSystem;
		private var pause:Boolean;

		// BoundingVolumes
		private var collisionSolver:CollisionResolver;

		// Blobs
		private var bitmapData:BitmapData;
		private var bitmap:Bitmap;
		private var drawMB:Boolean = false;
		private var mbValues:Vector.<int>;
		//}

		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);

			bitmapData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
			bitmap = new Bitmap(bitmapData, "auto", false);
			mbValues = new Vector.<int>(WIDTH * HEIGHT, true);

			if (drawMB) addChild(bitmap);

			addChild(new FpsTracker);
			addEventListener(Event.ENTER_FRAME, onFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
			initSimulation();
		}
		
		private function initSimulation():void {
			gravity = Vector2.Mult(Constants.GRAVITY, Constants.PARTICLE_MASS);
			fluidSim = new SPHSimulation(Constants.CELL_SPACE, Constants.SIM_DOMAIN);

			initCollisionSolver();
			initParticleSystem();
			
			prev_time = getTimer();
		}

		private function onMouseUp(e:MouseEvent):void {
			drawMB = !drawMB;
			if (drawMB) {
				addChild(bitmap);
			} else {
				//prev_time = getTimer(); // ignorer le temps perdu dans la pause
				removeChild(bitmap);
			}
		}

		private function updateSim():void {
			// Solve collisions only for obbs (not particles)
			collisionSolver.Solve();

			// Update particle system
			particleSystem.Update(Constants.DELTA_TIME_SEC);

			// Interaction handling
			//AddInteractionForces();

			// Solve collisions only for particles
			collisionSolver.SolveP(particleSystem.Particles);

			// Do simulation
			fluidSim.Calculate(particleSystem.Particles, gravity, Constants.DELTA_TIME_SEC);
		}
		
		private function simulate():void {
			var cur_time:int = getTimer();
			var elapsed:int = cur_time - prev_time;
			
			while (elapsed > update_interval) {
				updateSim();
				elapsed -= update_interval;
			}
			
			prev_time = getTimer() - elapsed; // utiliser getTimer() pour prendre en compte la durée de la frame courante
		}
		
		private function onFrame(e:Event):void {
			simulate();
			//updateSim();
			
			if (drawMB) {
				drawMetaballs(particleSystem.Particles);
			} else {
				//simulate();
				drawBVs();
			}
		}
		
		private function drawMetaballs(Particles:FluidParticles):void {
			const radius:Number = 10000;
			const maxRadius:uint = 10; // pour chaque particle 5x5 pixels pour la metaball
			var x:int, y:int, i:int;
			
			// commencer par vider les valeurs precedentes
			for (i = 0; i < WIDTH*HEIGHT; i++) {
				mbValues[i] = 0;
			}
			
			// mettre à jour mbValues
			for each (var particle:FluidParticle in Particles.List) {
				var point:Point = domainToScreen(particle.Position);
				var px:int = int(point.x);
				var py:int = int(point.y);
				for (var xoff:int = -maxRadius; xoff <= maxRadius; xoff++) {
					for (var yoff:int = -maxRadius; yoff <= maxRadius; yoff++) {
						x = px + xoff;
						y = py + yoff;
						
						if (x > 0 && x < WIDTH && y > 0 && y < HEIGHT) {
							mbValues[x+y*WIDTH] += radius / (1 + getPixelValue(point, x, y));
						}
					}
				}
			}
			
			// dessiner les metaballs
			bitmapData.lock();
			for (x = 0; x < WIDTH;x++) {
				for (y = 0; y < HEIGHT; y++) {
					bitmapData.setPixel(x, y, convertRGBColor(mbValues[x + y * WIDTH]));
				}
			}
			bitmapData.unlock();
		}
		
		private function domainToScreen(vecpos:Vector2):Point {
			return new Point(
				(vecpos.x - Constants.SIM_DOMAIN.x) * WIDTH / Constants.SIM_DOMAIN.width,
				(vecpos.y -Constants.SIM_DOMAIN.y) * HEIGHT / Constants.SIM_DOMAIN.height);
		}
		
		private function getPixelValue(pos:Point, x:uint, y:uint):Number {
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

		private function drawBVs():void {
			graphics.clear();
			graphics.beginFill(0xCC2200);
			for each (var particle:FluidParticle in particleSystem.Particles.List) {
				particle.BV.Draw(graphics, WIDTH, HEIGHT);
			}
			graphics.endFill();
			
			for each (var bv:BoundingVolume in collisionSolver.BVs) {
				bv.Draw(graphics, WIDTH, HEIGHT);
			}
		}

		private function initCollisionSolver():void {
			collisionSolver = new CollisionResolver();
			collisionSolver.BVs[0] = new OBB(
				new Vector2(Constants.SIM_DOMAIN.width / 3, Constants.SIM_DOMAIN.height / 2),
				new Vector2(Constants.SIM_DOMAIN.width / 6 , Constants.SIM_DOMAIN.height / 30)
			);

			collisionSolver.Bounciness = 0.2;
			collisionSolver.Friction = 0.01;
		}
		
		private function initParticleSystem():void {
			var freq:Number = 30;
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
	}
}
