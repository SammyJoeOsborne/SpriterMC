package com.sammyjoeosborne.spriter.models 
{	
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	
	public class AnimationData
	{
		public var RADIAN_IN_DEGREE:Number = 0.0174532925; //using this is slightly faster than doing PI/180
		
		protected var _id:uint;
		private var _name:String;
		private var _length:uint;
		private var _mainKeys:Vector.<MainKey> = new Vector.<MainKey>();
		private var _timelines:Vector.<Timeline> = new Vector.<Timeline>();
		private var _totalTime:uint = 0; //in milliseconds
		private var _loop:Boolean = true;
		
		public function AnimationData()
		{
		
		}
		
		/**********************
		 * Public Getters and Setters
		 **********************/
		
		public function get id():uint { return _id; }
		public function set id(value:uint):void { _id = value; }
		
		public function get totalTime():uint { return _totalTime; }
		public function set totalTime(value:uint):void { _totalTime = value; }
		
		public function get timelines():Vector.<Timeline> { return _timelines; }
		public function set timelines(value:Vector.<Timeline>):void { _timelines = value; }
		
		public function get mainKeys():Vector.<MainKey> { return _mainKeys; }
		public function set mainKeys(value:Vector.<MainKey>):void { _mainKeys = value; }
		
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }
		
		public function get length():uint { return _length; }
		public function set length(value:uint):void { _length = value; }
		
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
	}

}