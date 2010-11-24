package flx {
	import flash.display.BitmapData;
	import org.flixel.FlxSprite;
	
	/**
	 * Version spéciale de FlxSprite qui optimise la méthode draw()
	 * @author Saladin
	 */
	public class HakSprite extends FlxSprite{

		override public function draw(Brush:FlxSprite, X:int = 0, Y:int = 0):void {
			var b:BitmapData = Brush.pixels;

			_flashPoint.x = X;
			_flashPoint.y = Y;
			_flashRect2.width = b.width;
			_flashRect2.height = b.height;
			_framePixels.copyPixels(b,_flashRect2,_flashPoint,null,null,true);
			_flashRect2.width = _pixels.width;
			_flashRect2.height = _pixels.height;
		}
	}

}