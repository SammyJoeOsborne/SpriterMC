package com.sammyjoeosborne.spriter.utils 
{
	import flash.geom.Point;
	/**
	 * Just some functions needed internally.
	 * @author Sammy Joe Osborne
	 */
	public class TransformUtils 
	{
		
		public function TransformUtils() 
		{
			throw new Error("Do not instantiate TransformUtils. Use its static methods only.");
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
		public static function lerp($a:Number, $b:Number, $tweenFactor:Number):Number
		{
			return $a + ($b - $a) * $tweenFactor;
		}
		
		public static function rotatePoint($x:Number, $y:Number, $angle:Number, $parentX:Number, $parentY:Number):Point
		{
			var $sin:Number = Math.sin($angle * Math.PI / 180);
			var $cos:Number = Math.cos($angle * Math.PI / 180);
			var $newX:Number = ($x * $cos) - ($y * $sin);
			var $newY:Number = ($x * $sin) + ($y * $cos);
			$newX += $parentX;
			$newY += $parentY;
			
			return new Point($newX, $newY);	
		}
	}

}