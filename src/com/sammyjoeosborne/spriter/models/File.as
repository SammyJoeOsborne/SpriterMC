package com.sammyjoeosborne.spriter.models 
{
	import starling.textures.Texture;
	/**
	 * 1/14/2013 7:16 PM
	 * @author Sammy Joe Osborne
	 */
	public class File 
	{
		private var _id:uint;
		private var _name:String;
		private var _width:Number;
		private var _height:Number;
		private var _texture:Texture;
		
		public function File($id:uint, $name:String, $width:Number, $height:Number) 
		{
			_id = $id;
			_name = $name;
			_width = $width;
			_height = $height;
		}
		
		public function get id():uint { return _id; }
		
		public function get name():String { return _name; }
		
		public function get width():Number { return _width; }
		
		public function get height():Number { return _height; }
		
		public function get texture():Texture { return _texture; }
		public function set texture($value:Texture):void { _texture = $value; }
		
		public function dispose():void
		{
			if (_texture) _texture.dispose();
		}
		
	}

}