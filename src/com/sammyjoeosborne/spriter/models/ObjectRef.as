package com.sammyjoeosborne.spriter.models 
{
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	public class ObjectRef extends Ref
	{
		private var _zIndex:uint; //index in the display lists to have this object
		
		
		public function ObjectRef($id:uint, $timeline:Timeline, $key:Key = null) 
		{
			super($id, $timeline, $key);
		}
		
		public function get zIndex():uint { return _zIndex; }
		public function set zIndex(value:uint):void { _zIndex = value; }
		
	}

}