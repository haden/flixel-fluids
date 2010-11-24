package simulation.sks {
	import utils.Vector2;
	/**
	 * ...
	 * @author Saladin
	 */
	public class SKViscosity extends SmoothingKernel {
		
		public function SKViscosity(kernelSize:Number) {
			super(kernelSize);
		}
		
		//{ Methods

		protected override function CalculateFactor():void {
			factor = 15.0 / (2.0 * Math.PI * kernelSize3);
		}

		public override function Calculate(r:Vector2):Number {
			var lenSq:Number = r.LengthSquared;
			if (lenSq > kernelSizeSq) {
				return 0.0;
			}
			if (lenSq < Constants.FLOAT_EPSILON) {
				lenSq = Constants.FLOAT_EPSILON;
			}
			var len:Number = Math.sqrt(lenSq);
			var len3:Number = len * len * len;
			return factor * (((-len3 / (2.0 * kernelSize3)) + (lenSq / kernelSizeSq) + (kernelSize / (2.0 * len))) - 1.0);
		}

		public override function CalculateLaplacian(r:Vector2):Number {
			//var lenSq:Number = r.LengthSquared;
			var lenSq:Number = r.x * r.x + r.y * r.y;
			if (lenSq > kernelSizeSq) {
				return 0.0;
			}
			if (lenSq < Constants.FLOAT_EPSILON) {
				lenSq = Constants.FLOAT_EPSILON;
			}
			var len:Number = Math.sqrt(lenSq);
			return factor * (6.0 / kernelSize3) * (kernelSize - len);
		}

		//}

	}

}