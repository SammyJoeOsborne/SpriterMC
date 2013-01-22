/** SpriterMC: a Starling implementation for importing skeletal 
 * (and non-skeletal) animations generated with Spriter (http://www.brashmonkey.com/spriter.htm)
 *
 *   @author Sammy Joe Osborne
 *   http://www.sammyjoeosborne.com
 *   https://github.com/SammyJoeOsborne/SpriterMC
 */

/**
 * Licensed under the MIT License
 *
 * Copyright (c) 2013 Sammy Joe Osborne
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

package com.sammyjoeosborne.spriter 
{
	import com.sammyjoeosborne.spriter.data.TexturePack;
	import com.sammyjoeosborne.spriter.data.ScmlData;
	import com.sammyjoeosborne.spriter.utils.ScmlParser;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import starling.events.EventDispatcher;
	import starling.textures.TextureAtlas;
	
	/**
	 * 1/15/2013 7:06 PM
	 * @author Sammy Joe Osborne
	 */
	public class SpriterMCFactory extends EventDispatcher
	{
		private static var _currentSCML:XML;
		private static var _currentName:String;
		private static var _spriterMCs:Vector.<SpriterMC> = new Vector.<SpriterMC>();
		private static var _scmlDatas:Vector.<ScmlData> = new Vector.<ScmlData>();
		private static var _texturePacks:Vector.<TexturePack> = new Vector.<TexturePack>();
		
		public function SpriterMCFactory() 
		{
			throw new Error("Do not instantiate SpriterMCFactory class. Only use its static methods.");
		}

		/**
		 * Defines a new SpriterMC generated from the SCML file specified in $scmlPath
		 * @param	$scmlPath The path to the SCML file used to create this SpriterMC.
		 * @param	$name This is the unique identifying name for a new SpriterMC type, such as "Hero".
		 * @param	$returnInstance Set to false to avoid creating a SpriterMC instance if you do not need one yet
		 * @return  A new instance of this new SpriterMC; null if $returnInstance is false
		 * @throws  Error if the name is not unique
		 */
		public static function createSpriterMC($name:String, $scmlPath:String, $textureAtlas:TextureAtlas = null, $onReadyCallback:Function = null, $returnInstance:Boolean = true):SpriterMC
		{
			if (!nameExists($name, getScmlDataNames()))
			{
				var $scmlData:ScmlData 			= new ScmlData($name, $scmlPath);
				var $texturePack:TexturePack 	= new TexturePack($name, $textureAtlas);
				var $scmlParser:ScmlParser 		= new ScmlParser($scmlData);
				$scmlParser.addEventListener(ScmlParser.FILES_ESTABLISHED, $texturePack.filesEstablishedHandler);
				$scmlParser.start();
				
				_scmlDatas.push($scmlData);
				_texturePacks.push($texturePack);
				
				if ($returnInstance)
				{
					//Create SpriterMC instance
					return generateInstance($name, $onReadyCallback, $name);
				}
				
				else return null;
			}
			else
			{
				throw new Error("A SpriterMC by the name + \"" + $name + "\" already exists. Please use a unique name.");
			}
		}
		
		/**
		 * Returns a new instance of the SpriterMC requested by $name.
		 * @throws Error if a SpriterMC by the specified name does not exist
		 * @param  $name The name of the SpriterMC
		 * @param  $onReadyCallback Optional parameter, function to call once this SpriterMC is ready
		 * @param  $altTexturePack Optional parameter, if you want to use a TexturePack other than the default
		 * @return A new instance of the SpriterMC requested by $name
		 */
		public static function generateInstance($name:String, $onReadyCallback:Function = null, $altTexturePack:String = ""):SpriterMC
		{
			if ($altTexturePack == "") $altTexturePack = $name;
			var $sd:ScmlData 	= getScmlData($name);
			var $tp:TexturePack = getTexturePack($altTexturePack);
			
			if (!$sd) throw new Error("SCMLData " + $name + " did not exist.");
			else if (!$tp) throw new Error("TexturePack \"" + $altTexturePack + "\" did not exist.");
			
			//create instance and return it
			else
			{
				var $spriterMC:SpriterMC = new SpriterMC($sd, $tp, $onReadyCallback);
				return $spriterMC;
			}
		}
		
		static private function nameExists($name:String, $namesVector:Vector.<String>):Boolean 
		{
			var $length:uint = $namesVector.length;
			for (var i:int = 0; i < $length; i++) 
			{
				if ($namesVector[i] == $name) return true;
			}
			return false;
		}
		
		/**
		 * Returns a Vector<String> of names of all TexturePacks that exist
		 * @return A Vector of Strings representing the TexturePack names that exist
		 */
		public static function getTexturePackNames():Vector.<String>
		{
			var $namesVec:Vector.<String> = new Vector.<String>();
			var $length:uint = _texturePacks.length;
			for (var i:int = 0; i < $length; i++) 
			{
				$namesVec.push(_scmlDatas[i].name);
			}
			return $namesVec;
		}
		
		/**
		 * Returns a Vector<String> of names representing all ScmlData that exist
		 * @return A Vector of Strings representing the ScmlData names that exist
		 */
		public static function getScmlDataNames():Vector.<String> 
		{
			var $namesVec:Vector.<String> = new Vector.<String>();
			var $length:uint = _scmlDatas.length;
			for (var i:int = 0; i < $length; i++) 
			{
				$namesVec.push(_scmlDatas[i].name);
			}
			return $namesVec;
		};
		
		/**
		 * Disposes of the ScmlData and TexturePack of the specified SpriterMC name.
		 * This will effect any SpriterMC instances you currently have in existence that use these assets,
		 * so be sure you take care of those SpriterMCs first
		 * @param	$name Name of the SpriterMC and TexturePack you want to dispose of.
		 * @param	$disposeOfTexturePack Boolean specifying if you want to dispose the TexturePack of the same name
		 */
		public static function dispose($name:String, $disposeOfTexturePack:Boolean = true):void
		{
			var $sd:ScmlData = getScmlData($name);
			disposeScmlData($sd);
			if ($disposeOfTexturePack)
			{
				var $tp:TexturePack = getTexturePack($name);
				disposeTexturePack($tp);
			}
		}
		
		/**
		 * Allows you to register a ScmlData with the SpriterMCFactory, and won't create the TexturePack from the assets referenced in the SCML.
		 * This could be useful for creating SpriterMCs with custom TexturePacks, perhaps generated from a SpriterSheet
		 * @param	$texturePack The TexturePack to add
		 * @throws  Error if the TexturePack by the same name already exists
		 */
		public static function addScmlData($scmlData:ScmlData):void
		{
			if (!nameExists($scmlData.name, getScmlDataNames()))
			{
				_scmlDatas.push($scmlData);
			}
			else throw new Error("Cannot add ScmlData \"" + $scmlData.name + "\". A ScmlData by that name already exists.");
		}
		
		/**
		 * Deletes the ScmlData from this SpriterMCFactor's TexturePack collection
		 * @param	$scmlData The ScmlData to dispose of
		 */
		public static function disposeScmlData($scmlData:ScmlData):void
		{
			var $index:int = _scmlDatas.indexOf($scmlData);
			if ($index != -1)
			{
				_scmlDatas.splice($index, 1);
			}
		}
		
		/**
		 * Allows you to register a TexturePack with the factory without having to create a whole SpriterMC from an SCML file.
		 * This could be useful for adding TexturePacks generated (somehow...) from SpriteSheets instead of SCML.
		 * @param	$texturePack The TexturePack to add
		 * @throws  Error if the TexturePack by the same name already exists
		 */
		public static function addTexturePack($texturePack:TexturePack):void
		{
			if (!nameExists($scmlData.name, getScmlDataNames()))
			{
				_scmlDatas.push($scmlData);
			}
			else throw new Error("Cannot add TexturePack \"" + $texturePack.name + "\". A TexturePack by that name already exists.");
		}
		
		/**
		 * Disposes all Textures within a TexturePack, and deletes it from this SpriterMCFactor's TexturePack collection
		 * @param	$texturePack
		 */
		public static function disposeTexturePack($texturePack:TexturePack):void
		{
			var $index:int = _texturePacks.indexOf($texturePack);
			if ($index != -1)
			{
				$texturePack.dispose();
				_texturePacks.splice($index, 1);
			}
		}
		
		/**
		 * Returns the requested ScmlData by name.
		 * @param	$name The name of the ScmlData you would like
		 * @return  Returns the request ScmlData, null if not found
		 */
		public static function getScmlData($name:String):ScmlData
		{
			var $length:uint = _scmlDatas.length;
			for (var i:int = 0; i < $length; i++) 
			{
				if (_texturePacks[i].name == $name) return _scmlDatas[i];
			}
			
			return null;
		}
		
		/**
		 * Returns the requested TexturePack by name.
		 * @param	$name The name of the ScmlData you would like
		 * @return  Returns the request TexturePack, null if not found
		 */
		public static function getTexturePack($name:String):TexturePack
		{
			var $length:uint = _texturePacks.length;
			for (var i:int = 0; i < $length; i++) 
			{
				if (_texturePacks[i].name == $name) return _texturePacks[i];
			}
			
			return null;
		}
		
		
		
	}

}