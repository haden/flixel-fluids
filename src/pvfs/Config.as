package pvfs {
	/**
	 * Configuration parameters
	 */
	public class Config {
		
		static public var Default:Config = new Config;
		
		public var repel:Number;
		public var timestep:Number;
		public var spin:Number;
		public var attract:Number;
		public var gravity:Number;
		public var itrsperframe:int;
		public var particlesize:int;
		public var rendersize:int;
		public var emitnumber:int;
		public var width:int;
		public var height:int;
		
		public function Config() {
			timestep = 0.1;
			itrsperframe = 5;
			particlesize = 10;
			rendersize = 2;
			gravity = 0.1;
			repel = 10;
			spin = 10;
			attract = 0.1;
			emitnumber = 5;
			width = 512;
			height = 512;
		}
		
	}

}