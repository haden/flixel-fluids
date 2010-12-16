package renderers {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import pvfs.Config;
	import pvfs.Neighbor;
	import pvfs.Particle;
	
	public class SpriteRenderer extends Renderer {

		private var fluidContainer:Sprite = new Sprite();
		private var fluidG:Graphics;
		//private var bitmap:Bitmap = new Bitmap();
		//private var bitmapData:BitmapData;
		private var bitmapDataCopy:BitmapData;
		
		private var blurFilter:BlurFilter = new BlurFilter(10, 10, 2);
		
		//private var point:Point = new Point(0, 0);

		public function SpriteRenderer(Width:int, Height:int) {
			super(Width, Height);
			//bitmapData = new BitmapData(Config.Default.width, Config.Default.height, true, 0xFF000000);
			bitmapDataCopy = new BitmapData(Config.Default.width, Config.Default.height, false, 0xFF000000);
			
			//bitmap = new Bitmap(bitmapData, "auto", true);
			
			fluidG = fluidContainer.graphics;
		}

		override public function beginDraw():void {
			fluidG.clear();
			//fluidG.lineStyle(1, 0xFFFFFF);
		}
		
		override public function drawParticle(x:Number, y:Number, color:uint):void {
			fluidG.beginFill(color);
			fluidG.drawCircle(x, y, Config.Default.rendersize);
			fluidG.endFill();
		}

		override public function endDraw():void {
			bitmapDataCopy.fillRect(bitmapDataCopy.rect, 0xFFaaaaaa);
			
			bitmapDataCopy.draw(fluidContainer, null, null, null, _flashRect, false);
			//bitmapDataCopy.applyFilter(bitmapDataCopy, _flashRect, _flashPoint, blurFilter);
			
			_framePixels.fillRect(_flashRect, 0xFFaaaaaa);
			_framePixels.copyPixels(bitmapDataCopy, bitmapDataCopy.rect, _flashPoint);
		}
		
		override public function render():void {
			super.render();
		}
	}

}