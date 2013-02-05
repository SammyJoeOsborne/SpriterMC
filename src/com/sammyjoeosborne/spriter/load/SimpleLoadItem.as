package com.sammyjoeosborne.spriter.load 
{
	import flash.net.URLRequest;
	/**
	 * 2/4/2013 8:09 PM
	 * @author Sammy Joe Osborne 
	 */
	public class SimpleLoadItem
	{
		private var _id:String;
		private var _url:String;
		private var _data:Object;
		
		public function SimpleLoadItem($id:String, $url:String, $data:Object = null) 
		{
			_id = $id;
			_url = $url;
			_data = $data;
		}
		
		
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void { _data = value; }
		
		public function get url():String { return _url; }
		public function set url(value:String):void { _url = value; }
		
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
		
	}

}