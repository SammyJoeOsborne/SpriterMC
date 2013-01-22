package com.sammyjoeosborne.spriter.models 
{
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author ...
	 */
	public class Ref 
	{
		protected var _id:uint;
		protected var _parentID:int = -1; //this refers to the ID of a bone, doesn't have to exist
		protected var _parent:BoneRef = null; //only bones can be parents, so I'm typing it as a BoneRef
		protected var _timeline:Timeline; //reference to the timeline object which contains the keys for this object or bone
		protected var _key:Key; //reference to the key within the timeline that we want to use
		
		public function Ref($id:uint, $timeline:Timeline, $key:Key = null) 
		{
			_id = $id;
			_timeline = $timeline;
			_key = $key;
		}
		
		public function get id():uint { return _id; }
		public function set id(value:uint):void { _id = value; }
		
		public function get parentID():int { return _parentID; }
		public function set parentID(value:int):void { _parentID = value; }
		
		public function get parent():BoneRef { return _parent; }
		public function set parent(value:BoneRef):void { _parent = value; }
		
		public function get timeline():Timeline { return _timeline; }
		public function set timeline(value:Timeline):void { _timeline = value; }
		
		public function get key():Key { return _key; }
		public function set key(value:Key):void { _key = value; }
	}

}