package flx {
	import org.flixel.FlxMonitor;
	import flash.utils.getTimer;
	
	/**
	 * Permet de mesurer un interval de temps ou encore un compteur.
	 * 
	 * @author Saladin
	 */
	public class HakMonitor extends FlxMonitor {
		
		private var _counter:uint;
		private var _iscounter:Boolean;
		private var _mark:uint;

		public function HakMonitor(Size:uint) {
			super(Size);
			reset();
		}

		public function reset():void {
			_mark = 0;
			_counter = 0;
			//_iscounter = false;
		}

		public function mark():void {
			_mark = getTimer();
		}
		
		public function addTimer(cumul:Boolean = false):void {
			var old:uint = _mark;
			_mark = getTimer();
			if (cumul) {
				_counter += _mark - old;
			} else {
				add(_mark - old);
			}
		}

		public function cumul():void {
			add(_counter);
			_counter = 0;
		}
		
		public function count(inc:uint = 1, cumul:Boolean=false):void {
			_counter += inc;
			_iscounter = true;
			if (cumul) this.cumul();
		}
		
		public function get isCounter():Boolean { return _iscounter; }
	}

}