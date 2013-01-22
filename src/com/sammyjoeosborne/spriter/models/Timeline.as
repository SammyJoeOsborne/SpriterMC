package com.sammyjoeosborne.spriter.models 
{
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	
	public class Timeline 
	{
		protected var _id:uint;
		protected var _name:String;
		protected var _keys:Vector.<Key> = new Vector.<Key>();
		protected var _isBone:Boolean = false;
		
		public function Timeline($id:uint, $name:String = "") 
		{
			_id = 	$id;
			_name = $name;
			_keys = new Vector.<Key>();
		}
		
		public function getKeyByID($id:uint):Key
		{
			return _keys[$id];
		}
		
		public function get id():uint { return _id; }
		
		public function get name():String { return _name; }
		
		public function get keys():Vector.<Key> { return _keys; }
		
		public function get isBone():Boolean { return _isBone; }
		public function set isBone(value:Boolean):void { _isBone = value; }
		
		
		
	}

}