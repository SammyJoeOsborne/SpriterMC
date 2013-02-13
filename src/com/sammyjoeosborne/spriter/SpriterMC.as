/** SpriterMC: a Starling implementation for importing skeletal 
 * (and non-skeletal) animations generated with Spriter (http://www.brashmonkey.com/spriter.htm)
 *
 *   @author Sammy Joe Osborne
 *   http://www.sammyjoeosborne.com
 *	 http://www.sammyjoeosborne.com/SpriterMC
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
	import com.sammyjoeosborne.spriter.models.Command;
	import com.sammyjoeosborne.spriter.data.ScmlData;
	import com.sammyjoeosborne.spriter.data.TexturePack;
	import com.sammyjoeosborne.spriter.Animation;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	/** SpriterMC is engineered to mimick the Starling MovieClip class closely, with a few differences.
	 *  A SpriterMC can be played back fluidly at any speed and with minimal memory overhead since
	 * all motion is generated via bone data.<br/>
	 * 
	 * <p><b>You should never create a SpriterMC directly</b><br/>
	 * Instead, you should use the SpriterMCFactory.</p>
	 * 
	 * <p>A SpriterMC also contains multiple Animations. You can think of a SpriterMC as a character,
	 * and the various Animations within as the many actions that charater might take. For example,
	 * you may have a character with a "Run" Animation, a "jump" Animation, and a "idle" Animation.
	 * <br/>
	 * These various Animations are generated from the SCML file you provide the SpriterMC factory.
	 * You use Spriter to create multiple Animations within the same file.</p>
	 * 
	 * A SpriterMC dispatches Event.COMPLETE when a non-looping Animation has reached its last frame.
	 * 
	 * <p>To switch between the various Animations, you can use the setAnimationByName and setAnimationByID functions.</p>
	 * For example, the following would switch to the run animation and tell it to play immediately.
	 * <pre>mySpriterMC.setAnimationByName("run", true);</pre>
	 * 
	 * 
	 * @author Sammy Joe Osborne
	 */
	public class SpriterMC extends Sprite implements IAnimatable
	{
		static public const SPRITER_MC_READY:String = "spriterMCReady";
		
		private var _spriterName:String;
		private var _scmlData:ScmlData;
		private var _texturePack:TexturePack;
		private var _onReadyCallback:Function = null;
		
		private var _animations:Vector.<Animation> = new Vector.<Animation>();
		private var _currentAnimation:Animation;
		private var _graphics:Vector.<Vector.<Texture>> = new Vector.<Vector.<Texture>>();
		private var _showBones:Boolean = false;
		
		private var _commandQueue:Vector.<Command> = new Vector.<Command>(); ///Queues commands (play, pause, etc.) issued before the SpriterMC is ready and calls them once it is ready
		private var _isReady:Boolean = false;
		
		
		/**
		 * You should never call this method. Only the SpriterMCFactory should be responsible for creating new SpriterMCs.
		 * @param	$scmlData - the already-parsed SCML data
		 * @param	$texturePack - the TexturePack holding the various assets and information (TextureAtlas) needed to represent this SpriterMC visually.
		 * @param	$onReadyCallback - an optional function to be called when this SpriterMC is fully loaded and ready
		 */
		public function SpriterMC($scmlData:ScmlData, $texturePack:TexturePack, $onReadyCallback:Function = null)
		{
			_scmlData = $scmlData;
			_spriterName = _scmlData.name; //this is just the name of the ScmlData...lets you know what type of SpriterMC this is, that's all
			_onReadyCallback = $onReadyCallback;
			if (_onReadyCallback != null)
			{
				addEventListener(SPRITER_MC_READY, $onReadyCallback);
			}
			
			applyTexturePack($texturePack);
			//_texturePack = $texturePack;
			if (_scmlData.isReady)
			{
				createAnimations();
			}
			else {
				_scmlData.addEventListener(ScmlData.SCML_READY, sclmDataReadyHandler);
			}

			if (_scmlData.isReady && _texturePack && _texturePack.isReady)
			{
				setIsReady();
			}
		}
		
		private function setIsReady():void 
		{
			_isReady = true;
			generateAnimationImages(); //goes through each Animation and generates the images required for display from the given Textures
			setCurrentAnimation(_animations[0]);
			while (_commandQueue.length)
				_commandQueue.shift().callMethod(this);
			
			dispatchEventWith(SpriterMC.SPRITER_MC_READY);
		}
		
		private function sclmDataReadyHandler($e:Event):void 
		{
			createAnimations();
			
			if (!_isReady && _texturePack && _texturePack.isReady)
			{
				setIsReady();
			}
		}
		
		private function texturePackReadyHandler($e:Event):void 
		{
			var $texturePack:TexturePack = $e.target as TexturePack;
			applyTexturePack($texturePack, true);
			if (!_isReady && _scmlData.isReady)
			{
				setIsReady();
			}
		}
		
		private function generateAnimationImages():void
		{
			for (var i:int = 0, l:uint = _animations.length; i < l; i++) 
			{
				_animations[i].generateImages();
			}
		}
		
		private function createAnimations():void
		{
			var $length:uint = _scmlData.animationDatas.length;
			for (var i:int = 0; i < $length; i++)
			{
				_animations.push(new Animation(_scmlData.animationDatas[i], this));
			}
		}
		
		/**********************
		 * Public Properties
		 **********************/
		public function get isReady():Boolean { return _isReady; }
		
		/**
		 * @return Returns a Vector of Textures, which is the current set of Textures in the TexturePack
		 */
		public function get textures():Vector.<Vector.<Texture>>{ return _texturePack.textureVec; }
		
		public function get showBones():Boolean { return _showBones; }
		public function set showBones(value:Boolean):void {
			_showBones = value;
		}
		
		/**********************************************************************
		 * These just delegate the same calls to the current animation 
		 **********************************************************************
		*/
		/**
		 * Plays or resumes the SpriterMC's current Animation (the first listed in the SCML by default) from whatever current frame it is on
		 */
		public function play():void
		{
			
			if (_isReady && _currentAnimation)
			{	
				_currentAnimation.play();
			}
			else _commandQueue.push(new Command(play));
		}
		
		/**
		 * Pauses the SpriterMC's current Animation
		 */
		public function pause():void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.pause();
			else _commandQueue.push(new Command(pause));
		}
		
		/**
		 * Stops the SpriterMC's current Animation and sets its current frame to 1 (or the last frame, if it is currently playing in reverse)
		 */
		public function stop():void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.stop();
			else _commandQueue.push(new Command(stop));
		}
		
		/**
		 * Used by a Juggler to advance the playhead of the SpriterMC's current Animation. If playbackSpeed is currently 0, nothing happens.
		 * @param	$time The amount of time to increase the playhead. This is multiplied by the playbackSpeed
		 */
		public function advanceTime($time:Number):void 
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.advanceTime($time);
			}
		}
		
		/**
		 * Returns the current playbackSpeed for the SpriterMC's current Animation. Note: the playbackSpeed for other Animations might be different. They can each have their own speed. This only returns for the CURRENT set Animation
		 */
		public function get playbackSpeed():Number
		{
			if (_isReady && _currentAnimation)
			{
				return _currentAnimation.playbackSpeed;
			} else throw new Error("Cannot determine playbackSpeed yet. SpriterMC is not ready.")
		}
		
		/**
		 * Sets the playback speed for the SpriterMC's current Animation. Note: only effects the current Animation.
		 */
		public function set playbackSpeed($value:Number):void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.playbackSpeed = $value;
			else _commandQueue.push(new Command(setPlaybackSpeed, [$value]));
		}
		
		/**
		 * This is only used for the command queue, since I can't use a setter in it.
		 * @param	$value The desired playback speed
		 */
		private function setPlaybackSpeed($value:Number):void
		{
			if (_isReady && _currentAnimation)
				_currentAnimation.playbackSpeed = $value;
			else _commandQueue.push(new Command(setCurrentFrame, [$value]));
		}
		
		/**
		 * Returns the current key frame
		 */
		public function get currentFrame():int
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.currentFrame;
			else return 1;
		}
		
		/**
		 * Sets the current frame of the animation. If greater than the length of keys, sets it to the last frame.
		 * @param $value The frame to jump to
		 */
		public function set currentFrame($value:int):void
		{
			if (_isReady && _currentAnimation)
				_currentAnimation.currentFrame = $value;
			
			//must use the setCurrentFrame method since (I don't believe) I can call a setter properly from the command queue
			else _commandQueue.push(new Command(setCurrentFrame, [$value]));
		}
		
		/**
		 * This is only used for the command queue, since I can't use a setter in it.
		 * @param	$value The frame to go to
		 */
		private function setCurrentFrame($value:int):void
		{
			if (_isReady && _currentAnimation)
				_currentAnimation.currentFrame = $value;
			else _commandQueue.push(new Command(setCurrentFrame, [$value]));
		}
		
		/**
		 * Only for non-looping Animations. Returns if the current Animation has completed a full play through and reached its last frame
		 */
		public function get isComplete():Boolean
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.isComplete;
			else return false;
		}
		/**
		 * Allows you to detect if the SpriterMC's current Animation is currently playing
		 */
		public function get isPlaying():Boolean
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.isPlaying;
			else return false;
		}
		
		/**
		 * This returns whether the current Animation is set to loop or not.
		 * Not to be confused with originallyLooped use originallyLooped to determine if the
		 * Animation was set to loop originally in the SCML file.
		 * @return Boolean whether the current animation is set to loop or not.
		 */
		public function get loop():Boolean
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.loop;
			else return false;
		}
		
		/**
		 * Allows you to change the current Animations looping status
		 */
		public function set loop($value:Boolean):void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.loop = $value;
			else _commandQueue.push(new Command(setLoop, [$value]));
		}
		
		/**
		 * Used for the command queue since I don't think I can call setters with params from it
		 * @param	$value
		 */
		private function setLoop($value:Boolean)
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.loop = $value;
			else _commandQueue.push(new Command(setLoop, [$value]));
		}
		/**
		 * Used to determine if the current Animation was originally set to loop
		 * in the SCML file.
		 * Not to be confused with loop, which returns the <i>current</i> looping status.
		 * @return Boolean whether the current Animation was originally set to loop in the SCML file
		 */
		public function get originallyLooped():Boolean
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.originalyLooped;
			else throw new Error("Cannot determine originallyLooped yet. SpriterMC is not ready.")
		}
		
		/**
		 * Returns the number of key frames comprising the SpriterMC's current Animation
		 */
		public function get numFrames():uint
		{
			if (_isReady && _currentAnimation)
				return _currentAnimation.numFrames;
			else throw new Error("Cannot determine numFrames yet. SpriterMC is not ready.")
		}
		
		/*********************
		 * Public Methods
		 *********************/
		/**
		 * Applies a new set of textures to this SpriterMC instance.
		 * @throws  Error if this texture pack doesn't have the correct filestructure expected from this SpriterMC's SCML (TODO: not actually checking if TexturePacks are valid yet)
		 * @param	$texturePack The TexturePack to apply
		 * @param	$disposeOld Disposes of all textures in the previous TexturePack. You must be sure these textures aren't being used elsewhere
		 */
		public function applyTexturePack($texturePack:TexturePack, $disposeOld:Boolean = true)
		{
			if ($texturePack.isReady)
			{
				if ($disposeOld && _texturePack && $texturePack != _texturePack)
				{
					_texturePack.dispose();
					_graphics = new Vector.<Vector.<Texture>>();
				}
				_texturePack = $texturePack;
				//_graphics = _texturePack.generateImageVector();
			}
			else
			{
				_isReady = false;
				$texturePack.addEventListener(TexturePack.TEXTURE_PACK_READY, texturePackReadyHandler);
			}
		}
		 
		 
		/**
		 * Returns the number of milliseconds a frame lasts in the current Animation
		 * This depends on the direction the animation is currently playing (forward or backward)
		 * @param	$frameID
		 * @return  The number of milliseconds this frame lasts, dependant upon which direction the animation is playing
		 */
		public function getFrameDuration($frameID:uint):Number
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.getFrameDuration($frameID);
			else throw new Error("Cannot determine frame duration yet. SpriterMC is not ready.")
		}
		
		/**
		 * addFrameCallback Allows you to register callback functions to be ran when an Animation hits a
		 * a specified frame.
		 * @param	$frameID - The ID of the frame to add the callback to
		 * @param	$callback - The function to call
		 * @param	$params - optional parameter to pass params into the callback if they are required
		 */
		public function addFrameCallback($frameID:uint, $callback:Function, $params:Array = null):void
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.addFrameCallback($frameID, $callback, $params);
			}
			else _commandQueue.push(new Command(addFrameCallback, [$frameID, $callback, $params]));
		}
		
		/**
		 * removeFrameCallback - If it exists, removes the specified function from the specified frame's callbacks. Otherwise does nothing.
		 * @param	$frameID
		 * @param	$callbackFunc
		 */
		public function removeFrameCallback($frameID:uint, $callback:Function):void
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.removeFrameCallback($frameID, $callback);
			}
			else _commandQueue.push(new Command(removeFrameCallback, [$frameID, $callback]));
		}
		
		public function hasFrameCallback($frameID:uint, $callback:Function):Boolean
		{
			if (_isReady && _currentAnimation)
			{
				return _currentAnimation.hasFrameCallback($frameID, $callback);
			}
			else
			{
				trace("hasFrameCallback: Animation not yet ready, returning false.");
				return false;
			}
		}
		
		/**
		 * @return The soundChannel used by the current Animation, so it can be adjusted as needed
		 */
		public function get soundChannel():SoundChannel
		{
			if (_isReady && _currentAnimation)
			{
				return _currentAnimation.soundChannel;
			}
			else return null;
		}
		/**
		 * Sets the sound of the specified frame. You can supply more than 1 sound per frame as well.
		 * @param	$frameID
		 * @param	$sound
		 */
		public function setFrameSound($frameID:uint, $sound:Sound)
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.setFrameSound($frameID, $sound);
			}
			else _commandQueue.push(new Command(setFrameSound, [$frameID, $sound]));
		}
		
		/**
		 * Returns a Vector(Sound) of all the sounds set to play on this frame
		 * @param	$frameID
		 * @return A Vector of Sounds set to play on the specified frame
		 */
		public function getFrameSounds($frameID:uint):Vector.<Sound>
		{
			if (_isReady && _currentAnimation)
			{
				return _currentAnimation.getFrameSounds($frameID);
			}
			else _commandQueue.push(new Command(getFrameSounds, [$frameID]));
		}
		
		/**
		 * If it existed, removes the specified sound from the specified frame so it will not longer play
		 * @param	$frameID
		 * @param	$sound
		 */
		public function removeFrameSound($frameID:uint, $sound:Sound):void
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.removeFrameSound($frameID, $sound);
			}
			else _commandQueue.push(new Command(removeFrameSound, [$frameID, $sound]));
		}
		
		/**
		 * Removes all sounds that were added to this frame so they will no longer play
		 * @param	$frameID
		 */
		public function removeAllFrameSounds($frameID:uint):void
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.removeAllFrameSounds($frameID);
			}
			else _commandQueue.push(new Command(removeAllFrameSounds, [$frameID]));
		}
		 
		/**
		 * Returns the current Animation this SpriterMC is playing
		 * @return The current animation
		 */
		public function get currentAnimation():Animation { return _currentAnimation; }
		
		/**
		 * Returns the name of this SpriterMC. This is the name registered in the SpriterMCFactory, used if you want to generate new instances
		 * of a SpriterMC.
		 */
		public function get spriterName():String { return _spriterName; }
		public function set spriterName(value:String):void { _spriterName = value; }
		
		public function get texturePack():TexturePack { return _texturePack; }
		
		/**
		 * Allows you to switch between the various Animations in this SpriterMC
		 * @param	$name - the name of the Animation to switch to, such as "Run", "walk", "jump", etc.
		 * @param	$playImmediately - whether the Animation should play now or not
		 * @throws  An Error if an animation by that name is not found
		 */
		public function setAnimationByName($name:String, $playImmediately:Boolean = true):void
		{
			if (_isReady && _currentAnimation)
			{
				var $animation:Animation;
				for (var i:int = 0; i < _animations.length; i++) 
				{
					if (_animations[i].name == $name)
					{
						setCurrentAnimation(_animations[i], $playImmediately);
						return;
					}
				}
				
				throw new Error("Animation \"" + $name + "\" not found.");
			}
			else {
				_commandQueue.push(new Command(setAnimationByName, [$name, $playImmediately]));
			}
		}
		
		/**
		 * Same as setAnimationByName, except using an Animation's ID number. This is a zero based number, appearing in order in the SCML file
		 * @param	$id - The id of the animation to switch to
		 * @param	$playImmediately
		 * @throws  An Error if an animation by that id is not found
		 */
		public function setAnimationByID($id:uint, $playImmediately:Boolean = false)
		{
			if(_isReady && _currentAnimation)
			{
				if ($id > 0 && $id < _animations.length)
				{
					setCurrentAnimation(_animations[$id], $playImmediately);
					return;
				}
				
				throw new Error("Animation with id " + $id + " does not exist. Id out of range.");
				}
			else {
				_commandQueue.push(new Command(setAnimationByID, [$id, $playImmediately]));
			}
		}
		
		private function setCurrentAnimation($value:Animation, $playImmediately:Boolean = false):void 
		{
			if (_currentAnimation != $value)
			{
				if (this.contains(_currentAnimation))
				{
					removeChild(_currentAnimation);
				}
				
				_currentAnimation = $value;
				addChild(_currentAnimation);
				_currentAnimation.updateVisuals();
				if ($playImmediately) play();
			}
		}
		
		/**
		 * @return A Vector(String) containing all the Animations this SpriterMC contains such as "walk", "run", "jump." Useful if you need to know your options.
		 */
		public function getAnimationNames():Vector.<String>
		{
			var $namesVec:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < _animations.length; i++) 
			{
				$namesVec.push(_animations[i].name);
			}
			return $namesVec;
		}
		
		/**
		 * Disposes of this SpriterMC instance. The ScmlData and TexturePack will still exist in the SpriterMCFactory in case further instances of this
		 * type need to be generated later.
		 * To dispose of the ScmlData and TexturePack, use the various dispose methods of the SpriterMCFactory.
		 */
		override public function dispose():void
		{
			stop();
			if (parent) removeFromParent();
			_scmlData = null;
			_texturePack = null; //we don't want to call TexturePack.dispose since other SpriterMC instances might be using this TexturePack
			_animations.length = 0; _animations = null;
			super.dispose();
		}
		
	}
}