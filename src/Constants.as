package {
	import flash.geom.Rectangle;
	import utils.Vector2;
	
	/**
	 * Some constants
	 * 
	 * @author Saladin
	 */
	public class Constants{

		//{ Physic

		public static const GRAVITY:Vector2 = new Vector2(0.0, 9.81);
		public static const DENSITY_OFFSET:Number = 100;
		public static const GAS_K:Number = 0.1;
		public static const VISC0SITY:Number = 0.02;

		public static const SIM_DOMAIN:Rectangle = new Rectangle(0.1, 0.1, 6.1, 6.1);
		public static const CELL_SPACE:Number = (SIM_DOMAIN.width + SIM_DOMAIN.height) / 64.0;
		public static const DELTA_TIME_SEC:Number = 0.01;
		public static const PARTICLE_MASS:Number = CELL_SPACE * 20.0;

		//}
	
		//{ Common

		public static const PRIME_1:int = 73856093;
		public static const PRIME_2:int = 19349663;
		public static const PRIME_3:int = 83492791;

		public static const FLOAT_EPSILON:Number = 1.192092896e-07;

		//}

	}

}