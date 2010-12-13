package  pvfs
{
	/**
	 * ...
	 * @author haden.dude
	 */
	public class Material 
	{
		public var name:String;
		public var k:Number;
		public var knear:Number;
		public var restDensity:Number;
		
		public var simSpring:Boolean;
		public var kspring:Number;
		public var yieldRatio:Number;
		public var yieldRate:Number;
		public var yieldWithAge:Number;
		
		public var mass:Number;
		public var c:uint;
		
		public function Material(Name:String, k:Number, knear:Number, restDensity:Number, kspring:Number, yieldRatio:Number, yieldRate:Number,
			yieldWithAge:Number, mass:Number, color:uint) {
			var timestep:Number = Config.Default.timestep;
			var tsSq:Number = timestep * timestep;
			
			this.name = name;
			this.k = k * tsSq;
			this.knear = knear * tsSq;
			this.restDensity = restDensity;
			this.kspring =  kspring * tsSq;
			if (kspring > 0.) {
				this.simSpring = true;
				//this.kspring = kspring;
				this.yieldRatio = yieldRatio;
				this.yieldRate = yieldRate * timestep;
				this.yieldWithAge = yieldWithAge * timestep;
			}else {
				this.simSpring = false;
			}
			this.mass = mass;
			this.c = color;
		}
		
	}

}