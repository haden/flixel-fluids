package simulation.sks {
	import utils.Vector2;
	/**
	 * Implementation of the Spiky Smoothing-Kernel for SPH-based fluid simulation
	 * 
	 * @author Saladin
	 */
	public class SKSpiky extends SmoothingKernel{
		
		public function SKSpiky(kernelSize:Number) {
			super(kernelSize);
		}
		
		//{ Methods

		protected override function CalculateFactor():void {
			var kernelRad6:Number = Math.pow(KernelSize, 6.0);
			factor = 15.0 / (Math.PI * kernelRad6);
		}

		public override function Calculate(r:Vector2):Number {
			//var lenSq:Number = r.LengthSquared;
			var lenSq:Number = r.x * r.x + r.y * r.y;
			if (lenSq > kernelSizeSq) {
				return 0.0;
			}
			if (lenSq < Constants.FLOAT_EPSILON) {
				lenSq = Constants.FLOAT_EPSILON;
			}
			var f:Number = kernelSize - Math.sqrt(lenSq);
			return factor * f * f * f;
		}

		public override function CalculateGradient(r:Vector2, out:Vector2):void {
			//var lenSq:Number = r.LengthSquared;
			var lenSq:Number = r.x * r.x + r.y * r.y;
			if (lenSq > kernelSizeSq) {
				//return new Vector2;
				out.x = out.y = 0;
				return;
			}
			if (lenSq < Constants.FLOAT_EPSILON) {
				lenSq = Constants.FLOAT_EPSILON;
			}
			var len:Number = Math.sqrt(lenSq);
			var f:Number = -factor * 3.0 * (kernelSize - len) * (kernelSize - len) / len;

			//return new Vector2(r.x * f, r.y * f);
			out.x = r.x * f;
			out.y = r.y * f;
		}

		//}
	}

}