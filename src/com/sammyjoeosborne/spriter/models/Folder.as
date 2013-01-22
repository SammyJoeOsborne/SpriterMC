package com.sammyjoeosborne.spriter.models 
{
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	public class Folder 
	{
		private var _id:uint;
		private var _name:String;
		private var _files:Vector.<File> = new Vector.<File>();
		
		public function Folder($id:uint, $name:String) 
		{
			_id = $id;
			_name = $name;
		}
		
		public function addFile($file:File):void
		{
			_files.push($file);
		}
		
		public function getFileTexture($fileID:uint):Texture
		{
			return _files[$fileID].texture;
		}
		
		public function get files():Vector.<File> { return _files; }
		
		public function get name():String { return _name; }
		
		public function get id():uint { return _id; }
		
		public function dispose():void
		{
			var $length:uint = _files.length;
			for (var i:uint = $length; i >= 0; i--)
			{
				_files[i].dispose();
				_files[i] = null;
			}
			_files.length = 0;
		}
		
	}

}