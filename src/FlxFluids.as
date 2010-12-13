package
{
	import flash.events.Event;
	import flx.HakMonitors;
	import org.flixel.*;
	import org.flixel.data.FlxConsole;
	import pvfs.Particle;

	[SWF(width="512", height="512", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]



	public class FlxFluids extends FlxGame
	{
		private static var monitors:HakMonitors;
		public static function get Monitors():HakMonitors { return monitors; }
		
		public function FlxFluids() {
			new Particle(0., 0., null, 0, false);
			super(512, 512, MenuState, 1);
		}
		
		override protected function update(event:Event):void {
			if (!monitors) {
				monitors = new HakMonitors(console.monitors, 8);
			} else {
				monitors.reset();
			}
			
			super.update(event);
		}

	}

}

