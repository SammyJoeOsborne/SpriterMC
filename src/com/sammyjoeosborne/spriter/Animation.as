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
	import com.sammyjoeosborne.spriter.models.AnimationData;
	import com.sammyjoeosborne.spriter.models.BoneRef;
	import com.sammyjoeosborne.spriter.models.Command;
	import com.sammyjoeosborne.spriter.models.Key;
	import com.sammyjoeosborne.spriter.models.MainKey;
	import com.sammyjoeosborne.spriter.models.ObjectRef;
	import com.sammyjoeosborne.spriter.models.Timeline;
	import com.sammyjoeosborne.spriter.models.Transform;
	import com.sammyjoeosborne.spriter.utils.BoneTexture;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/** <p>Used by SpriterMC (you shouldn't ever use it, really), Animation is the meat of a SpriterMC. You should never really need to interact with an Animation
	 * directly. A SpriterMC can contain many Animations, such as "walk", "run", "jump", etc. These are created
	 * in Spriter.</p>
	 * <p>You can switch between them using</p>
	 * <pre>mySpriterMC.setAnimationByName("run", true);</pre>
	 * or
	 * <pre>mySpriterMC.setAnimationByID(1, true);</pre>
	 * 
	 * If an Animation is not looping, it will dispatch Event.COMPLETE once it has reached its last frame (last frame is dependant on which direction playback is playing).
	 * @author Sammy Joe Osborne
	 */
	public class Animation extends Sprite implements IAnimatable
	{
		
		public var RADIAN_IN_DEGREE:Number = 0.0174532925; //using this is slightly faster than doing PI/180
		
		private var _animationData:AnimationData;
		private var _spriterMC:SpriterMC;
		private var _soundChannel:SoundChannel = new SoundChannel();
		
		protected var _id:uint;
		private var _loop:Boolean = true;
		private var _animationEnded:Boolean = false;
		private var _firstFrameIndex:uint;
		private var _lastFrameIndex:uint;
		private var _currentKeyIndex:int = 0;
		private var _currentTime:int = 0;
		private var _isPlaying:Boolean = false;
		private var _isTransitioning:Boolean = false; // currently does nothing :(
		private var _playDirection:int = 1; //could be 1 for forward, -1 for backward
		private var _playbackSpeed:Number = 1; //percentage for how fast this animation should play, 1 being the default 100%
		
		private var _callbacks:Vector.<Vector.<Command>>;
		private var _sounds:Vector.<Vector.<Sound>>;
		
		private var _timelineImages:Vector.<Image> = new Vector.<Image>();
		private var _boneImages:Vector.<Image>;
		static public var BONE_TEXTURE:Texture; //we only want one copy of this Texture. It's not created if not needed
		
		public function Animation($animationData:AnimationData, $spriterMC:SpriterMC)
		{
			_spriterMC = $spriterMC;
			_animationData = $animationData;
			_loop = _animationData.loop;
			this.name = _animationData.name;
			init();
		}
		
		
		
		/**********************
		 * Public functions
		 **********************/
		internal function init():void 
		{
			_currentTime = 0;
			_currentKeyIndex = 0;
			playbackSpeed = 1; //this also initializes the _firstFrameIndex and _lastFrameIndex
		}
		 
		internal function play():void
		{
			//if we aren't looping and play was called while the animation was on its last frame, restart it
			if (!_loop && _currentKeyIndex == _lastFrameIndex)
			{
				_currentTime = mainKeys[_firstFrameIndex].time; //this is gonna make currentTime 0 or the length of the animation, depending on which way the animation is playing
				_currentKeyIndex = _firstFrameIndex;
			}
			_isPlaying = true;
		}
		
		internal function pause():void
		{
			_isPlaying = false;
		}
		
		internal function stop():void
		{
			_isPlaying = false;
			_currentKeyIndex = 0;
			_currentTime = 0;
		}
		 
		public function advanceTime($time:Number):void 
		{
			if (!_isPlaying || _playbackSpeed == 0 || !_spriterMC.isReady) return;
			
			$time *= 1000 * _playbackSpeed; //turn the additional time into milliseconds, then adjust for proper playbackSpeed
			_currentTime += $time * _playDirection;
			normalizeCurrentTime();
			//if we aren't looping and we're going over the length of the animation
			if (!_loop)
			{
				//if not looping, only update if current time is not past the last frame's time (whether we're playing forward or backward)
				//if we're playing forward and the current time is >= the last keyframe's time, do not update. Just return.
				if (_playDirection >= 0 && (_currentTime >= mainKeys[_lastFrameIndex].time)) return;
				//if we're playing backward and current time is somehow less than 0, don't update. Just return.
				else if (_playDirection < 0 && (_currentTime < 0)) return;
			}
			
			updateVisuals();
		}
		
		public function getNextFrame():MainKey
		{
			//if playing forward
			if (_playDirection >= 0)
			{
				if (_currentKeyIndex == mainKeys.length - 1) return mainKeys[0];
			}
			//if playing backward
			else
			{
				if (_currentKeyIndex == 0) return mainKeys[int(mainKeys.length - 1)];
			}
			
			return mainKeys[int(_currentKeyIndex + _playDirection)];
		}
		
		public function getCurrentFrame():MainKey
		{
			return mainKeys[_currentKeyIndex];
		}
		
		public function getPreviousFrame():MainKey
		{
			//if playing forward
			if (_playDirection >= 0)
			{
				if (_currentKeyIndex == 0) return mainKeys[int(mainKeys.length - 1)];
			}
			//if playing backward
			else
			{
				if (_currentKeyIndex == mainKeys.length - 1) return mainKeys[0];
			}
			
			return mainKeys[int(_currentKeyIndex - _playDirection)];
		}
		
		/**
		 * Sets the sound of the specified frame. You can supply more than 1 sound per frame as well.
		 * @param	$frameID
		 * @param	$sound
		 */
		public function setFrameSound($frameID:uint, $sound:Sound):void
		{
			if ($frameID < mainKeys.length)
			{
				if (!_sounds) 
				{
					_sounds = new Vector.<Vector.<Sound>>();
					_sounds.length = mainKeys.length;
				}
				if (!_sounds[$frameID]) _sounds[$frameID] = new Vector.<Sound>()
				if (_sounds[$frameID].indexOf($sound) == -1)
				{
					_sounds[$frameID].push($sound);
				}
			}
		}
		
		/**
		 * Returns a Vector(Sound) of all the sounds set to play on this frame
		 * @param	$frameID
		 * @return A Vector of Sounds set to play on the specified frame
		 */
		public function getFrameSounds($frameID:uint):Vector.<Sound>
		{
			if ($frameID < mainKeys.length)
			{
				if (_sounds && _sounds[$frameID])
				{
					return _sounds[$frameID];
				}
			}
			
			return null;
		}
		
		/**
		 * If it existed, removes the specified sound from the specified frame so it will not longer play
		 * @param	$frameID
		 * @param	$sound
		 */
		public function removeFrameSound($frameID:uint, $sound:Sound):void
		{
			if ($frameID < mainKeys.length)
			{
				if (_sounds && _sounds[$frameID])
				{
					var $index:int = _sounds[$frameID].indexOf($sound)
					if ($index != -1)
					{
						_sounds[$frameID].splice($index, 1);
					}
				}
			}
		}
		
		/**
		 * Removes all sounds that were added to this frame so they will no longer play
		 * @param	$frameID
		 */
		public function removeAllFrameSounds($frameID:uint):void
		{
			if ($frameID < mainKeys.length)
			{
				if (_sounds && _sounds[$frameID])
				{
					_sounds[$frameID].length = 0;
				}
			}
		}
		
		
		/**
		 * Returns the number of milliseconds a frame lasts.
		 * This depends on the direction the animation is currently playing (forward or backward)
		 * @param	$frameID
		 * @return  The number of milliseconds this frame lasts, dependant upon which direction the animation is playing
		 */
		public function getFrameDuration($frameID:uint):Number
		{
			if (_playDirection >= 0)
			{
				if ($frameID < mainKeys.length - 1)
					return mainKeys[int($frameID + 1)].time - mainKeys[$frameID].time;
				else
					return totalTime - mainKeys[$frameID].time;
			}
			else
			{
				if ($frameID > 0)
					return mainKeys[$frameID].time - mainKeys[int($frameID - 1)].time;
				else
					return mainKeys[$frameID].time;
			}
		}
		
		/**
		 * addFrameCallback Allows you to register callback functions to be ran when an Animation hits a
		 * a specified frame.
		 * @param	$frameID - The ID of the frame to add the callback to
		 * @param	$callback - The function to call
		 * @param	$params - optional parameter to pass params into the callback if they are required
		 */
		public function addFrameCallback($frameID:uint, $callbackFunc:Function, $params:Array = null):void
		{
			if ($frameID < mainKeys.length)
			{
				var $callback:Command = new Command($callbackFunc, $params);
				if (!_callbacks) {
					_callbacks = new Vector.<Vector.<Command>>();
					_callbacks.length = mainKeys.length;
				}
				if (!_callbacks[$frameID]) _callbacks[$frameID] = new Vector.<Command>();
				if (!_callbacks[$frameID].length || !hasFrameCallback($frameID, $callbackFunc))
				{
					_callbacks[$frameID].push($callback);
				}
			}
		}
		
		/**
		 * removeFrameCallback - If it exists, removes the specified function from the specified frame's callbacks. Otherwise does nothing.
		 * @param	$frameID
		 * @param	$callbackFunc
		 */
		public function removeFrameCallback($frameID:uint, $callbackFunc:Function):void
		{
			if ($frameID < mainKeys.length)
			{
				if (_callbacks && _callbacks[$frameID])
				{
					for (var i:int = 0; i < _callbacks[$frameID].length; i++) 
					{
						if (_callbacks[$frameID][i].method == $callbackFunc)
						{
							_callbacks[$frameID].splice(i, 1);
							break;
						}
					}
				}
			}
		}
		
		public function hasFrameCallback($frameID:uint, $callbackFunc:Function):Boolean
		{
			if ($frameID < mainKeys.length)
			{
				if (!_callbacks || !_callbacks[$frameID]) return false;
				for (var i:int = 0; i < _callbacks[$frameID].length; i++) 
				{
					if (_callbacks[$frameID][i].method == $callbackFunc) return true;
				}	
			}
			
			return false;
		}
		
		internal function generateImages():void
		{
			var $mainKeysLength:uint = _animationData.mainKeys.length;
			var $tl:Timeline;
			var $key:Key;
			_timelineImages.length = 0;
			for (var i:uint = 0; i < _animationData.timelines.length; i++)
			{
				$tl = _animationData.timelines[i];
				if ($tl.isBone || $tl.keys.length == 0)
				{
					_timelineImages.push(null)
				}
				else {
					$key = $tl.keys[0];
					_timelineImages.push(new Image(_spriterMC.textures[$key.folder][$key.file]));
				}
			}
		}
		
		/****************************
		 * Public Getters and Setters
		 ***************************/
		
		public function get currentTime():int { return _currentTime };
		public function set currentTime($value:int):void { _currentTime = $value }
		
		public function get currentFrame():int { return _currentKeyIndex; }
		public function set currentFrame($value:int):void {
			$value = ($value > mainKeys.length - 1) ? mainKeys.length - 1 : $value;
			$value = ($value < 0) ? 0 : $value;
			_currentKeyIndex = $value;
			_currentTime = mainKeys[_currentKeyIndex].time;
			updateVisuals();
		}
		
		public function get numFrames():uint { return _animationData.mainKeys.length }
		
		public function get isComplete():Boolean { return _animationEnded; }
		
		public function get isPlaying():Boolean { return _isPlaying; }
		
		public function get playbackSpeed():Number 
		{
			return _playbackSpeed * _playDirection;
		}
		
		public function set playbackSpeed($value:Number):void 
		{
			//we'll always keep playback speed positive. If it's set to
			//below 0, we just change _playDirection
			_playbackSpeed = Math.abs($value);
			
			//set first and last frame indexes
			if ($value >= 0)
			{
				_playDirection = 1;
				_firstFrameIndex = 0;
				_lastFrameIndex = mainKeys.length - 1;
			}
			else {
				_playDirection = -1;
				_firstFrameIndex = mainKeys.length - 1;
				_lastFrameIndex = 0;
			}
		}
		
		/******************************
		* Private (internal) functions
		*******************************/
		private var $updated:Boolean;
		private var $currentMainKey:MainKey;
		private var $objRef:ObjectRef;
		private var $timeline:Timeline;
		private var $boneRef:BoneRef;
		private var $boneContainer:Sprite;
		private var $key:Key;
		private var $nextKey:Key;
		private var $image:Image;
		private var $boneTransformVec:Vector.<Transform> = new Vector.<Transform>();
		private var $spin:int;
		private var $transform:Transform;
		private var $tweenFactor:Number;
		private var $propsAreDirty:Boolean;
		private var $pivotIsDirty:Boolean;
		private var $fileIsDirty:Boolean;
		private var $playingForward:Boolean;
		private var $refLength:uint;
		private var $toRemoveLength:uint;
		private var $boneImage:Image;
		internal function updateVisuals():void 
		{
			if (_spriterMC.isReady)
			{
				if (!_isTransitioning)
				{
					$updated = updateCurrentFrame(); //did the current frame change or are we just further along in the same frame
					$currentMainKey = getCurrentFrame();
					if ($updated)
					{
						callFrameCallbacks(_currentKeyIndex);
						playFrameSounds(_currentKeyIndex);
					}
					
					$playingForward = (_playDirection > 0);
					
					//Remove all children that don't belong
					$toRemoveLength = $currentMainKey.timelineIDsToRemove.length;
					var $timelineIDsToRemove:Vector.<uint> = $currentMainKey.timelineIDsToRemove;
					for (var j:int = 0; j < $toRemoveLength; j++) 
					{
						$image = _timelineImages[$timelineIDsToRemove[j]];
						if ($image.parent == this) removeChild($image);
					}
					
					//if drawing bones, empty the bone container indiscriminately (being lazy, but bones are really just for debugging anyway)
					if(_spriterMC.showBones && $boneContainer) $boneContainer.removeChildren();
						
					//create bones
					$refLength = $currentMainKey.boneRefs.length;
					if ($refLength) $boneTransformVec.length = 0;
					for (var i:int = 0; i < $refLength; i++) 
					{
						$boneRef = $currentMainKey.boneRefs[i];
						$key = $boneRef.key;
						$transform = $key.modTransform.copyValues($key.originalTransform);
						
						//perform lerping
						//based on play direction, figure out which key is the "next" key
						$nextKey = ($playingForward) ? $key.next : $key.prev;
						$propsAreDirty = ($playingForward) ? $key.nextPropsDirty : $key.prevPropsDirty;
						if ($nextKey && $propsAreDirty)
						{
							$tweenFactor = (_currentTime - $key.time) / ($nextKey.time - $key.time);
							
							//spin should be derived from the key you're coming from, not the key you're going to
							//If _playDirection is backwards, we must derive the spin from the
							//current key's previous key and reverse it. In this case, the previous key IS $nextKey
							$spin = ($playingForward) ? $key.spin : $nextKey.spin * -1;
							$transform.transformLerp($nextKey.originalTransform, $tweenFactor, $spin); //lerp with parent transform (nextkey.originalTransform)
						}
						
						//apply parent transformation
						if ($boneRef.parent)
						{
							$transform.applyParentTransform($boneTransformVec[$boneRef.parentID]);
						}
						
						$boneTransformVec.push($transform);
						
						//======================== Bone Drawing =======================
						if (_spriterMC.showBones)
						{
							if (!_boneImages || _boneImages.length == 0)
							{
								generateBoneImages();
							}
							
							if (!$boneContainer) $boneContainer = new Sprite();
							$boneImage 			= _boneImages[i];
							$boneImage.x 		= $transform.x;
							$boneImage.y 		= -$transform.y;
							$boneImage.scaleX	= $transform.scaleX;
							$boneImage.scaleY	= $transform.scaleY;
							$boneImage.rotation = -1 * ($transform.angle * RADIAN_IN_DEGREE);
							$boneContainer.addChild($boneImage);
						}
						else if($boneContainer)
						{
							if ($boneContainer.parent == this) $boneContainer.removeFromParent(true);
						}
						
						//===================== End Bone Drawing ======================
					}
					
					//create objects
					$refLength = $currentMainKey.objectRefs.length;
					for (i = 0; i < $refLength; i++) 
					{	
						$objRef = $currentMainKey.objectRefs[i];
						$key = $objRef.key;
						$transform = $key.modTransform.copyValues($key.originalTransform);
						
						//perform lerping
						$nextKey = ($playingForward) ? $key.next : $key.prev;
						$propsAreDirty = ($playingForward) ? $key.nextPropsDirty : $key.prevPropsDirty;
						if ($nextKey && $propsAreDirty)
						{
							$tweenFactor = (_currentTime - $key.time) / ($nextKey.time - $key.time);
							//spin should be derived from the key you're coming from, not the key you're going to
							//If _playDirection is backwards, we must derive the spin from the
							//current key's previous key and reverse it. In this case, the previous key IS $nextKey
							$spin = ($playingForward) ? $key.spin : $nextKey.spin * -1;
							$transform.transformLerp($nextKey.originalTransform, $tweenFactor, $spin);
						}
						
						if ($objRef.parent)
						{
							$transform.applyParentTransform($boneTransformVec[$objRef.parentID]);
						}
						
						//**********Adding stuff to stage************************
						var $timelineID:uint = $key.timeline.id;
						$image = _timelineImages[$timelineID];
						if ($image.parent != this)
						{
							addChild($image);
							//must reset rotation and scale so we can accurately set the pivot point
							//since the image was scaled/rotated in the previous frame (which throws off its width/height if we don't reset it)
							$image.rotation = 0; 
							$image.scaleX = $image.scaleY = 1;
							$image.pivotX = $key.pivot.x * $image.width;
							$image.pivotY = ((1 - $key.pivot.y) * $image.height);
						}
						//it's already on the stage so don't add it, but update dirty props
						else
						{
							$fileIsDirty = ($playingForward) ? $key.nextFileDirty : $key.prevFileDirty;
							if ($fileIsDirty)
							{
								var tx:Texture = _spriterMC.textures[$key.folder][$key.file];
								if (tx != $image.texture) {
									$image.texture = tx;
									$image.readjustSize();
								}
							}
							
							//must reset rotation and scale so we can accurately set the pivot point
							//since the image was scaled/rotated in the previous frame (which throws off its width/height if we don't reset it)
							$pivotIsDirty = ($playingForward) ? $key.nextPivotDirty : $key.prevPivotDirty;
							if ($pivotIsDirty)
							{
								$image.rotation = 0; 
								$image.scaleX = $image.scaleY = 1;
								
								//the pivots use UV coords, so this is a little tricky. 
								//UV coords are 0,0 at bottom left, 1,1 at top right so we must do
								//the math to translate into starling coordinate space
								$image.pivotX = $key.pivot.x * $image.width;
								$image.pivotY = ((1 - $key.pivot.y) * $image.height);
							}
							
							//swap depths here if it's needed
							if (getChildAt(i) != $image)
							{
								swapChildren(getChildAt(i), $image);
							}
						}
						
						$image.scaleX = $transform.scaleX;
						$image.scaleY = $transform.scaleY;
						$image.x = $transform.x;
						$image.y = -$transform.y;
						$image.rotation = -1*($transform.angle * RADIAN_IN_DEGREE);	
					}
					
					if (_spriterMC.showBones) addChild($boneContainer);
				}
			}
		}
		
		private function updateCurrentFrame():Boolean
		{
			var $currentIndex:uint = _currentKeyIndex;
			var $nextFrame:MainKey;
			while(true)
			{
				$nextFrame = getNextFrame(); //assign this so we're not processing the nextFrame each time
				if (_currentTime == $nextFrame.time)
				{
					_currentKeyIndex = $nextFrame.id;
					break;
				}
				
				//if playing forwards
				if (_playDirection >= 0)
				{
					//trace("foreward ct: " + _currentTime + "  cf: " + getCurrentFrame().time  + " nf: " + $nextFrame.time );
					if (_currentTime >= getCurrentFrame().time && _currentTime < $nextFrame.time) 
						break;
				}
				
				//if playing backward
				else
				{
					//trace("backward ct: " + _currentTime + "  cf: " + getCurrentFrame().time + " nf: " + $nextFrame.time);
					if (_currentTime <= getCurrentFrame().time && _currentTime > $nextFrame.time)
					{
						break;
					}
				}
				
				_currentKeyIndex = $nextFrame.id;
			}
			
			return ($currentIndex != _currentKeyIndex);
		}
		
		///returns true if the current time had to be brought back within the animation time bounds (0 to length)
		private function normalizeCurrentTime():void
		{
			//if we aren't looping and we're going over the length of the animation
			if (!_loop)
			{
				//if playing forward and we're going over length, set current time to length and stop playing
				//or if playing backward and current time is going below zero, set current time to zero and stop playback
				if ((_playDirection >= 0 && _currentTime >= totalTime) || (_playDirection < 0 && _currentTime <= 0))
				{
					_currentTime = mainKeys[_lastFrameIndex].time; //this will either be animation length, or zero, depending on playback direction
					_currentKeyIndex = _lastFrameIndex;
					_isPlaying = false;
					_animationEnded = true;
					_spriterMC.dispatchEventWith(Event.COMPLETE);
				}
			}
			//if we are looping
			else
			{
				//trace(totalTime);
				//if playing forward and time is past length, set current time to what it should be
				if (_playDirection >= 0) 
				{
					//in looping animation, last key equals first key, so when the end is reached we must jump 
					//to the first key to avoid time computational issues
					while (_currentTime >= totalTime)
					{
						_currentTime = _currentTime - totalTime;
					}
				}
				//if playing backward and time is below 0, set current time to what it should be
				else if (_playDirection < 0)
				{
					if (_currentTime <= 0)
					{
						//trace("ct: " + _currentTime + " tt: " + totalTime + " pbs: " + _playbackSpeed);
						_currentTime = totalTime + _currentTime;
					}
					else if (_currentTime > totalTime) _currentTime = totalTime;
				}
			}
		}
		
		
		private function callFrameCallbacks($frameID:uint):void 
		{
			if (_callbacks && _callbacks[$frameID])
			{
				for (var i:uint = 0; i < _callbacks[$frameID].length; i++)
				{
					_callbacks[$frameID][i].callMethod(this);
				}
			}
		}
		
		private function playFrameSounds($frameID:uint):void
		{
			if (_sounds && _sounds[$frameID])
			{
				for (var i:int = 0; i < _sounds[$frameID].length; i++) 
				{
					_soundChannel = _sounds[$frameID][i].play();
				}
			}
		}
		
		//used to generate images used when we want to display bones
		private function generateBoneImages():void
		{
			//create this texture only once
			if (!Animation.BONE_TEXTURE)
			{
				Animation.BONE_TEXTURE = BoneTexture.generateBoneTexture();
			}
			
			_boneImages = new Vector.<Image>();
			//get the highest number of bones that ever exist during a frame
			var $highestBoneCount:uint = 0;
			var $boneLength:uint;
			for (var i:uint = 0, l:uint = _animationData.mainKeys.length; i < l; i++)
			{
					$boneLength = _animationData.mainKeys[i].boneRefs.length;
					if ($boneLength > $highestBoneCount) $highestBoneCount = $boneLength;
			}

			var $image:Image;
			for (i = 0; i < $highestBoneCount; i++)
			{
				$image = new Image(Animation.BONE_TEXTURE)
				$image.pivotY = $image.height / 2; //setting pivot here so we don't have to during updateVisuals
				_boneImages.push($image);
			}
		}
		
		
		/******************************************************
		 * Functions to retrieve values from the AnimationData
		 *****************************************************/
		
		internal function get mainKeys():Vector.<MainKey> { return _animationData.mainKeys; }
		
		internal function get timelines():Vector.<Timeline> { return _animationData.timelines; }
		
		internal function get id():uint { return _animationData.id; }
		
		internal function get totalTime():uint { return _animationData.totalTime; }
		
		internal function get length():uint { return _animationData.length }
		
		internal function get loop():Boolean { return _loop; }
		internal function set loop($value:Boolean):void { _loop = $value; }
		
		internal function get originalyLooped():Boolean { return _animationData.loop; }
		
		public function get animationData():AnimationData { return _animationData; }		
		
		public function get soundChannel():SoundChannel { return _soundChannel; }
	}

}