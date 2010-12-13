package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.filters.BlurFilter;
	import flash.utils.Dictionary;
	import pvfs.Material;
	import pvfs.Particle;
	import pvfs.Config;
	import renderers.Renderer;
	
	public class PVFS extends MovieClip {
		private var emit:int;
        private var iterations:int;
        
		private var materials:Vector.<Material>;
        private var mode:int;
		
        private var particles:Vector.<Particle> = new Vector.<Particle>();

		private var fluidContainer:Sprite = new Sprite();
		
		private var bitmap:Bitmap = new Bitmap();
		private var bitmapData:BitmapData;
		private var bitmapDataCopy:BitmapData;
		
		private var blurFilter:BlurFilter = new BlurFilter(10, 10, 2);
		
		private var point:Point = new Point(0, 0);
		
        private var pressed:Dictionary = new Dictionary;
        private var pressedprev:Dictionary= new Dictionary;
        private var mx:int = 0;
        private var my:int = 0;
        private var mxprev:int = 0;
        private var myprev:int = 0;

		public function PVFS() {
			// constructor code
            init();
			
			addEventListener('enterFrame', enterFrame);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mousePressed);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyboardUp);
			
			bitmapData = new BitmapData(Config.Default.width, Config.Default.height, true, 0xFF000000);
			bitmapDataCopy = new BitmapData(Config.Default.width, Config.Default.height, false, 0xFF000000);
			
			bitmap = new Bitmap(bitmapData, "auto", true);
			addChild(bitmap);
			
			stage.quality = "HIGH";
			
			pressed["lmb"] = false;
			pressed["rmb"] = false;
			pressed["mmb"] = false;
			pressed["c"] = false;
			pressed["top"] = false;
			pressed["down"] = false;
			pressed["left"] = false;
			pressed["right"] = false;
			pressed["space"] = false;
			
			pressedprev["lbm"] = false;
			pressedprev["rbm"] = false;
			pressedprev["mbm"] = false;
			pressedprev["c"] = false;
			pressedprev["top"] = false;
			pressedprev["down"] = false;
			pressedprev["left"] = false;
			pressedprev["right"] = false;
			pressedprev["space"] = false;
			
		}
		
		public function init() : void {
            Particle.InitGrid(Config.Default.particlesize, Config.Default.width, Config.Default.height);
			this.iterations = Config.Default.itrsperframe - 1;
			initMaterials();
			this.emit = Config.Default.emitnumber;
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
		
		public function enterFrame(e:Event) : void {
			sim();
			
			var g:Graphics = fluidContainer.graphics;
			g.clear();
			//g.lineStyle(1, 0xFFFFFF);
			
			var i:int = 0;
			for each(var p:Particle in particles) {
				i ++;
				
				//g.moveTo(p.x * 4, p.y * 4);
				//g.lineTo((4 * (p.x - p.u) + 1), (4 * (p.y - p.v) + 1));
				g.beginFill(p.c);
				g.drawCircle(p.posX/* * 4*/, p.posY/* * 4*/, Config.Default.particlesize);
				g.endFill();
				
				//g.DrawLine(Pens.White, (4F * p.x), (4F * p.y), (4F * (p.x - p.u)), (4F * (p.y - p.v)));
				//TODO draw the springs
			}
			
			bitmapDataCopy.fillRect(bitmapDataCopy.rect, 0xFFaaaaaa);
			
			bitmapDataCopy.draw(fluidContainer, null, null, null, new Rectangle(0, 0, Config.Default.width, Config.Default.height), false);
			//bitmapDataCopy.applyFilter(bitmapDataCopy, bitmapData.rect, new Point(0, 0), blurFilter);
			
			bitmapData.fillRect(bitmapData.rect, 0xFFaaaaaa);
			bitmapData.copyPixels(bitmapDataCopy, bitmapDataCopy.rect, point);
			//bitmapData.threshold(bitmapDataCopy, bitmapDataCopy.rect, point, ">", 0XFF2b2b2b, 0x55FFFFFF, 0xFFFFFFFF, false);
			//bitmapData.threshold(bitmapDataCopy, bitmapDataCopy.rect, point, ">", 0XFF2c2c2c, 0xBBFFFFFF, 0xFFFFFFFF, false);
			//bitmapData.threshold(bitmapDataCopy, bitmapDataCopy.rect, point, ">", 0XFF2d2d2d, 0xFFFFFFFF, 0xFFFFFFFF, false);
		}
		
		protected function relax():void {
			var particle:Particle;
			//TODO try to put all three operations in the same foreach loop
			for each (particle in particles) { particle.Density(); }
			for each (particle in particles) { particle.Pressure(); }
			for each (particle in particles) { particle.Relax(); }
		}
		
		protected function ispressed(key:String):Boolean {
			return pressed[key] && !pressedprev[key];
		}
		
		public function sim() : void {
			var drag:Boolean = false;
			var mdx:Number = 0.0;
			var mdy:Number = 0.0;
			var particle:Particle;
			
			if (ispressed("c")) {
				this.particles.splice(0, particles.length);
				Particle.InitGrid(Config.Default.particlesize, Config.Default.width, Config.Default.height);
				Particle.nparts = 0;
				Particle.frame = 0;
			}
			Particle.lmb = pressed["lmb"];
			Particle.mmb = pressed["mmb"];
			Particle.rmb = pressed["rmb"];
			Particle.mx = mx;
			Particle.my = my;
			
			if (ispressed("down")) {
				this.iterations--;
			}
			if (this.iterations == -1) {
				this.iterations = 0;
			}
			if (ispressed("left")) {
				this.mode--;
			} else if (ispressed("right")) {
				this.mode++;
			}
			if (this.mode == this.materials.length) {
				this.mode = 0;
			} else if (this.mode == -1) {
				this.mode = materials.length - 1;
			}
			
			var m:Material = materials[mode];
			var radius:Number, angle:Number;
			
			if (pressed["space"]) {
				Particle.lmb = false;
				Particle.mmb = false;
				Particle.rmb = false;
				Particle.emit = true;
				if (pressed["lmb"] && mx > Particle.left && mx < Particle.right && my > Particle.top && my < Particle.bottom) {
					for (var j:int = 0; j < this.emit; j++) {
						radius = Math.random() * Particle.rad;
						angle = Math.random() * 2. * Math.PI;
						particle = new Particle(mx + (Math.cos(angle) * radius), my + (Math.sin(angle) * radius), m, this.mode, false);
						this.particles.push(particle);
					}
				}
				// fixed particle
				if (pressed["right"] && mx > Particle.left && mx < Particle.right && my > Particle.top && my < Particle.bottom) {
					for (var k:int = 0; k < this.emit; k++) {
						radius = Math.random() * Particle.rad;
						angle = Math.random() * 2. * Math.PI;
						this.particles.push(new Particle(mx + ((Math.cos(angle)) * radius), my + ((Math.sin(angle)) * radius), m, this.mode, true));
					}
				}
			} else {
				Particle.emit = false;
			}
			
			
			for each (particle in particles) { particle.Update(); }

			Particle.frame++;
			for (var i:int = 1; i < this.iterations; i++) {
				for each (particle in particles) { particle.Update(); }
				Particle.frame++;
				for each (particle in particles) { particle.Density(); }
				for each (particle in particles) { particle.Pressure(); }
				for each (particle in particles) { particle.Relax(); }
			}

			//if (pressed["lmb"] && pressedprev["lmb"]) {
				//drag = true;
				//mdx = 0.25 * (Number)(mx - mxprev);
				//mdy = 0.25 * (Number)(my - myprev);
			//}
			
			pressedprev["lmb"] = pressed["lmb"];
			pressedprev["rmb"] = pressed["r"];
			pressedprev["mmb"] = pressed["mmb"];
			pressedprev["c"] = pressed["c"];
			pressedprev["up"] = pressed["up"];
			pressedprev["down"] = pressed["down"];
			pressedprev["left"] = pressed["left"];
			pressedprev["right"] = pressed["right"];
			pressedprev["space"] = pressed["space"];
			mxprev = mx;
			myprev = my;
		}

        public function mouseDragged(e:MouseEvent):void {
            pressed["lmb"] = true;
            mx = e.localX;
            my = e.localY;
        }

        public function mouseMoved(e:MouseEvent):void {
            mx = e.localX;
            my = e.localY;
        }

        public function mousePressed(e:MouseEvent):void {
			if (e.ctrlKey) pressed["mmb"] = true;
			else if (e.altKey) pressed["rmb"] = true;
			else pressed["lmb"] = true;
        }

        public function mouseReleased(e:MouseEvent):void {
            pressed["lmb"] = false;
            pressed["mmb"] = false;
            pressed["rmb"] = false;
        }

		private function keyboardUp(e:KeyboardEvent):void {
			if (e.keyCode == 32) pressed["space"] = false;
			else if (e.keyCode == 37) pressed["left"] = false;
			else if (e.keyCode == 38) pressed["up"] = false;
			else if (e.keyCode == 39) pressed["right"] = false;
			else if (e.keyCode == 40) pressed["down"] = false;
			else if ("c" == String.fromCharCode(e.charCode)) pressed["c"] = false;
		}

		private function keyboardDown(e:KeyboardEvent):void {
			if (e.keyCode == 32) pressed["space"] = true;
			else if (e.keyCode == 37) pressed["left"] = true;
			else if (e.keyCode == 38) pressed["up"] = true;
			else if (e.keyCode == 39) pressed["right"] = true;
			else if (e.keyCode == 40) pressed["down"] = true;
			else if ("c" == String.fromCharCode(e.charCode)) pressed["c"] = true;
		}
	}
}