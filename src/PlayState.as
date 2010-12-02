package
{
	import bounds.OBB;
	import org.flixel.*;
	import particles.ParticleEmitter;
	import particles.ParticleSystem;
	import renderers.MBRenderer0;
	import renderers.MBRenderer1;
	import renderers.MBRenderer2;
	import renderers.Renderer;
	import renderers.SbatRenderer;
	import simulation.CollisionResolver;
	import simulation.SPHSimulation;
	import utils.Vector2;
	
	public class PlayState extends FlxState
	{
		//{ Members
		private var update_interval:Number = Constants.DELTA_TIME_SEC;
		private var elapsed:Number = 0;

		// Sim
		private var fluidSim:SPHSimulation;
		private var gravity:Vector2;
		private var particleSystem:ParticleSystem;

		// BoundingVolumes
		private var collisionSolver:CollisionResolver;

		private var _monitors_display:FlxText;
		
		private var _renderers:Vector.<Renderer>;
		private var _curRenderer:int = 3;

		//}
		
		//{ Initialization

		override public function create():void {
			add(_monitors_display = new FlxText(FlxG.width - 200, FlxG.height - 300, 200));
			_monitors_display.alpha = 0.5;
			_monitors_display.setFormat("system", 8, 0xffffff, "right");
			_monitors_display.color = 0xff0000;

			_renderers = new Vector.<Renderer>();
			_renderers[0] = new MBRenderer0(FlxG.width, FlxG.height, 32, 1.0, 0.4, 0.8);
			_renderers[1] = new MBRenderer1(FlxG.width, FlxG.height);
			_renderers[2] = new MBRenderer2(FlxG.width, FlxG.height);
			_renderers[3] = new SbatRenderer(FlxG.width, FlxG.height, 20);

			initSimulation();
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
			emitter.VelocityMin = 1;// Constants.PARTICLE_MASS * 0.30;
			emitter.VelocityMax = 1.5;// Constants.PARTICLE_MASS * 0.35;
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

			if (FlxG.keys.pressed("ONE")) _curRenderer = 0;
			else if (FlxG.keys.pressed("TWO")) _curRenderer = 1;
			else if (FlxG.keys.pressed("THREE")) _curRenderer = 2;
			else if (FlxG.keys.pressed("FOUR")) _curRenderer = 3;

			if (_curRenderer == 3) {
				var sbatr:SbatRenderer = _renderers[3] as SbatRenderer;
				if (FlxG.keys.justPressed("F")) sbatr.filter++;
				if (sbatr.filter > 2) sbatr.filter = 0;
			}
			simulate();
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

		//}
		
		//{ Drawing
		
		override public function render():void {
			_renderers[_curRenderer].drawParticles(particleSystem.Particles);
			_renderers[_curRenderer].render();

			super.render();
		}

		override public function postProcess():void {
			_monitors_display.text = FlxFluids.Monitors.toString();
			super.postProcess();
		}

		//}

	}

}

