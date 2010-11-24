package simulation.sks {
	import utils.Vector2;
	/**
	 * ...
	 * @author Saladin
	 */
	public class SmoothingKernel{

		protected var factor:Number;
		protected var kernelSizeSq:Number;
		protected var kernelSize3:Number;

		//{ Properties

		protected var kernelSize:Number;
		public function get KernelSize():Number { return kernelSize; }
		public function set KernelSize(value:Number):void {
			kernelSize      = value;
			kernelSizeSq    = kernelSize * kernelSize;
			kernelSize3     = kernelSize * kernelSize * kernelSize;
			CalculateFactor();
		}
		
		//}
		
		public function SmoothingKernel(kernelSize:Number = 1) {
			factor = 1;
			this.KernelSize = kernelSize;
		}
		
		//{ Methods

		protected function CalculateFactor():void {
			throw new Error("Not Implemented");
		}

		public function Calculate(r:Vector2):Number {
			throw new Error("Not Implemented");
		}

		public function CalculateGradient(r:Vector2, out:Vector2):void {
			throw new Error("Not Implemented");
		}

		public function CalculateLaplacian(r:Vector2):Number {
			throw new Error("Not Implemented");
		}

		//}

	}

}