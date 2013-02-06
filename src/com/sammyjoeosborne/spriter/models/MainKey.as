package com.sammyjoeosborne.spriter.models 
{
	import flash.geom.Point;
	/**
	 * 12/9/2012 3:52 PM
	 * @author Sammy Joe Osborne
	 */
	
	public class MainKey 
	{
		protected var _id:uint;
		protected var _time:uint; ///Time in milliseconds for this key to occur
		protected var _objectRefs:Vector.<ObjectRef> = new Vector.<ObjectRef>();
		protected var _boneRefs:Vector.<BoneRef> = new Vector.<BoneRef>();
		protected var _callbacks:Vector.<Function>;
		
		public function MainKey($id:uint, $time:uint) 
		{
			_id = 		$id;
			_time = 	$time;		
		}
		
		public function toString():String
		{
			return ("id: " + _id + " time: " + _time );
		}
		
		public function get id():uint { return _id; }
		public function set id(value:uint):void { _id = value; }
		
		public function get time():uint { return _time; }
		public function set time(value:uint):void { _time = value; }
		
		public function get objectRefs():Vector.<ObjectRef> { return _objectRefs; }
		public function set objectRefs(value:Vector.<ObjectRef>):void { _objectRefs = value; }
		
		public function get boneRefs():Vector.<BoneRef> { return _boneRefs; }
		public function set boneRefs(value:Vector.<BoneRef>):void { _boneRefs = value; }
		
		public function get callbacks():Vector.<Function> { return _callbacks; }
		
		public function clone():MainKey
		{
			var $cMainKey:MainKey = new MainKey(_id, _time);
			$cMainKey.boneRefs = _boneRefs;
			$cMainKey.objectRefs = _objectRefs;
			
			return $cMainKey;
		}
		
	}

}