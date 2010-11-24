package simulation {
	import flash.geom.Rectangle;
	import particles.FluidParticle;
	import particles.FluidParticles;
	
	/**
	 * Implementation of an evenly spaced spatial grid, used for fast fluid simulation
	 * 
	 * @author Saladin
	 */
	public class IndexGrid{
		static public const DEFAULT_DOMAIN:Rectangle = new Rectangle(0, 0, 256, 256);
		
		protected var grid:Vector.<Vector.<int>>;

		//{ Properties

		private var invCellSpace:Number;
		private var cellSpace:Number;
		public function get CellSpace():Number { return cellSpace; }

		private var domain:Rectangle;
		public function get Domain():Rectangle { return domain; }

		protected var width:int;
		public function get Width():int { return width; }

		protected var height:int;
		public function get Height():int { return height; }

		/** Returns (3^nDim)-1 -> nDim=2 => 8 */
		public function get NeighbourCount ():int { return 8; }

		public function get Count():int { return grid.length; }

		//}
		
		//{ Constructors

		public function IndexGrid(cellSpace:Number, domain:Rectangle, Particles:FluidParticles) {
			this.cellSpace       = cellSpace;
			this.invCellSpace
			this.domain          = domain;
			this.width           = (int)(this.Domain.width / this.CellSpace);
			this.height          = (int)(this.Domain.height / this.CellSpace);
			trace("Width: " + width);
			trace("Height: " + height);
			
			this.Refresh(Particles);
		}

		//}
		
		//{ Methods

		public function Refresh(Particles:FluidParticles):void {
			grid = new Vector.<Vector.<int>>(this.Width * this.Height, true);

			var particle:FluidParticle;
			if (Particles != null) {
				for (var i:int = 0; i < Particles.Count; i++) {
					particle = Particles.List[i];
					var gridIndexX:int = GetGridIndexX(particle);
					var gridIndexY:int = GetGridIndexY(particle); 
					var gridIndex:int = gridIndexX + gridIndexY * this.Width;

					// Add particle to list
					if (grid[gridIndex] == null) {
						grid[gridIndex] = new Vector.<int>();
					}
					grid[gridIndex].push(i);
				}
			}
		}

		protected function GetGridIndexX(particle:FluidParticle):int {
			var gridIndexX:int = int(particle.position.x / this.CellSpace);
			// Clamp X
			// TODO trouver le moyen d'éliminer ces tests complétement
			if (gridIndexX < 0) {
				gridIndexX = 0;
			}
			if (gridIndexX >= this.width) {
				gridIndexX = this.width - 1;
			}
			
			return gridIndexX;
		}

		protected function GetGridIndexY(particle:FluidParticle):int {
			var gridIndexY:int = int(particle.position.y / this.CellSpace);
			// Clamp Y
			if (gridIndexY < 0) {
				gridIndexY = 0;
			}
			if (gridIndexY >= this.height) {
				gridIndexY = this.height - 1;
			}
			
			return gridIndexY;
		}

		public function GetNeighbourIndex(particle:FluidParticle, neighbors:Vector.<int> = null):Vector.<int> {
			//var neighbors:Vector.<int> = new Vector.<int>();
			if (!neighbors) neighbors = new Vector.<int>();
			
			var gridIndexX:int = GetGridIndexX(particle);
			var gridIndexY:int = GetGridIndexY(particle);

			var maxx:int = Math.min(gridIndexX + 1, this.width - 1);
			var minx:int = Math.max(gridIndexX - 1, 0);
			var maxy:int = Math.min(gridIndexY + 1, this.height - 1);
			var miny:int = Math.max(gridIndexY - 1, 0);

			for (var x:int = minx; x <= maxx; x++) {
				for (var y:int = miny; y <= maxy; y++) {
					var idxList:Vector.<int> = grid[x + y * this.width];
					if (idxList != null) {
						// Return neighbours index
						for each (var idx:int in idxList) {
							neighbors.push(idx);
						}
					}
				}
			}
			
			return neighbors;
		}

		public function getNeighbors(nIdx:uint):Vector.<int> {
			throw new Error("Not Implemented");
		}

		//}

	}

}