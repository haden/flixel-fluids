package simulation.sks {
	import utils.Vector2;
	/**
	 * Implementation of the Poly6 Smoothing-Kernel for SPH-based fluid simulation
	 * 
	 * @author Saladin
	 */
	public class SKPoly6 extends SmoothingKernel{
		
		public function SKPoly6(kernelSize:Number) {
			super(kernelSize);
		}
		     
		//{ Methods

		protected override function CalculateFactor():void {
			var kernelRad9:Number = Math.pow(kernelSize, 9.0);
			factor = 315.0 / (64.0 * Math.PI * kernelRad9);
		}

		public override function Calculate(r:Vector2):Number {
			var lenSq:Number = r.LengthSquared;
			if (lenSq > kernelSizeSq) {
				return 0.0;
			}
			if (lenSq < Constants.FLOAT_EPSILON) {
				lenSq = Constants.FLOAT_EPSILON;
			}
			var diffSq:Number = kernelSizeSq - lenSq;
			return factor * diffSq * diffSq * diffSq;
		}

		public override function CalculateGradient(r:Vector2, out:Vector2):void {
			var lenSq:Number = r.LengthSquared;
			if (lenSq > kernelSizeSq) {
				//return new Vector2;
				out.x = out.y = 0;
				return;
			}
			if (lenSq < Constants.FLOAT_EPSILON) {
				lenSq = Constants.FLOAT_EPSILON;
			}
			var diffSq:Number = kernelSizeSq - lenSq;
			var f:Number = -factor * 6.0 * diffSq * diffSq;
			//return new Vector2(r.x * f, r.y * f);
			out.x = r.x * f;
			out.y = r.y * f;
		}

		//}

	}

}