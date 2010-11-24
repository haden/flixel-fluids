package simulation {
	import flash.geom.Rectangle;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import simulation.sks.SmoothingKernel;
	import utils.Vector2;
	
	/**
	 * Implementation of an evenly spaced spatial grid, used for fast fluid simulation.
	 * Version optimisée qui calcule en une seule fois les neighbors de toutes les particules
	 * 
	 * @author Saladin
	 */
	public class IndexGridO extends IndexGrid{

		//{ Properties
		public var neighbors:Vector.<Vector.<int>>;

		//}
		
		//{ Constructors

		public function IndexGridO(cellSpace:Number, domain:Rectangle, MaxNumParticles:uint, MaxNeighborSize:uint) {
			super(cellSpace, domain, null);

			neighbors = new Vector.<Vector.<int>>(MaxNumParticles, true);
			for (var i:uint = 0; i < MaxNumParticles; i++) {
				neighbors[i] = new Vector.<int>(MaxNeighborSize + 1, true);
			}
		}

		//}
		
		//{ Methods

		public override function Refresh(Particles:FluidParticles):void {
			super.Refresh(Particles);

			var particle:FluidParticle;
			var i:uint, nIdx:uint, index:uint;
			var gridX:uint, gridY:uint;
			var maxx:uint, minx:uint, maxy:uint, miny:uint;
			var x:uint, y:uint;

			if (Particles != null) {
				for (i = 0; i < Particles.Count; i++) {
					neighbors[i][0] = 0;
				}			

				for (i = 0; i < Particles.Count; i++) {
					particle = Particles.list[i];

					gridX = GetGridIndexX(particle);
					gridY = GetGridIndexY(particle);

					maxx = Math.min(gridX + 1, this.width - 1);
					minx = Math.max(gridX - 1, 0);
					maxy = Math.min(gridY + 1, this.height - 1);
					miny = Math.max(gridY - 1, 0);

					for (x = minx; x <= maxx; x++) {
						for (y = miny; y <= maxy; y++) {
							var idxList:Vector.<int> = grid[x + y * this.width];
							if (idxList) {
								for each (nIdx in idxList) {
									if (nIdx < i) {
										index = neighbors[nIdx][0];
										neighbors[nIdx][index + 1] = i;
										neighbors[nIdx][0]++;
									}
								}
							}
						}
					}
					
				}
			}
		}
		
		public function RefreshOld(Particles:FluidParticles):void {
			super.Refresh(Particles);

			if (Particles != null) {
				neighbors = new Vector.<Vector.<int>>();
				for (var i:int = 0; i < Particles.Count; i++) {
					neighbors[i] = new Vector.<int>();
					GetNeighbourIndex(Particles.List[i], neighbors[i]); //TODO passer i comme param afin de ne pas inclure nIdx < i
				}
			}
		}

		public override function getNeighbors(nIdx:uint):Vector.<int> {
			return neighbors[nIdx];
		}

		//}

	}

}