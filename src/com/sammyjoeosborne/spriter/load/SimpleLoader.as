package com.sammyjoeosborne.spriter.load 
{
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sammy Joe Osborne
	 */
	public class SimpleLoader extends Loader
	{
		
		private var _simpleLoadItem:SimpleLoadItem;
		
		public function SimpleLoader():void 
		{
			super();
		}
		
		public function get simpleLoadItem():SimpleLoadItem { return _simpleLoadItem; }
		public function set simpleLoadItem(value:SimpleLoadItem):void { 
			_simpleLoadItem = value;
		}
		
	}

}