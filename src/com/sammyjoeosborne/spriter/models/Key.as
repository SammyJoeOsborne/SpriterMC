package com.sammyjoeosborne.spriter.models 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * 12/9/2012 3:52 PM
	 * @author Sammy Joe Osborne
	 */
	
	public class Key
	{
		protected var _id:uint;
		protected var _time:uint; ///Time in milliseconds for this key to occur
		protected var _spin:int;   ///-1 for negative rotation, 1 for positive, 0 for no rotation
		protected var _folder:uint;
		protected var _file:uint;
		private var _pivot:Point;
		private var _originalTransform:Transform = new Transform();
		private var _modTransform:Transform = new Transform();
		private var _timeline:Timeline; //the timeline this key is a part of
		
		private var _prev:Key = null; //reference to the previous key in this timeline
		private var _next:Key = null; //reference to the next key in this timeline
		
		private var _nextFileDirty:Boolean = true;
		private var _prevFileDirty:Boolean = true;
		
		private var _nextPropsDirty:Boolean = true;
		private var _prevPropsDirty:Boolean = true;
		
		private var _nextPivotDirty:Boolean = true;
		private var _prevPivotDirty:Boolean = true;
		
		public function Key($id:uint, $time:uint, $spin:int) 
		{
			_id = 		$id;
			_time = 	$time;
			_spin = 	$spin;		
		}
		
		public function toString():String
		{
			return ("id: " + _id 
				+ " time: " + _time 
				+ " spin: " + _spin 
				+ " x: " + _originalTransform.x 
				+ " y: " + _originalTransform.y
				+ " angle: " + _originalTransform.angle 
				+ " folder: " + _folder 
				+ " file: " + _file
				+ " nextFileDirty: " + nextFileDirty 
				+ " prevFileDirty: " + prevFileDirty);
		}
		
		public function arePropsEqual($key:Key):Boolean 
		{
			return _originalTransform.equals($key.originalTransform);
		}
		
		public function get id():uint { return _id; }
		
		public function get time():uint { return _time; }
		
		public function get spin():int { return _spin; }
		
		public function get folder():uint { return _folder; }
		public function set folder(value:uint):void { _folder = value; }
		
		public function get file():uint { return _file; }
		public function set file(value:uint):void { _file = value; }
		
		public function get x():Number { return _originalTransform.x; }
		public function set x(value:Number):void { 
			_originalTransform.x = value;
		}
		
		public function get y():Number { return _originalTransform.y; }
		public function set y(value:Number):void { 
			_originalTransform.y = value;
		}
		
		public function get angle():Number { return _originalTransform.angle; }
		public function set angle(value:Number):void {
			_originalTransform.angle = value;
		}
				
		public function get scaleX():Number { return _originalTransform.scaleX; }
		public function set scaleX(value:Number):void {
			_originalTransform.scaleX = value;
			
		}
		
		public function get scaleY():Number { return _originalTransform.scaleY; }
		public function set scaleY(value:Number):void { 
			_originalTransform.scaleY = value;
		}
		
		public function get pivot():Point { return _pivot; }
		public function set pivot(value:Point):void { _pivot = value; }
		
		public function get timeline():Timeline { return _timeline; }
		public function set timeline(value:Timeline):void { _timeline = value; }
		
		public function get prev():Key { return _prev; }
		public function set prev(value:Key):void { _prev = value; }
		
		public function get next():Key { return _next; }
		public function set next(value:Key):void { _next = value; }
		
		public function get nextPropsDirty():Boolean { return _nextPropsDirty; }
		public function set nextPropsDirty(value:Boolean):void { _nextPropsDirty = value; }
		
		public function get prevPropsDirty():Boolean { return _prevPropsDirty; }
		public function set prevPropsDirty(value:Boolean):void { _prevPropsDirty = value; }
		
		public function get originalTransform():Transform { return _originalTransform; }
		
		public function get nextPivotDirty():Boolean { return _nextPivotDirty; }
		public function set nextPivotDirty(value:Boolean):void { _nextPivotDirty = value; }
		
		public function get prevPivotDirty():Boolean { return _prevPivotDirty; }
		public function set prevPivotDirty(value:Boolean):void { _prevPivotDirty = value; }
		
		public function get nextFileDirty():Boolean { return _nextFileDirty; }
		public function set nextFileDirty(value:Boolean):void { _nextFileDirty = value; }
		
		public function get prevFileDirty():Boolean { return _prevFileDirty; }
		public function set prevFileDirty(value:Boolean):void { _prevFileDirty = value; }
		
		public function get modTransform():Transform { return _modTransform; }
		public function set modTransform(value:Transform):void { _modTransform = value; }
	}

}