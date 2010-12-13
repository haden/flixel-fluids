package  pvfs
{
	/**
	 * ...
	 * @author haden.dude
	 */
	public class Cell 
	{
		public var particles:Vector.<Particle>;
		private var firstNull:int; // index of first empty particle slot
		public var last:int; // index of last particle in the cell
		
		public function Cell()  {
			particles = new Vector.<Particle>(25);
		}
		
		public function add(particle:Particle):void {
			this.particles[firstNull] = particle;
			particle.cindex = firstNull;
            if (this.firstNull == this.last) { // there are no empty slots before this.last
                this.firstNull++;
                this.last++;
                if (this.last == particles.length) {
                    particles.push(null, null, null, null);
                }
            } else {
                for (var j:int = this.firstNull + 1; j <= this.last; j++) { // find the first empty slot in this.particles
                    if (this.particles[j] == null) {
                        this.firstNull = j;
                        return;
                    }
                }
            }
		}

        public function remove(p:Particle):void {
            this.particles[p.cindex] = null;
            if (p.cindex < this.firstNull) {
                this.firstNull = p.cindex;
            }
            while ((this.last > 0) && (this.particles[this.last - 1] == null)) {
                this.last--;
            }
        }
		
	}

}