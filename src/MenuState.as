package
{
	import org.flixel.*;
	import flash.system.Capabilities;

	public class MenuState extends FlxState
	{

		override public function create():void {
			add(new FlxSprite().createGraphic(FlxG.width, FlxG.height, 0xFFaaaaaa));
			
			var t:FlxText;
			add(t = new FlxText(0, FlxG.height / 3, FlxG.width, "FlxFluids"));
			t.setFormat(null, 32, 0xffffff, "center", 0xff000000);

			var b:FlxButton;
			var btnwidth:int = 450;
			add(b = new FlxButton((FlxG.width - btnwidth) / 2, FlxG.height / 2, sph));
			b.loadGraphic(new FlxSprite().createGraphic(btnwidth, 20, 0xffaaaaaa), new FlxSprite().createGraphic(btnwidth, 20, 0xffffaaaa));
			b.loadText(t = new FlxText(0, 0, btnwidth, "Smoothed Particle Hydrodynamics"));
			t.setFormat(null, 16, 0xffffff, "center");

			add(b = new FlxButton((FlxG.width - btnwidth) / 2, FlxG.height / 2 + 50, pvfs));
			b.loadGraphic(new FlxSprite().createGraphic(btnwidth, 20, 0xffaaaaaa), new FlxSprite().createGraphic(btnwidth, 20, 0xffffaaaa));
			b.loadText(t = new FlxText(0, 0, btnwidth, "Particle-based Viscoelastic Fluid Simulation"));
			t.setFormat(null, 16, 0xffffff, "center");
			
			if (Capabilities.isDebugger) FlxG.log("Running in DEBUGGER");
			
			FlxG.mouse.show();
		}

		protected function sph():void {
			FlxG.state = new PlayState;
		}

		protected function pvfs():void {
			FlxG.state = new PVFSPlayState;
		}
	}

}

