package  {
	import flash.display.Sprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import pvfs.Config;
	import pvfs.Material;
	import pvfs.Particle;
	import renderers.MBRenderer0;
	import renderers.Renderer;
	import renderers.SbatRenderer;
	import org.flixel.FlxG;
	import renderers.SpriteRenderer;
	import org.flixel.FlxU;
	
	public class PVFSPlayState extends FlxState {
		//{ members
		private var emit:int;
        private var iterations:int;
        
		private var materialTxt:FlxText;
		private var materials:Vector.<Material>;
        private var mode:int;
		
        private var particles:Vector.<Particle> = new Vector.<Particle>();

		private var _renderers:Vector.<Renderer>;
		private var _current:int = 1;

		private var _monitors_display:FlxText;
		//}
		
		//{ Initialization
		override public function create():void {
			add(_monitors_display = new FlxText(FlxG.width - 200, FlxG.height - 300, 200));
			_monitors_display.alpha = 0.5;
			_monitors_display.setFormat("system", 8, 0xffffff, "right");
			_monitors_display.color = 0xff0000;

			add(materialTxt = new FlxText(10, 10, 200));
			materialTxt.setFormat(null, 12);
			
            Particle.InitGrid(Config.Default.particlesize, Config.Default.width, Config.Default.height);
			this.iterations = Config.Default.itrsperframe - 1;
			initMaterials();
			this.emit = Config.Default.emitnumber;

			_renderers = new Vector.<Renderer>();
			_renderers[0] = new SpriteRenderer(FlxG.width, FlxG.height, materials);
			_renderers[1] = new MBRenderer0(FlxG.width, FlxG.height, Config.Default.rendersize, 1.0, 0.2, 0.8, materials);
			//renderer = new SpriteRenderer(FlxG.width, FlxG.height);
			
			for (var x:uint = 0; x < 40; x++) {
				for (var y:uint = 0; y < 40; y++) {
					var dx:Number = x / 20.0;
					var dy:Number = y / 20.0;
					particles.push(new Particle(dx * 200 + 100 + FlxU.random()*5-10, dy * 200 + 50+ FlxU.random()*5-10, materials[0], 0, false));
				}
			 }

			super.create();
		}
				
		private function initMaterials():void {
			materials = new Vector.<Material>();
			materials.push(new Material("Water", 30, 30, .25, 0, .3, 10, 0, 1, Renderer.getRGBf(0, 0.5, 1)));
			materials.push(new Material("Oil", 30, 30, .05, 0, .3, 10, 0, .2, Renderer.getRGBf(0, 0, 0)));
			materials.push(new Material("Heavy", 20, 20, .5, 0, .3, 10, 0, 2, Renderer.getRGBf(1, 0, 0)));
			materials.push(new Material("Tensile", 10, 20, 3, 0, .3, 10, 0, 1, Renderer.getRGBf(.8, .8, .1)));
			materials.push(new Material("Wall", 10, 20, 3, 0, .3, 10, 0, 1, Renderer.getRGBf(.5, .5, .5)));
			materials.push(new Material("Goo", 20, 20, .5, 10, .6, .6, .2, .6, Renderer.getRGBf(.5, 0, .5)));
			materials.push(new Material("Jello", 10, 10, 1, 30, .5, 1, .01, 1.5, Renderer.getRGBf(0, 1, 0)));
			materials.push(new Material("Elastic", 10, 10, 1, 60, .5, 0, 0, 1.5, Renderer.getRGBf(1, 1, 0)));
			materials.push(new Material("GlassShards", 5, 5, -10, 20, .5, 1, .01, 1, Renderer.getRGBf(.2, .8, 1)));
		}
		//}
		
		//{ Update
		protected function clear():void {
			this.particles.splice(0, particles.length);
			Particle.InitGrid(Config.Default.particlesize, Config.Default.width, Config.Default.height);
			Particle.nparts = 0;
			Particle.frame = 0;
		}
		
		protected function updateMouse():void {
			Particle.lmb = Particle.mmb = Particle.rmb = false;
			if (FlxG.mouse.pressed()) {
				if (FlxG.keys.ALT) Particle.mmb = true;
				else if (FlxG.keys.CONTROL) Particle.rmb = true;
				else Particle.lmb = true;
			}
			Particle.mx = FlxG.mouse.x;
			Particle.my = FlxG.mouse.y;
		}

		protected function updateMaterial():void {
			if (FlxG.keys.justPressed("LEFT")) this.mode--;
			else if (FlxG.keys.justPressed("RIGHT")) this.mode++;

			if (this.mode == this.materials.length) this.mode = 0;
			else if (this.mode == -1) this.mode = materials.length - 1;
		}
		
		protected function updateDrawing():void {
			var m:Material = materials[mode];
			var radius:Number, angle:Number;
			var mx:int = FlxG.mouse.x;
			var my:int = FlxG.mouse.y;
			
			if (FlxG.keys.SPACE) {
				Particle.lmb = false;
				Particle.mmb = false;
				Particle.rmb = false;
				Particle.emit = true;
				if (FlxG.mouse.pressed() && mx > Particle.left && mx < Particle.right && my > Particle.top && my < Particle.bottom) {
					var fixed:Boolean = FlxG.keys.F;
					for (var j:int = 0; j < this.emit; j++) {
						radius = Math.random() * Particle.rad;
						angle = Math.random() * 2. * Math.PI;
						this.particles.push(new Particle(mx + (Math.cos(angle) * radius), my + (Math.sin(angle) * radius), m, this.mode, fixed));
					}
				}
			} else {
				Particle.emit = false;
			}
		}

		protected function updateParticles():void {
			var particle:Particle;
			
FlxFluids.Monitors.mark("pvfs.particles.update");
			for each (particle in particles) { particle.Update(); }
FlxFluids.Monitors.addTimer("pvfs.particles.update", true);

			Particle.frame++;
			for (var i:int = 1; i < this.iterations; i++) {
FlxFluids.Monitors.mark("pvfs.particles.update");
				for each (particle in particles) { particle.Update(); }
FlxFluids.Monitors.addTimer("pvfs.particles.update", true);
				Particle.frame++;
FlxFluids.Monitors.mark("pvfs.particles.density");
				for each (particle in particles) { particle.Density(); }
FlxFluids.Monitors.addTimer("pvfs.particles.density", true);
FlxFluids.Monitors.mark("pvfs.particles.pressure");
				for each (particle in particles) { particle.Pressure(); }
FlxFluids.Monitors.addTimer("pvfs.particles.pressure", true);
FlxFluids.Monitors.mark("pvfs.particles.relax");
				for each (particle in particles) { particle.Relax(); }
FlxFluids.Monitors.addTimer("pvfs.particles.relax", true);
			}
			
FlxFluids.Monitors.cumul("pvfs.particles.update");
FlxFluids.Monitors.cumul("pvfs.particles.density");
FlxFluids.Monitors.cumul("pvfs.particles.pressure");
FlxFluids.Monitors.cumul("pvfs.particles.relax");
		}

		override public function update():void {
			if (FlxG.keys.pressed("ONE")) _current = 0;
			else if (FlxG.keys.pressed("TWO")) _current = 1;

			if (FlxG.keys.justPressed("C")) clear();

			updateMouse();
			updateMaterial();
			
			if (FlxG.keys.justPressed("DOWN")) this.iterations--;
			if (this.iterations == -1) this.iterations = 0;

			updateDrawing();
			updateParticles();
			
			materialTxt.text = materials[mode].name;
			
			super.update();
		}

		//}

		//{ Render
		override public function render():void {
			var renderer:Renderer = _renderers[_current];
			
			renderer.beginDraw();
			for each (var particle:Particle in particles) {
				renderer.drawParticleM(particle.posX, particle.posY, particle.phase);
			}
			renderer.endDraw();
			renderer.render();

			super.render();
		}

		override public function postProcess():void {
			_monitors_display.text = FlxFluids.Monitors.toString();
			super.postProcess();
		}
		
		//}
	}

}