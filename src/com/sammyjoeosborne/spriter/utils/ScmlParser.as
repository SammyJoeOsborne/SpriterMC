package com.sammyjoeosborne.spriter.utils 
{
	import com.sammyjoeosborne.spriter.data.ScmlData;
	import com.sammyjoeosborne.spriter.models.AnimationData;
	import com.sammyjoeosborne.spriter.models.BoneRef;
	import com.sammyjoeosborne.spriter.models.File;
	import com.sammyjoeosborne.spriter.models.Folder;
	import com.sammyjoeosborne.spriter.models.Key;
	import com.sammyjoeosborne.spriter.models.MainKey;
	import com.sammyjoeosborne.spriter.models.ObjectRef;
	import com.sammyjoeosborne.spriter.models.Timeline;
	import flash.geom.Point;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import starling.events.EventDispatcher;
	/**
	 * For internal use only, really. Loads and parses a provided SCML file path and creates the requisite ScmlData and gets the whole TexturePack process started.
	 * @author Sammy Joe Osborne
	 */
	public class ScmlParser extends EventDispatcher
	{
		static public const FILES_ESTABLISHED:String = "filesEstablished";
		var _scmlData:ScmlData;
		
		public function ScmlParser($scmlData:ScmlData) 
		{
			_scmlData = $scmlData;
		}
		
		public function start():void
		{
			loadSCML(_scmlData.scmlFilepath);
		}
		
		private function onSCMLComplete($e:Event):void
		{
			_scmlData.scmlXML = XML($e.target.data);
			parseScml(_scmlData);
		}
		
		private function parseScml($scmlData:ScmlData):void
		{
			createFoldersAndFiles($scmlData);
			trace("Scml files and folders parsed. Sending to TexturePack");
			dispatchEventWith(FILES_ESTABLISHED, false);
			createTimelines(_scmlData);
			createMainlineKeys(_scmlData);
			
			$scmlData.disposeXML();
			$scmlData.isReady = true;
			trace("ScmlData ready");
			$scmlData.dispatchEventWith(ScmlData.SCML_READY);			
		}
		
		private function createFoldersAndFiles($scmlData:ScmlData):void
		{
			var $scmlXML:XML = $scmlData.scmlXML;
			var $folderXMLList:XMLList = $scmlXML.folder;
			var $filenameXMLList:XMLList;
			var $folderLength:uint = $folderXMLList.length();
			var $fileLength:uint;
			
			var $folder:Folder;
			for (var i:uint = 0; i < $folderLength; i++)
			{
				$folder = new Folder(i, $folderXMLList[i].@name);
				$filenameXMLList = $folderXMLList[i].file;
				$fileLength = $filenameXMLList.length();
				for (var k:uint = 0; k < $fileLength; k++)
				{
					$folder.addFile(new File(k, $filenameXMLList[k].@name.toString(), Number($filenameXMLList[k].@width), Number($filenameXMLList[k].@height)));
					//$filenameVec.push(Utils.getFileNameWithoutExtension($filenameXMLList[k].@name.toString()));
				}
				
				$scmlData.folders.push($folder);
			}
		}
		
		private function createTimelines($scmlData:ScmlData):void
		{
			var $scmlXML:XML = $scmlData.scmlXML;
			var $animationList:XMLList = $scmlXML.entity.animation;
			var $animationData:AnimationData;
			var $timelineList:XMLList;
			var $keyList:XMLList;
			var $keyXML:XML;
			var $timeline:Timeline;
			var $name:String;
			var $key:Key;
			
			//key props
			var $id:uint;
			var $time:uint;
			var $spin:int;
			var $folder:uint;
			var $file:uint;
			var $pivotX:Number;
			var $pivotY:Number;
			var $angle:Number;
			
			var $numAnimations:uint = $animationList.length();
			for (var i:uint = 0; i < $numAnimations; i++)
			{
				$animationData = new AnimationData();
				$animationData.totalTime = parseInt($animationList[i].@length)
				$animationData.name = $animationList[i].@name;
				//if looping exists, use value. Otherwise, assume true
				if ($animationList[i].hasOwnProperty("@looping"))
				{
					$animationData.loop = ($animationList[i].@looping == "true") ? true : false;
				}
				
				//create timeline objects
				$timelineList = $animationList[i].timeline;
				for (var k:int = 0; k < $timelineList.length(); k++) 
				{
					$timeline = new Timeline(parseInt($timelineList[k].@id), ($timelineList[k].hasOwnProperty("@name")) ? $timelineList[k].@name : "");
					
					$animationData.timelines.push($timeline);
					
					//create key objects within the timeline
					$keyList = $timelineList[k].key;
					for (var j:int = 0; j < $keyList.length(); j++) 
					{
						$keyXML = $keyList[j];
						//either bone or object
						var $prop:String = $keyXML.hasOwnProperty("object") ? "object" : "bone";
						$id = parseInt($keyXML.@id);
						$time = ($keyXML.hasOwnProperty("@time")) ? parseInt($keyXML.@time) : 0;
						$spin = ($keyXML.hasOwnProperty("@spin")) ? parseInt($keyXML.@spin) : 1; //1 should be default if no spin is included
						
						//if this is the first keyframe in the timeline, create it.
						if (j == 0)
						{
							$key= new Key($id, $time, $spin);
						}
						//if it's not the first keyframe in this timeline, assign this new 
						//keyframe to the previous keyframe's next property
						else
						{
							$key.next = new Key($id, $time, $spin);
							$key = $key.next;
						}
						//There are certain properties that don't exist on bones, only on objects: folder, file, pivots
						if ($prop == "object")
						{
							$key.folder =  parseInt($keyXML.object.@folder);
							$key.file = parseInt($keyXML.object.@file);
							$pivotX = ($keyXML.object.hasOwnProperty("@pivot_x")) ? Number($keyXML.object.@pivot_x) : 0;
							$pivotY = ($keyXML.object.hasOwnProperty("@pivot_y")) ? Number($keyXML.object.@pivot_y) : 1;
							$key.pivot = new Point($pivotX, $pivotY);
						}
						else
						{
							//dunno if this is needed but marking timeline as for a bone
							$timeline.isBone = true;
						}
						
						$key.x = ($keyXML[$prop].hasOwnProperty("@x")) ? Number($keyXML[$prop].@x) : 0;
						$key.y = ($keyXML[$prop].hasOwnProperty("@y")) ? Number($keyXML[$prop].@y) : 0;
						if ($keyXML[$prop].hasOwnProperty("@angle"))
						{
							$key.angle =  Number($keyXML[$prop].@angle);
						}
						else
						{
							$key.angle = 0;
						}
						
						$key.scaleX = ($keyXML[$prop].hasOwnProperty("@scale_x")) ? Number($keyXML[$prop].@scale_x) : 1;
						$key.scaleY = ($keyXML[$prop].hasOwnProperty("@scale_y")) ? Number($keyXML[$prop].@scale_y) : 1;
						
						$key.timeline = $timeline;
						//assign previous frame
						$key.prev = (j != 0) ? $timeline.keys[j - 1] : null;
						
						$timeline.keys.push($key);
						
					}
				}
				
				$scmlData.animationDatas.push($animationData);
			}
			
		}
		
		private function createMainlineKeys($scmlData:ScmlData):void 
		{
			var $scmlXML:XML = $scmlData.scmlXML;
			var $animationData:AnimationData;
			var $animationList:XMLList;
			
			var $keyList:XMLList = $scmlXML.entity.animation[0].mainline.key;
			var $keyXML:XML;
			var $mainKey:MainKey;
			var $id:uint;
			var $time:uint;
			var $parentID:uint;
			var $parent:BoneRef;
			
			var $boneRefList:XMLList;
			var $objRefList:XMLList;
			var $objXML:XML;
			var $boneRef:BoneRef;
			var $objectRef:ObjectRef;
			var $timeline:Timeline;
			var $key:Key;
			var $parentKey:Key;
			
			var $length:uint = $scmlData.animationDatas.length;
			for (var i:uint = 0; i < $length; i++)
			{
				$animationData = $scmlData.animationDatas[i];
				$keyList = $scmlXML.entity.animation[i].mainline.key;
				for (var k:int = 0; k < $keyList.length(); k++) 
				{
					$keyXML = $keyList[k];
					$id = parseInt($keyXML.@id);
					$time = ($keyXML.hasOwnProperty("@time")) ? parseInt($keyXML.@time) : 0;
					$mainKey = new MainKey($keyXML.@id, $time);
					
					//add all bone refs
					$boneRefList = $keyXML.bone_ref;
					for (var j:int = 0; j < $boneRefList.length(); j++) 
					{
						$objXML = $boneRefList[j];
						$id = parseInt($objXML.@id);
						$timeline = $animationData.timelines[(parseInt($objXML.@timeline))];
						$key = $timeline.keys[parseInt($objXML.@key)];
						$boneRef = new BoneRef($id, $timeline, $key);
						//trace($objXML.@parent)
						$boneRef.parentID = ($objXML.hasOwnProperty("@parent")) ? parseInt($objXML.@parent) : -1;
						if ($boneRef.parentID != -1) 
						{
							$boneRef.parent = $mainKey.boneRefs[$boneRef.parentID];
						}
						
						$mainKey.boneRefs.push($boneRef);
					}
					
					//add all object refs
					$objRefList = $keyXML.object_ref;
					for (j = 0; j < $objRefList.length(); j++)
					{
						$objXML = $objRefList[j];
						$id = parseInt($objXML.@id);
						$timeline = $animationData.timelines[(parseInt($objXML.@timeline))];
						if ($timeline.keys.length)
						{
							$key = $timeline.getKeyByID(parseInt($objXML.@key));
						}
						$objectRef = new ObjectRef($id, $timeline, $key);
						$objectRef.parentID = ($objXML.hasOwnProperty("@parent")) ? parseInt($objXML.@parent) : -1;
						if ($objectRef.parentID != -1) 
						{
							$objectRef.parent = $mainKey.boneRefs[$objectRef.parentID];
						}
						
						$mainKey.objectRefs.push($objectRef);
					}
					
					$animationData.mainKeys.push($mainKey);
				}
				
				//if the last keyframe doesn't fall at the very end of the animation, clone it and
				//insert it at the end so the last frame holds until the end of the animation
				if ($animationData.mainKeys[k-1].time < $animationData.totalTime)
				{
					var $endingKey:MainKey = $animationData.mainKeys[k-1].clone();
					$endingKey.id++;
					$endingKey.time = $animationData.totalTime;
					$animationData.mainKeys.push($endingKey);
					//trace("there was no ending frame. Adding mainKey at " + $animation.totalTime);
				}
				/*else
				{
					trace("key fell on last frame. not adding ending frame.");
				}*/
			}
		}
		
		public function loadSCML($path:String)
		{
			var $loader:URLLoader = new URLLoader();
			$loader.addEventListener(Event.COMPLETE, onSCMLComplete);
			$loader.addEventListener(ErrorEvent.ERROR, onError);
			$loader.load(new URLRequest($path));
		}
		
		private function onError($e:Event):void
		{
			throw new Error("Error loading " + $e.toString());
		}
		
		public function get scmlData():ScmlData { return _scmlData; }
		
	}

}