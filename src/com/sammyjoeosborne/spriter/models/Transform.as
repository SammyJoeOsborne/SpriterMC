package com.sammyjoeosborne.spriter.models 
{
	import com.sammyjoeosborne.spriter.utils.TransformUtils;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	public class Transform 
	{
		private var _x:Number;
		private var _y:Number;
		private var _angle:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		
		public function Transform($x:Number= 0, $y:Number = 0, $angle:Number = 0, $scaleX:Number = 1, $scaleY:Number = 1) 
		{
			_x = $x;
			_y = $y;
			_angle = $angle;
			_scaleX = $scaleX;
			_scaleY = $scaleY;
		}
		
		public function equals($t:Transform):Boolean
		{
			return(_x == $t.x && _y == $t.y && _angle == $t.angle && _scaleX == $t._scaleX && _scaleY == $t.scaleY);
		}
		
		public function transformLerp($transform:Transform, $tweenFactor:Number, $spin:int)
		{
			_x = TransformUtils.lerp(_x, $transform.x, $tweenFactor);
			_y = TransformUtils.lerp(_y, $transform.y, $tweenFactor);
			
			//spin should be derived from the key you're coming from, not the key you're going to
			if ($spin != 0)
			{
				if ($spin > 0 && _angle > $transform.angle)
				{
					_angle = TransformUtils.lerp(_angle, $transform.angle + 360, $tweenFactor);
				}
				else if ($spin < 0 && _angle < $transform.angle)
				{
					_angle = TransformUtils.lerp(_angle, $transform.angle - 360, $tweenFactor);
				}
				else
				{
					_angle = TransformUtils.lerp(_angle, $transform.angle, $tweenFactor);
				}
			}
			else
			{
				_angle = TransformUtils.lerp(_angle, $transform.angle, $tweenFactor);
			}
			
			_scaleX = TransformUtils.lerp(_scaleX, $transform.scaleX, $tweenFactor);
			_scaleY = TransformUtils.lerp(_scaleY, $transform.scaleY, $tweenFactor);
		}
		
		public function applyParentTransform($parent:Transform)
		{
			_x *= $parent.scaleX;
			_y *= $parent.scaleY;
			
			var $rPoint:Point = TransformUtils.rotatePoint(_x, _y, $parent.angle, $parent.x, $parent.y);
			_x = $rPoint.x;
			_y = $rPoint.y;
			
			_angle += $parent.angle;
			_scaleX *= $parent.scaleX;
			_scaleY *= $parent.scaleY;
		}
		
		public function toString():String
		{
			return "x: " + _x + " y: " + _y + " angle: " + _angle + " scaleX: " + _scaleX + " scaleY: " + _scaleY;
		}
		
		public function get x():Number {	return _x;}
		public function set x(value:Number):void{	_x = value;}
		
		public function get y():Number {	return _y;}
		public function set y(value:Number):void{	_y = value;}
		
		public function get angle():Number {	return _angle;}
		public function set angle(value:Number):void{	_angle = value;}
		
		public function get scaleX():Number {	return _scaleX;}
		public function set scaleX(value:Number):void{	_scaleX = value;}
		
		public function get scaleY():Number {	return _scaleY;}
		public function set scaleY(value:Number):void{	_scaleY = value;}
	}
	
	
}