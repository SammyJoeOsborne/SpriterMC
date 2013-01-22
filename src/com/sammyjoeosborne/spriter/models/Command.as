package com.sammyjoeosborne.spriter.models 
{
	/**
	 * 1/20/2013 10:29 AM
	 * @author Sammy Joe Osborne
	 */
	public class Command 
	{
		private var _method:Function;
		private var _params:Array = null;
		
		public function Command($method:Function, $params:Array = null) 
		{
			_method = $method;
			_params = $params;
		}
		
		public function get method():Function { return _method; }
		
		public function get params():Array { return _params; }	
		
		public function callMethod($thisArg:*):void
		{
			_method.apply($thisArg, _params);
		}
	}

}