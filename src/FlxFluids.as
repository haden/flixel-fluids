package
{
	import flash.events.Event;
	import flx.HakMonitors;
	import org.flixel.*;
	import org.flixel.data.FlxConsole;
	import pvfs.Config;
	
	[SWF(width="512", height="512", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class FlxFluids extends FlxGame
	{
		private static var monitors:HakMonitors;
		public static function get Monitors():HakMonitors { return monitors; }
		
		public function FlxFluids() {
			super(Config.Default.width, Config.Default.height, MenuState, 1);
			FlxU.seed = 0.5;
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

