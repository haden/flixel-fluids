package flx {
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import org.flixel.FlxMonitor;
	
	/**
	 * ...
	 * @author Saladin
	 */
	public class HakMonitors {
		
		private var _monitors:Dictionary;
		private var _hidelist:Vector.<String>;
		private var _size:uint;
		private var _mark:uint;
		
		public function HakMonitors(mtrs:Dictionary, Size:uint) {
			_monitors = mtrs;
			_hidelist = new Vector.<String>();
			_size = Size;
		}
		
		public function hide(...keys):void {
			for each (var key:* in keys) {
				_hidelist.push(key);
			}
		}

		public function reset():void {
			for each (var monitor:FlxMonitor in _monitors) {
				if (monitor is HakMonitor) HakMonitor(monitor).reset();
			}
		}
		
		public function mark(key:String):void {
			getMonitor(key).mark();
		}
		
		public function cumul(key:String):void {
			getMonitor(key).cumul();
		}
		
		public function addTimer(key:String, cumul:Boolean = false):void {
			getMonitor(key).addTimer(cumul);
		}

		public function count(key:String, inc:uint = 1, cumul:Boolean = false):void {
			getMonitor(key).count(inc, cumul);
		}
		
		public function addMonitor(key:String, Size:uint):void {
			if (_monitors[key] == null) _monitors[key] = new HakMonitor(Size);
		}
		
		public function getMonitor(key:String):HakMonitor {
			var monitor:HakMonitor = _monitors[key];
			if (!monitor) _monitors[key] = monitor = new HakMonitor(_size);
			return monitor;
		}
		
		public function toString():String {
			var text:String = "";
			for (var key:String in _monitors) {
				var monitor:FlxMonitor = _monitors[key];
				
				if (_hidelist.indexOf(key) != -1) continue; // ne pas afficher ce moniteur
				if (!(monitor is HakMonitor)) continue; // ignorer les moniteurs d'origine
				
				var pre:String = HakMonitor(monitor).isCounter ? " ":"ms ";
				text = text + uint(monitor.average()) + pre + key + "\n";
			}
			
			return text;
		}
	}

}