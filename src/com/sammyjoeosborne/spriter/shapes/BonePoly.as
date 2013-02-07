package com.sammyjoeosborne.spriter.shapes 
{
	import com.sammyjoeosborne.primitives.IrregularPolygon;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	public class BonePoly extends DisplayObjectContainer
	{
		var _polygon:IrregularPolygon;
		
		public function BonePoly() 
		{
			_polygon = new IrregularPolygon(new <Point>[new Point(0, 0),
				new Point(20, -10),
				new Point(200, 0),
				new Point(20, 10)], 0xFFC4FC);
			_polygon.alpha = .5;
			addChild(_polygon);
		}
		
		public override function dispose():void
		{
			_polygon.dispose();
			super.dispose();
		}
		
	}

}