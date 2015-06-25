package com.sammyjoeosborne.spriter.models 
{
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
		
		private var _rPoint:Point = new Point(); //optimization: avoids creating/disposing of this point during the rotation functions
		
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
		
		//Imagine a tween as a function of values. In linear it's a straight line, in quadratic it's curved, etc.
		//tweenFactor is essentially the position on that line from which we should get values.
		//Calculated by (currentTime - timeA)/(timeB - timeA), which should
		//calculate once per frame and passed to the lerp function.
		/**
		 * Linear interpolation. Will need to come up with other methods once other Tween types are integrated into Spriter...
		 * Imagine a tween as a function of values. In linear it's a straight line, in quadratic it's curved, etc.
		 * tweenFactor is essentially the position on that line from which we should get values.
		 * Calculated by (currentTime - timeA)/(timeB - timeA)
		 * @param	$a the first value
		 * @param	$b the second value
		 * @param	$tweenFactor
		 * @return
		 */
		[Inline]
		final private function lerp($a:Number, $b:Number, $tweenFactor:Number):Number
		{
			return $a + ($b - $a) * $tweenFactor;
		}
		
		//moving vars out here to save on object creation
		private var $sin:Number;
		private var $cos:Number;
		private var $newX:Number;
		private var $newY:Number;
		[Inline]
		final private function rotatePoint($x:Number, $y:Number, $angle:Number, $parentX:Number, $parentY:Number, $pointToModify:Point):void
		{
			$sin = Math.sin($angle * Math.PI / 180);
			$cos = Math.cos($angle * Math.PI / 180);
			$newX = ($x * $cos) - ($y * $sin);
			$newY = ($x * $sin) + ($y * $cos);
			$newX += $parentX;
			$newY += $parentY;
			
			$pointToModify.x = $newX;
			$pointToModify.y = $newY;
		}
		
		[Inline]
		final public function transformLerp($transform:Transform, $tweenFactor:Number, $spin:int):void
		{
			_x = lerp(_x, $transform.x, $tweenFactor);
			_y = lerp(_y, $transform.y, $tweenFactor);
			//_x = _x + ($transform.x - _x) * $tweenFactor; //manually inlining the lerp
			//_y = _y + ($transform.y - _y) * $tweenFactor; //manually inlining the lerp
			
			//spin should be derived from the key you're coming from, not the key you're going to
			if ($spin != 0)
			{
				if ($spin > 0 && _angle > $transform.angle)
				{
					_angle = lerp(_angle, $transform.angle + 360, $tweenFactor);
					//_angle = _angle + (($transform.angle +360) - _angle) * $tweenFactor; //manual inline lerping
				}
				else if ($spin < 0 && _angle < $transform.angle)
				{
					_angle = lerp(_angle, $transform.angle - 360, $tweenFactor);
					//_angle = _angle + (($transform.angle-360) - _angle) * $tweenFactor; //manual inline lerping
				}
				else
				{
					_angle = lerp(_angle, $transform.angle, $tweenFactor);
					//_angle = _angle + ($transform.angle - _angle) * $tweenFactor; //manual inline lerping
				}
			}
			else
			{
				_angle = lerp(_angle, $transform.angle, $tweenFactor);
				//_angle = _angle + ($transform.angle - _angle) * $tweenFactor; //manual inline lerping
			}
			
			_scaleX = lerp(_scaleX, $transform.scaleX, $tweenFactor);
			_scaleY = lerp(_scaleY, $transform.scaleY, $tweenFactor);
			//_scaleX = _scaleX + ($transform.scaleX - _scaleX) * $tweenFactor; //manual inline lerping
			//_scaleY = _scaleY + ($transform.scaleY - _scaleY) * $tweenFactor; //manual inline lerping
		}
		
		[Inline]
		final public function applyParentTransform($parent:Transform):void
		{
			_x *= $parent.scaleX;
			_y *= $parent.scaleY;
			
			rotatePoint(_x, _y, $parent.angle, $parent.x, $parent.y, _rPoint);
			_x = _rPoint.x;
			_y = _rPoint.y;
			
			_angle += $parent.angle;
			_scaleX *= $parent.scaleX;
			_scaleY *= $parent.scaleY;
		}
		
		[Inline]
		final public function copyValues($t:Transform):Transform
		{
			_x = $t.x;
			_y = $t.y;
			_scaleX = $t.scaleX;
			_scaleY = $t.scaleY;
			_angle = $t.angle;
			
			return this;
		}
		
		public function clone():Transform
		{
			return new Transform(_x, _y, _angle, _scaleX, _scaleY);
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