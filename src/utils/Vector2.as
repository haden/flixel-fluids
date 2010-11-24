package utils {
	import utils.Vector2;
	/**
	 * ...
	 * @author Saladin
	 */
	public class Vector2 {

		static public const Zero:Vector2 = new Vector2;
		
		//{ Properties
		
		public var x:Number;
		public var y:Number;

		public function get LengthSquared():Number {
			return x * x + y * y;
		}
		
		//}
		
		public function Vector2(x:Number = 0, y:Number = 0) {
			this.x = x;
			this.y = y;
			
		}
		
		public function Normalize():void {
			var len:Number = Math.sqrt(LengthSquared);
			x /= len;
			y /= len;
		}
		
		public function Inc(vec:Vector2):Vector2 {
			x += vec.x;
			y += vec.y;
			return this;
		}
		
		public function Dec(vec:Vector2):Vector2 {
			x -= vec.x;
			y -= vec.y;
			return this;
		}
		
		public function Mul(value:Number):Vector2 {
			x *= value;
			y *= value;
			return this;
		}
		
		public function Set(vec:Vector2):Vector2 {
			x = vec.x;
			y = vec.y;
			return this;
		}
				
		public function Clone():Vector2 {
			return new Vector2(x, y);
		}

		public function get PerpendicularRight():Vector2 {
			return new Vector2(y, -x);
		}

		static public function get UnitX():Vector2 { return new Vector2(1, 0); }
		static public function get UnitY():Vector2 { return new Vector2(0, 1); }
		
		static public function mult(vec:Vector2, value:Number):Vector2 {
			return vec.Clone().Mul(value);
		}
		
		static public function add(left:Vector2, right:Vector2):Vector2 {
			return left.Clone().Inc(right);
		}
		
		static public function sub(left:Vector2, right:Vector2, out:Vector2 = null):Vector2 {
			if (!out) out = new Vector2;
			return out.Set(left).Dec(right);
		}
		
		static public function Dot(left:Vector2, right:Vector2):Number {
			return left.x * right.x + left.y * right.y;
		}
		
	}

}