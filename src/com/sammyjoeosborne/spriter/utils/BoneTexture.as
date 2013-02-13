package com.sammyjoeosborne.spriter.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	public class BoneTexture
	{
		
		public function BoneTexture() 
		{
			
		}
		
		public static function generateBoneTexture():Texture
		{
			var $boneMC:Sprite = new Sprite();
			$boneMC.graphics.lineStyle(1,0xff66cc);
			$boneMC.graphics.beginFill(0xff99cc, .5);
			$boneMC.graphics.moveTo(0, 10);
			$boneMC.graphics.lineTo(20, 0);
			$boneMC.graphics.lineTo(200, 10);
			$boneMC.graphics.lineTo(20, 20);
			$boneMC.graphics.endFill();

			var $bd:BitmapData = new BitmapData($boneMC.width, $boneMC.height, true,0x00FFFFFF);
			$bd.draw($boneMC);
			
			return Texture.fromBitmapData($bd);
		}
		
	}

}