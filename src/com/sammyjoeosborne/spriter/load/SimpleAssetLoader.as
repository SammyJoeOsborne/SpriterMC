package com.sammyjoeosborne.spriter.load 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import starling.events.EventDispatcher;
	/**
	 * 2/4/2013 8:07 PM
	 * @author Sammy Joe Osborne
	 */
	public class SimpleAssetLoader extends EventDispatcher
	{
		static public const ALL_ITEMS_COMPLETE:String = "allItemsComplete";		
		
		private var _queue:Vector.<SimpleLoadItem> = new Vector.<SimpleLoadItem>();
		private var _totalItems:uint = 0;
		private var _totalItemsLoaded:uint = 0;
		private var _currentItemIndex:uint = 0;
		
		public function SimpleAssetLoader() 
		{
			
		}
		
		public function startLoad():void
		{
			if (_totalItems > 0) 
			{
				trace("START LOAD CALLED");
				loadNextItem();
			}
		}
		
		public function addItem($url:String, $data:Object = null):void
		{
			_queue.push(new SimpleLoadItem(_totalItems.toString(), $url, $data));
			_totalItems++;
		}
		
		private function loadNextItem():void 
		{
			var $simpleLoader:SimpleLoader = new SimpleLoader();
			$simpleLoader.simpleLoadItem = _queue[_currentItemIndex];
			$simpleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, itemCompleteHandler);
			$simpleLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, iOErrorCatch, false, 0, true);
			$simpleLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorCatch, false, 0, true);
			
			
			_currentItemIndex++;
			$simpleLoader.load(new URLRequest($simpleLoader.simpleLoadItem.url));
		}
		
		private function itemCompleteHandler($e:Event)
		{
			var $simpleLoader:SimpleLoader = $e.target.loader as SimpleLoader;
			_totalItemsLoaded++;
			dispatchEventWith("complete", false, $simpleLoader);
			
			if (_totalItemsLoaded == _totalItems)
			{
				allItemsComplete();
			}
			else
			{
				loadNextItem();
			}
		}
		
		private function iOErrorCatch($e:IOErrorEvent):void 
		{
			trace("well, wtf: " + SimpleLoader($e.target).simpleLoadItem.url)
			throw new Error("IOError: " + $e.text);
		}
		
		private function securityErrorCatch($e:SecurityErrorEvent):void 
		{
			throw new Error("Security error: " + $e.text);
		}
		
		private function allItemsComplete():void
		{
			_queue.length = 0;
			dispatchEventWith(ALL_ITEMS_COMPLETE, false);
		}
		
	}

}