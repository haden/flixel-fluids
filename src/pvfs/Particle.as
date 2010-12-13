package  pvfs
{
	/**
	 * ...
	 * @author haden.dude
	 */
	public class Particle
	{
		public static var attract:Number;
        public static var bottom:int;
        public var c:uint; // color
        public var cindex:int;
        public var d:Number;
        public var dn:Number;
        public static var emit:Boolean;
        public var firstNull:int;
        public var fix:Boolean;
        private var fixX:Number;
        private var fixY:Number;
        public var forceX:Number;
        public var forceY:Number;
        public static var frame:int = 0;
        public static var gh:int;
        public static var gravity:Number;
        private static var grid:Vector.<Vector.<Cell>>;
        public static var gw:int;
        private var hc:int;
        public static var height:int;
        public var index:int;
        private var k:Number;
        private var knear:Number;
        private var kspring:Number;
        //private var l:int = 20;
        public var last:int;
        public static var left:int;
        public static var lmb:Boolean;
        private var mass:Number;
        public static var mmb:Boolean;
        public static var mx:int;
        public static var my:int;
        private var neighbors:Vector.<Neighbor>;
        public static var nparts:int = 0;
        private var nsize:int;
        public var p:Number;
        public var p2:Number;
        public var phase:int;
        public var pn:Number;
        public var posX:Number;
        public var posY:Number;
        public var prevX:Number;
        public var prevY:Number;
        public static var rad:int;
        public static var repel:Number;
        private var restDensity:Number;
        public static var right:int;
        public static var rmb:Boolean;
        public static var rsq:int;
        public static var spin:Number;
        public var spring:Boolean;
        public static var top:int;
        private var vc:int;
        public static var width:int;
        private var yieldRate:Number;
        private var yieldRatio:Number;
        private var yieldWithAge:Number;

        public function Particle(x:Number, y:Number, m:Material, p:int, f:Boolean) {
            this.posX = this.prevX = x;
            this.posY = this.prevY = y;
            this.k = m.k;
            this.knear = m.knear;
            this.restDensity = m.restDensity;
            if (m.simSpring) {
                this.spring = true;
                this.kspring = m.kspring;
                this.yieldRatio = m.yieldRatio;
                this.yieldRate = m.yieldRate;
                this.yieldWithAge = m.yieldWithAge;
            } else {
                this.spring = false;
            }
            this.mass = m.mass;
            this.c = m.c;
            this.phase = p;
            this.forceX = this.forceY = 0.;
            this.neighbors = new Vector.<Neighbor>(20);
            for (var i:int = 0; i < this.neighbors.length; i++) {
                this.neighbors[i] = new Neighbor();
            }
            this.hc = int(this.posX) / rad;
            this.vc = int(this.posY) / rad;
            grid[this.hc][this.vc].add(this);
            this.fix = f;
            this.fixX = x;
            this.fixY = y;
            this.index = nparts++;
        }

        public function Density():void {
            var density:Number = 0;
            var neardensity:Number = 0;
			
            for (var i:int = (this.hc > 0) ? (this.hc - 1) : 0; (i < (this.hc + 2)) && (i < gw); i++) {
                for (var j:int = (this.vc > 0) ? (this.vc - 1) : 0; (j < (this.vc + 2)) && (j < gh); j++) {
                    var cell:Cell = grid[i][j];
                    for (var k:int = 0; k < cell.last; k++) { // for each particle in the cell
                        var particle:Particle = cell.particles[k];
                        if ((particle != null) && (particle.index < this.index)) {
                            var distx:Number = particle.posX - this.posX;
                            if ((distx > -rad) && (distx < rad)) {
                                var disty:Number = particle.posY - this.posY;
                                if ((disty > -rad) && (disty < rad)) {
                                    var rij:Number = (distx * distx) + (disty * disty);
                                    if ((rij < rsq) && (rij > .0)) {
                                        rij = Math.sqrt(rij);
                                        var q:Number = 1. - (rij / rad); // (1-q)
                                        var q2:Number = q * q;
                                        var q3:Number = q * q2;
                                        density += q2;
                                        neardensity += q3;

										particle.d += q2;
                                        particle.dn += q3;
										
                                        if (this.spring) {
                                            var flag:Boolean = false;
                                            for (var m:int = 0; m < this.last; m++) {
                                                var neighbor:Neighbor = this.neighbors[m];
                                                if (neighbor.j == particle) {
                                                    flag = true;
                                                    neighbor.q = q;
                                                    neighbor.q2 = q2;
                                                    var num13:Number = distx / rij;
                                                    var num14:Number = disty / rij;
                                                    neighbor.dx = num13;
                                                    neighbor.dy = num14;
                                                    neighbor.lastUpdate = frame;
                                                    if (!emit && (neighbor.j.phase == this.phase)) {
                                                        var num15:Number = this.yieldRatio * neighbor.restLength;
                                                        var num16:Number = neighbor.restLength + num15;
                                                        if (rij > num16) {
                                                            neighbor.restLength += this.yieldRate * (rij - num16);
                                                        } else {
                                                            var num17:Number = neighbor.restLength - num15;
                                                            if (rij < num17) {
                                                                neighbor.restLength += this.yieldRate * (rij - num17);
                                                            }
                                                        }
                                                        neighbor.restLength += this.yieldWithAge * (rij - neighbor.restLength);
                                                        var num18:Number = (this.kspring * (1. - (neighbor.restLength / (Number(rad))))) * (neighbor.restLength - rij);
                                                        var num19:Number = num18 * num13;
                                                        var num20:Number = num18 * num14;
                                                        this.forceX -= num19;
                                                        this.forceY -= num20;

														particle.forceX += num19;
                                                        particle.forceY += num20;
                                                        break;
                                                    }
                                                    neighbor.restLength = rij;
                                                    break;
                                                }
                                            }
                                            if (!flag) {
                                                var neighbor2:Neighbor = this.neighbors[this.firstNull];
                                                neighbor2.j = particle;
                                                neighbor2.q = q;
                                                neighbor2.q2 = q2;
                                                var num21:Number = distx / rij;
                                                var num22:Number = disty / rij;
                                                neighbor2.dx = num21;
                                                neighbor2.dy = num22;
                                                neighbor2.restLength = rij;
                                                neighbor2.lastUpdate = frame;
                                                if (this.firstNull == this.last) {
                                                    this.firstNull++;
                                                    this.last++;
                                                    if (this.last == this.neighbors.length) {
														this.neighbors.push(new Neighbor);
														this.neighbors.push(new Neighbor);
														this.neighbors.push(new Neighbor);
														this.neighbors.push(new Neighbor);
                                                    }
                                                } else {
                                                    for (var num25:int = this.firstNull + 1; num25 <= this.last; num25++) {
                                                        if (this.neighbors[num25].j == null) {
                                                            this.firstNull = num25;
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                            continue;
                                        }
                                        if (this.nsize == neighbors.length) {
											this.neighbors.push(new Neighbor);
											this.neighbors.push(new Neighbor);
											this.neighbors.push(new Neighbor);
											this.neighbors.push(new Neighbor);
                                        }
                                        var neighbor3:Neighbor = this.neighbors[this.nsize++];
                                        neighbor3.j = particle;
                                        neighbor3.q = q;
                                        neighbor3.q2 = q2;
                                        var dx:Number = distx / rij;
                                        var dy:Number = disty / rij;
                                        neighbor3.dx = dx;
                                        neighbor3.dy = dy;
                                    }
                                }
                            }
                        }
                    }
                }
            }

			this.d += density;
            this.dn += neardensity;
			
			//if (density > 0) trace("density: " + density);
        }

        public static function InitGrid(r:int, w:int, h:int):void  {
            rad = r;
            rsq = rad * rad;
            width = w;
            height = h;
            left = rad;
            right = width - rad;
            top = rad;
            bottom = height - rad;
            gw = (width / rad) + 1;
            gh = (height / rad) + 1;
            grid = new Vector.<Vector.<Cell>>(gw, true);
            for (var i:int = 0; i < gw; i++) {
				grid[i] = new Vector.<Cell>(gh, true);
                for (var j:int = 0; j < gh; j++) {
                    grid[i][j] = new Cell();
                }
            }
            repel = (Config.Default.repel * Config.Default.timestep) * Config.Default.timestep;
            spin = (Config.Default.spin * Config.Default.timestep) * Config.Default.timestep;
            attract = (Config.Default.attract * Config.Default.timestep) * Config.Default.timestep;
            gravity = (Config.Default.gravity * Config.Default.timestep) * Config.Default.timestep;
        }

        public function Pressure():void {
            this.p = this.k * (this.mass * this.d - this.restDensity);
            this.p2 = this.k * this.mass * this.d;
            this.pn = this.knear * this.mass * this.dn;
        }

        public function Relax():void {
            var Fx:Number = .0;
            var Fy:Number = .0;
            if (this.spring) {
                for (var i:int = 0; i < this.last; i++) {
                    var neighbor:Neighbor = this.neighbors[i];
                    if (neighbor.j != null) {
                        if (neighbor.lastUpdate == frame) {
                            var num4:Number = (this.phase == neighbor.j.phase) ? 
								(((this.p + neighbor.j.p) * neighbor.q) + ((this.pn + neighbor.j.pn) * neighbor.q2)) 
								: 
								(((this.p2 + neighbor.j.p2) * neighbor.q) + ((this.pn + neighbor.j.pn) * neighbor.q2));
                            var num5:Number = num4 * neighbor.dx;
                            var num6:Number = num4 * neighbor.dy;
                            Fx += num5;
                            Fy += num6;

							neighbor.j.forceX += num5;
                            neighbor.j.forceY += num6;
                            //goto Label_0306;
                        } else if (!emit && (neighbor.j.phase == this.phase)) {
                            var num7:Number = neighbor.j.posX - this.posX;
                            var num8:Number = neighbor.j.posY - this.posY;
                            var num9:Number = (num7 * num7) + (num8 * num8);
                            num9 = Math.sqrt(num9);
                            var num10:Number = num7 / num9;
                            var num11:Number = num8 / num9;
                            var num12:Number = this.yieldRatio * neighbor.restLength;
                            var num13:Number = neighbor.restLength + num12;
                            if (num9 > num13) {
                                neighbor.restLength += this.yieldRate * (num9 - num13);
                            }
                            neighbor.restLength += this.yieldWithAge * (num9 - neighbor.restLength);
                            if (neighbor.restLength < rad) {
                                var num14:Number = (this.kspring * (1. - (neighbor.restLength / (Number(rad))))) * (neighbor.restLength - num9);
                                var num15:Number = num14 * num10;
                                var num16:Number = num14 * num11;
                                Fx += num15;
                                Fy += num16;

								neighbor.j.forceX += num15;
                                neighbor.j.forceY += num16;
                                //goto Label_0306;
                            } else {
								neighbor.j = null;
								if (i < this.firstNull) {
									this.firstNull = i;
								}
								while ((this.last > 0) && (this.neighbors[this.last - 1].j == null)) {
									this.last--;
								}
							}
                        } else {
                            neighbor.j = null;
                            if (i < this.firstNull) {
                                this.firstNull = i;
                            }
                            while ((this.last > 0) && (this.neighbors[this.last - 1].j == null)) {
                                this.last--;
                            }
                        }
                    //Label_0306:;
                    }
                }
            } else {
				// Le problème est dans le calcul de this.p et neighbor2.j.p
                for (var j:int = 0; j < this.nsize; j++) {
                    var neighbor2:Neighbor  = this.neighbors[j];
                    var num18:Number = (this.phase == neighbor2.j.phase) ? 
						(((this.p + neighbor2.j.p) * neighbor2.q) + ((this.pn + neighbor2.j.pn) * neighbor2.q2)) 
						: 
						(((this.p2 + neighbor2.j.p2) * neighbor2.q) + ((this.pn + neighbor2.j.pn) * neighbor2.q2));
                    var Fjx:Number = num18 * neighbor2.dx;
                    var Fjy:Number = num18 * neighbor2.dy;
                    Fx += Fjx;
                    Fy += Fjy;

					neighbor2.j.forceX += Fjx;
                    neighbor2.j.forceY += Fjy;
                }
            }
            this.forceX -= Fx;
            this.forceY -= Fy;
        }

        public function Update():void {
            this.posX += this.forceX / this.mass;
            this.posY += this.forceY / this.mass;
            if (this.fix) {
                if (emit) {
                    this.fixX = this.posX;
                    this.fixY = this.posY;
                } else {
                    this.posX = this.fixX;
                    this.posY = this.fixY;
                }
            }
            this.forceX = .0;
            this.forceY = gravity * this.mass;
            var num:Number = this.posX - this.prevX;
            var num2:Number = this.posY - this.prevY;
            if (emit) {
                num *= 0.5;
                num2 *= 0.5;
                this.forceY = .0;
            }
            if (lmb) {
                var num3:Number = this.posX - mx;
                var num4:Number = this.posY - my;
                var num5:Number = ((num3 * num3) + (num4 * num4)) / repel;
                this.forceX += (num3 / num5) * this.mass;
                this.forceY += (num4 / num5) * this.mass;
            }
            if (mmb) {
                var num6:Number = this.posX - mx;
                var num7:Number = this.posY - my;
                var num8:Number = ((num6 * num6) + (num7 * num7)) / spin;
                this.forceX -= (num7 / num8) * this.mass;
                this.forceY += (num6 / num8) * this.mass;
            }
            if (rmb) {
                var num9:Number = this.posX - mx;
                var num10:Number = this.posY - my;
                var num11:Number = Math.sqrt(((num9 * num9) + (num10 * num10))) / attract;
                this.forceX -= (num9 / num11) * this.mass;
                this.forceY -= (num10 / num11) * this.mass;
            }
            this.prevX = this.posX;
            this.prevY = this.posY;
            this.posX += num;
            this.posY += num2;
            if (this.posX < left) {
                this.forceX += ((left - this.posX) / 8.) * this.mass;
            } else if (this.posX > right) {
                this.forceX += ((right - this.posX) / 8.) * this.mass;
            }
            if (this.posY < top) {
                this.forceY += ((top - this.posY) / 8.) * this.mass;
            } else if (this.posY > bottom) {
                this.forceY += ((bottom - this.posY) / 8.) * this.mass;
            }
            this.d = 0.;
            this.dn = 0.;
            this.nsize = 0;
            var num12:int = int(this.posX) / rad;
            if ((num12 > -1) && (num12 < gw)) {
                var num13:int = int(this.posY) / rad;
                if (((num13 > -1) && (num13 < gh)) && ((num12 != this.hc) || (num13 != this.vc))) {
					grid[this.hc][this.vc].remove(this);
                    this.hc = num12;
                    this.vc = num13;
					grid[this.hc][this.vc].add(this);
                }
            }
        }
    }

}