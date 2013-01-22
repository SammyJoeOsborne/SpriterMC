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

package com.sammyjoeosborne.spriter.data 
{
	import com.emibap.textureAtlas.DynamicAtlas;
	import com.sammyjoeosborne.spriter.models.File;
	import com.sammyjoeosborne.spriter.models.Folder;
	import com.sammyjoeosborne.spriter.utils.ScmlParser;
	import com.stimuli.loading.BulkLoader;
	import com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import starling.events.Event;
	import starling.display.Image;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * 1/14/2013 7:15 PM
	 * @author Sammy Joe Osborne
	 * TexturePack is a class holding the Textures from which we can derive Images for a 
	 * SpriterMC Animation. We store Textures instead of Images so that we may duplicate
	 * a SpriterMC instance if desired.
	 * A SpriterMC can switch out the TexturePack it's using at any time, so long as the TexturePack
	 * meets the expected requirements of the SpriterMC instance.
	 *  (TODO) If the assets don't match what the SpriterMC is expecting/needing, an error is thrown.
	 */
	public class TexturePack extends EventDispatcher
	{
		static public const TEXTURE_PACK_READY:String = "TexturePackReady";
		
		private var _name:String;
		private var _textureAtlas:TextureAtlas;
		private var _folders:Vector.<Folder> = new Vector.<Folder>();
		private var _isReady:Boolean = false;
		private var _loadedAssets:Vector.<MovieClip>;
		private var _imageVec:Vector.<Vector.<Image>>
		
		public function TexturePack($name:String, $textureAtlas:TextureAtlas) 
		{
			_name = $name;
			_textureAtlas = $textureAtlas;
		}
		
		public function filesEstablishedHandler($e:Event):void
		{
			var $scmlData:ScmlData = ScmlParser($e.target).scmlData;
			createTexturePack($scmlData);
		}
		
		public function createTexturePack($scmlData:ScmlData):void
		{
			_folders = $scmlData.folders;
			(_textureAtlas) ? loadTexturesFromTextureAtlas(_textureAtlas) : loadTextures();
		}
		
		public function addFolder($folder:Folder):void
		{
			_folders.push($folder);
		}
		
		public function getTexture($folderID:uint, $fileID:uint):Texture
		{
			return _folders[$folderID].files[$fileID].texture;
		}
		
		public function generateImageVector():Vector.<Vector.<Image>>
		{
			var $imageVec:Vector.<Vector.<Image>> = new Vector.<Vector.<Image>>();
			var $folderLength:uint = _folders.length;
			var $filesLength:uint;
			for (var i:int = 0; i < $folderLength; i++) 
			{
				$imageVec.push(new Vector.<Image>());
				$filesLength = _folders[i].files.length;
				for (var j:int = 0; j < $filesLength; j++)
				{
					$imageVec[i].push(new Image(_folders[i].files[j].texture));
				}
			}
			
			return $imageVec;
		}
		
		public function loadTexturesFromTextureAtlas($atlas:TextureAtlas):void
		{
			//trace("-----------------loading textures from atlas");
			if (!_isReady)
			{
				var $allFilenames:Vector.<String> = new Vector.<String>();
				var $folder:Folder;
				var $file:File;
				var $foldersLength:uint = _folders.length;
				var $filesLength:uint;
				var $id:String;
				var $name:String;
				//go through the files and match up their texture in the atlas
				var $duplicateFound:Boolean = false;
				for (var i:int = 0; i < $foldersLength; i++)
				{
					$folder = _folders[i];
					$filesLength = $folder.files.length;
					for (var j:int = 0; j < $filesLength; j++) 
					{
						$file = $folder.files[j];
						$name = getFileNameWithoutExtension($file.name);
						//check for duplicates and throw error if there is a duplicate filename
						if ($allFilenames.indexOf($name) != -1)
						{
							throw new Error("A texture by the name \"" + $name + "\" already exists. Please make all asset names unique so we can use a TextureAtlas.");
						}
						$allFilenames.push($name);
						
						var $texture:Texture = $atlas.getTexture($name);
						if ($texture)
						{
							$file.texture = $atlas.getTexture($name);
						}
						else
						{
							throw new Error("Texture " + $name + " did not exist in the provided TextureAtlas. Check the pathing in your SCML file, as it should match the TextureAtlas XML. Existing textures in this atlas are: " + $atlas.getNames() + ".");
						}
					}
				}
				
				setIsReady();
			}
		}
		
		public function loadTextures():void
		{
			trace("loading textures from individual files");
			_loadedAssets = new Vector.<MovieClip>();
			if (!_isReady)
			{
				//I'm not a fan of BulkLoader...this is temporary until I can write a similar load manager to the proprietary one we use at my work. It's the shizzle.
				var $bulkLoader:BulkLoader = new BulkLoader();
				var $folder:Folder;
				var $foldersLength:uint = _folders.length;
				var $filesLength:uint;
				var $id:String;
			
				for (var i:int = 0; i < $foldersLength; i++) 
				{
					$folder = _folders[i];
					$filesLength = $folder.files.length;
					for (var j:int = 0; j < $filesLength; j++) 
					{
						$id = $folder.files[j].name;
						$bulkLoader.add($folder.files[j].name, { "id":$id } ).addEventListener(Event.COMPLETE, itemCompleteHandler);
					}
				}
				
				$bulkLoader.addEventListener(BulkLoader.COMPLETE, allFilesLoadedHandler);
				$bulkLoader.start();
			}
			else throw new Error("TexturePack " + _name + " already loaded all textures.");
		}
		
		private function allFilesLoadedHandler($e:*):void 
		{
			//TODO: turn loaded files into one big Texture and create a texture atlas out of it
			//trace("TexturePack " + _name + " loaded all textures successfully.");
			createTextureAtlas();
		}
		
		private function createTextureAtlas():void 
		{
			var $mc:MovieClip = new MovieClip();
			var $length:uint = _loadedAssets.length;
			for (var i:int = 0; i < $length; i++)
			{
				$mc.addChild(_loadedAssets[i]);
			}
			
			//dynamically creates TextureAtlas
			_textureAtlas = DynamicAtlas.fromMovieClipContainer($mc);
			
			//TextureAtlas is created, so now remove all individual assets since we no longer need them
			for (i = 0; i < $length; i++)
			{
				//trace("trashing indivual asset");
				Bitmap(_loadedAssets[i].getChildAt(0)).bitmapData.dispose();
				_loadedAssets[i] = null;
			}
			_loadedAssets.length = 0;
			$mc = null;
			
			loadTexturesFromTextureAtlas(_textureAtlas);
		}
		
		private function itemCompleteHandler($e:*):void 
		{
			var $loadingItem:LoadingItem = LoadingItem($e.target);
			var $id:String = getFileNameWithoutExtension($loadingItem.id);
			var $bitmapMC:MovieClip = new MovieClip();
			$bitmapMC.name = $id;
			$bitmapMC.addChild(Bitmap($loadingItem.content));
			_loadedAssets.push($bitmapMC);
		}
		
		private function setIsReady():void
		{
			trace("TexturePack " + _name + " loaded all textures successfully.");
			_isReady = true;
			_imageVec = generateImageVector();
			dispatchEventWith(TEXTURE_PACK_READY);
		}
		
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		public function get isReady():Boolean { return _isReady; }
		
		public function get imageVec():Vector.<Vector.<Image>> { return _imageVec; }
		
		public function dispose():void
		{
			var $length:uint = _folders.length;
			for (var i:int = 0; i < $length; i++) 
			{
				_folders[i].dispose();
			}
			
			_folders.length = 0; _folders = null;
			_imageVec.length = 0; _imageVec = null;
			_loadedAssets.length = 0; _loadedAssets = null;
		}
		
		/****************************************
		 * HELPER FUNCTIONS
		 * *************************************/
		
		private function getFileNameWithoutExtension($file:String):String
		{
			/*var nameStart:int = $file.lastIndexOf("/");
			nameStart = (nameStart == -1) ? 0 : nameStart + 1;*/
			var $nameStart:int = 0;
			
			var $nameEnd:int = $file.lastIndexOf(".");
			$nameEnd = ($nameEnd == -1) ? $file.length : $nameEnd;
			return $file.substring($nameStart, $nameEnd);
		}
	}

}