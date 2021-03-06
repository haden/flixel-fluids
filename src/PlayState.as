package
{
	import bounds.OBB;
	import org.flixel.*;
	import particles.FluidParticle;
	import particles.ParticleEmitter;
	import particles.ParticleSystem;
	import renderers.MBRenderer0;
	import renderers.Renderer;
	import renderers.SbatRenderer;
	import simulation.CollisionResolver;
	import simulation.simulators.Simulation;
	import simulation.simulators.SPHSimulation;
	import utils.Vector2;
	
	public class PlayState extends FlxState
	{
		//{ Members
		private var update_interval:Number = Constants.DELTA_TIME_SEC;
		private var elapsed:Number = 0;

		// Sim
		private var fluidSim:Simulation;
		private var gravity:Vector2;
		private var particleSystem:ParticleSystem;

		// BoundingVolumes
		private var collisionSolver:CollisionResolver;

		private var _monitors_display:FlxText;
		
		private var _renderers:Vector.<Renderer>;
		private var _curRenderer:int = 1;

		//}
		
		//{ Initialization

		override public function create():void {
			add(_monitors_display = new FlxText(FlxG.width - 200, FlxG.height - 300, 200));
			_monitors_display.alpha = 0.5;
			_monitors_display.setFormat("system", 8, 0xffffff, "right");
			_monitors_display.color = 0xff0000;

			_renderers = new Vector.<Renderer>();
			_renderers[0] = new MBRenderer0(FlxG.width, FlxG.height, 32, 1.0, 0.4, 0.8);
			_renderers[1] = new SbatRenderer(FlxG.width, FlxG.height, 10);

			initSimulation();
		}

		private function initSimulation():void {
			gravity = Vector2.mult(Constants.GRAVITY, Constants.PARTICLE_MASS);
			fluidSim = new SPHSimulation(Constants.CELL_SPACE, Constants.SIM_DOMAIN, 1000, 100);
			//var pvfSim:PVFSimulation = new PVFSimulation(Constants.CELL_SPACE, Constants.SIM_DOMAIN, 1000, 1000);
			//pvfSim.k = 1.0;
			//pvfSim.k_near = 1.0;
			//pvfSim.p_rest = 1.0;
			//pvfSim.R = Constants.CELL_SPACE / 2;
			//pvfSim.gamma = 0.0;
			//pvfSim.beta = 0.0;
			//fluidSim = pvfSim;
			
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
			//for (var x:uint = 0; x < 20; x++) {
				//for (var y:uint = 0; y < 20; y++) {
					//var dx:Number = x / 20.0;
					//var dy:Number = y / 20.0;
					//particleSystem.Particles.List.push(new FluidParticle(
						//new Vector2((dx + 0.5) * Constants.SIM_DOMAIN.width / 5, (dy + 0.5) * Constants.SIM_DOMAIN.height / 5),
						//new Vector2((dx + 0.5) * Constants.SIM_DOMAIN.width / 5, (dy + 0.5) * Constants.SIM_DOMAIN.height / 5),
						//Constants.PARTICLE_MASS/10));
				// }
			// }
			
			particleSystem.MaxParticles = maxPart;
			particleSystem.MaxLife = int(maxPart / freq / Constants.DELTA_TIME_SEC);
			particleSystem.TestMaxLife = false;
		}

		//}
		
		//{ Update
		
		override public function update():void {

			if (FlxG.keys.pressed("ONE")) _curRenderer = 0;
			else if (FlxG.keys.pressed("TWO")) _curRenderer = 1;

			if (_curRenderer == 1) {
				var sbatr:SbatRenderer = _renderers[1] as SbatRenderer;
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
			//for (var i:int = 0; i < 10; i++) updateSim();
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
			_renderers[_curRenderer].beginDraw();
			for each (var particle:FluidParticle in particleSystem.Particles.List) {
				_renderers[_curRenderer].drawParticle(xToScreen(particle.position.x), yToScreen(particle.position.y), 0xffffff);
			}
			_renderers[_curRenderer].endDraw();
			_renderers[_curRenderer].render();

			super.render();
		}

		protected function xToScreen(x:Number):Number {
			return (x - Constants.SIM_DOMAIN.x) * FlxG.width / Constants.SIM_DOMAIN.width;
		}

		protected function yToScreen(y:Number):Number {
			return (y - Constants.SIM_DOMAIN.y) * FlxG.height / Constants.SIM_DOMAIN.height;
		}

		override public function postProcess():void {
			_monitors_display.text = FlxFluids.Monitors.toString();
			super.postProcess();
		}

		//}

	}

}

