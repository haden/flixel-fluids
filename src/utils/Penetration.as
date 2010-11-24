package utils {
	import utils.Vector2;
	/**
	 * ...
	 * @author Saladin
	 */
	public class Penetration{
		private var normal:Vector2 = new Vector2;
		public function get Normal():Vector2 { return normal; }
		public function set Normal(n:Vector2):void { normal.Set(n); }
		
		public var Length:Number = 0;

	}

}