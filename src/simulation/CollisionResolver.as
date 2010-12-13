package simulation {
	import bounds.BoundingVolume;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import utils.Penetration;
	import utils.Vector2;
	
	/**
	 * Solves Collisions
	 * 
	 */
	public class CollisionResolver {
		
		//{ Properties

		private var bvs:Vector.<BoundingVolume> = new Vector.<BoundingVolume>();
		public function get BVs():Vector.<BoundingVolume> { return bvs; }

		public var Bounciness:Number = 1;

		public var Friction:Number = 0;

		//}
		
		//{ Methods

		/**
		 * Solves collisions for the bounding volumes among each other associated with this instance.
		 * @return True, if a collision occured
		 */
		public function Solve():Boolean {
			var hasCollided:Boolean = false;
			var pen:Penetration = new Penetration;
			var bv1:BoundingVolume, bv2:BoundingVolume;

			for each (bv1 in this.BVs) {
				for each (bv2 in this.BVs) {
					if (bv1 != bv2) {
						if (bv1.Intersects(bv2, pen)) {
							hasCollided = true;
							pen.Normal.Mul(pen.Length);
							if (bv2.IsFixed) {
								bv1.Position.Inc(pen.Normal);
							}
							else {
								bv2.Position.Dec(pen.Normal);
							}
						}
					}
				}
			}
			
			return hasCollided;
		}

		/// <summary>
		/// Solves collisions only for the particles and the bounding volumes associated with this instance.
		/// </summary>
		/// <param name="particles">The particles.</param>
		/// <returns>True, if a collision occured.</returns>
		
		/**
		 * Solves collisions only for the particles and the bounding volumes associeated with this instance.
		 * @param	Particles The particles.
		 * @return True, if a collision occured.
		 */
		public function SolveP(Particles:FluidParticles):Boolean {
			var hasCollided:Boolean = false;
			var pen:Penetration = new Penetration;
			var penVec:Vector2, v:Vector2, vn:Vector2, vt:Vector2;
			var penLen:Number, dp:Number;
			var bv:BoundingVolume;
			var particle:FluidParticle;
			
			v = new Vector2;
			penVec = new Vector2;
			vn = new Vector2;
			vt = new Vector2;
			
			for each (bv in this.BVs) {
				for each (particle in Particles.List) {
					if (bv.Intersects(particle.BV, pen)) {
						hasCollided = true;
						//penVec = Vector2.Mult(pen.Normal, pen.Length);
						penVec.Set(pen.Normal).Mul(pen.Length);
						if (particle.BV.IsFixed) {
							bv.Position.Inc(penVec);
						} else {
							particle.BV.Position.Dec(penVec);

							// Calc new velocity using elastic collision with friction
							// -> Split oldVelocity in normal and tangential component, revert normal component and add it afterwards
							// v = pos - oldPos;
							//vn = n * Vector2.Dot(v, n) * -Bounciness;
							//vt = t * Vector2.Dot(v, t) * (1.0f - Friction);
							//v = vn + vt;
							//oldPos = pos - v;

							//v = Vector2.Sub(particle.Position, particle.PositionOld); // v = pos - oldPos
							v.Set(particle.Position).Dec(particle.PositionOld);
							var tangent:Vector2 = pen.Normal.PerpendicularRight; // t
							dp = Vector2.Dot(v, pen.Normal); // dp = Dot(v, n)
							//vn = Vector2.Mult(pen.Normal, dp * -this.Bounciness); // vn = n * Dot(v, n) * - Bounciness
							vn.Set(pen.Normal).Mul(dp * -this.Bounciness);
							dp = Vector2.Dot(v, tangent); // dp = Dot(v, t)
							//vt = Vector2.Mult(tangent, dp * (1.0 - this.Friction)); // vt = t * Dot(v, t) * (1 - Friction)
							vt.Set(tangent).Mul(dp * (1.0 - this.Friction));
							//v = Vector2.Add(vn, vt); // v = vn + vt
							v.Set(vn).Inc(vt);
							particle.Position.Dec(penVec);
							//particle.PositionOld = Vector2.Sub(particle.Position, v); // oldPos = pos - v
							particle.PositionOld.Set(particle.Position).Dec(v);
						}
					}
				}
			}
			
			return hasCollided;
		}

		//}
		
	}

}