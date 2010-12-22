package renderers {
	import flash.display.BitmapData;
	import flx.HakSprite;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import particles.FluidParticle;
	import particles.FluidParticles;
	import org.flixel.FlxG;
	import pvfs.Material;
	import utils.Vector2;
	
	/**
	 * Renderer that computes just draws a sprite for each metaball
	 */
	public class MBRenderer0 extends Renderer {

		private var sprites:Vector.<FlxSprite>;
		
		private var materials:Vector.<Material>; // used to get the color

		public function MBRenderer0(Width:uint, Height:uint, texSize:int, energy:Number, fallOff:Number, energyThreshold:Number, materials:Vector.<Material> = null) {
			super(Width, Height);
			this.materials = materials;
			sprites = new Vector.<FlxSprite>();
			if (materials) {
				for (var i:int = 0; i < materials.length; i++) {
					sprites[i] = initPSprite(texSize, materials[i].c);
				}
			} else {
				sprites[0] = initPSprite(texSize);
			}
		}

		private function initPSprite(texSize:int, color:uint = 0xffffffff):FlxSprite {
			return new FlxSprite().createGraphic(texSize, texSize, color);
		}
		
		protected function getColor(color:uint, alpha:uint):uint {
			return  (Math.min(alpha, 255) << 24) | (color & 0x00ffffff);
		}

		override public function drawParticle(x:Number, y:Number, color:uint):void {
			var pSprite:FlxSprite = sprites[0];
			draw(pSprite, x - pSprite.width / 2, y - pSprite.height / 2);
		}

		override public function drawParticleM(x:Number, y:Number, material:uint):void {
			//var pSprite:FlxSprite = (materials) ? sprites[material] : sprites[0]; 
			var pSprite:FlxSprite = sprites[material];
			draw(pSprite, x - pSprite.width / 2, y - pSprite.height / 2);
		}

	}

}