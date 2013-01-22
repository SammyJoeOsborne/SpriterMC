package com.sammyjoeosborne.spriter.models 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.display.Quad;
	import starling.display.Sprite;
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
		private var _x:Number;
		private var _y:Number;
		private var _pivot:Point;
		private var _angle:Number = 0;
		private var _scaleX:Number; 
		private var _scaleY:Number; 
		private var _timeline:Timeline; //the timeline this key is a part of
		
		private var _prev:Key = null; //reference to the previous key in this timeline
		private var _next:Key = null; //reference to the next key in this timeline
		
		public function Key($id:uint, $time:uint, $spin:int) 
		{
			_id = 		$id;
			_time = 	$time;
			_spin = 	$spin;		
		}
		
		public function toString():String
		{
			return ("id: " + _id + " time: " + _time + " spin: " + _spin + " x: " + _x + " y: " + _y
				+ " angle: " + _angle + " folder: " + _folder + " file: " + _file);
		}
		
		public function get id():uint { return _id; }
		
		public function get time():uint { return _time; }
		
		public function get spin():int { return _spin; }
		
		public function get folder():uint { return _folder; }
		public function set folder(value:uint):void { _folder = value; }
		
		public function get file():uint { return _file; }
		public function set file(value:uint):void { _file = value; }
		
		public function get x():Number { return _x; }
		public function set x(value:Number):void { 
			_x = value;
			
		}
		
		public function get y():Number { return _y; }
		public function set y(value:Number):void { 
			_y = value;
		}
		
		public function get pivot():Point { return _pivot; }
		public function set pivot(value:Point):void { _pivot = value; }
		
		public function get angle():Number { return _angle; }
		public function set angle(value:Number):void {
			_angle = value;
			
		}
				
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void {
			_scaleX = value;
			
		}
		
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void { 
			_scaleY = value;
			
		}
		
		public function get timeline():Timeline { return _timeline; }
		public function set timeline(value:Timeline):void { _timeline = value; }
		
		public function get prev():Key { return _prev; }
		public function set prev(value:Key):void { _prev = value; }
		
		public function get next():Key { return _next; }
		public function set next(value:Key):void { _next = value; }
		
	}

}