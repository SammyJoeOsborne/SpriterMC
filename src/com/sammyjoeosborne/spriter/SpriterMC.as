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
	import com.sammyjoeosborne.spriter.models.Command;
	import com.sammyjoeosborne.spriter.data.ScmlData;
	import com.sammyjoeosborne.spriter.data.TexturePack;
	import flash.media.Sound;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	/**
	 * ...
	 * @author Sammy Joe Osborne
	 * 1/12/2013 2:32 PM
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
		private var _graphics:Vector.<Vector.<Image>> = new Vector.<Vector.<Image>>();
		
		private var _commandQueue:Vector.<Command> = new Vector.<Command>(); ///Queues commands (play, pause, etc.) issued before the SpriterMC is ready and calls them once it is ready
		private var _isReady:Boolean = false;
		
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
			
			if (_scmlData.isReady && _texturePack.isReady)
			{
				setIsReady();
			}
		}
		
		private function setIsReady():void 
		{
			_isReady = true;
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
		
		public function get graphics():Vector.<Vector.<Image>>{ return _graphics; }
		
		/**********************************************************************
		 * These just delegate the same calls to the current animation 
		 **********************************************************************
		*/
		public function play():void
		{
			
			if (_isReady && _currentAnimation)
			{	
				_currentAnimation.play();
			}
			else _commandQueue.push(new Command(play));
		}
		
		public function pause():void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.pause();
			else _commandQueue.push(new Command(pause));
		}
		
		public function stop():void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.stop();
			else _commandQueue.push(new Command(stop));
		}
		
		public function advanceTime($time:Number):void 
		{
			if (_isReady && _currentAnimation)
			{
				_currentAnimation.advanceTime($time);
			}
		}
		
		public function get playbackSpeed():Number
		{
			if (_isReady && _currentAnimation)
			{
				return _currentAnimation.playbackSpeed;
			} else throw new Error("Cannot determine playbackSpeed yet. SpriterMC is not ready.")
		}
		
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
		
		public function get isComplete():Boolean
		{
			if(_isReady && _currentAnimation)
				return _currentAnimation.isComplete;
			else return false;
		}
		
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
		
		public function set loop($value:Boolean):void
		{
			if(_isReady && _currentAnimation)
				_currentAnimation.loop = $value;
			else throw new Error("Cannot set loop. SpriterMC is not ready.")
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
		 * @throws  Error if this texture pack doesn't have the correct filestructure expected from this SpriterMC's SCML
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
					_graphics = new Vector.<Vector.<Image>>();
				}
				_texturePack = $texturePack;
				_graphics = _texturePack.generateImageVector();
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
		 * TODO: not yet implemented.
		 * Method for manually setting Sounds on frames outside of what the SCML file 
		 * specified.
		 * @param	$frameID
		 * @param	$sound
		 */
		public function setFrameSound($frameID:uint, $sound:Sound)
		{
			//TODO: add sounds to frames
			//currentAnimation.setFrameSound($frameID, $sound);
		}
		
		/**
		 * TODO: not yet implemented. Will get any Sounds set to play on the specified frame
		 * @param	$frameID
		 * @return  A Vector of all Sounds set to play on the specified frame
		 */
		public function getFrameSound($frameID:uint):Vector.<Sound>
		{
			//TODO: return sound once sounds are supported
			//return currentAnimation.getFrameSounds($frameID);
		}
		 
		/**
		 * Returns the current Animation this SpriterMC is playing
		 * @return The current animation
		 */
		public function get currentAnimation():Animation { return _currentAnimation; }
		
		public function get spriterName():String { return _spriterName; }
		public function set spriterName(value:String):void { _spriterName = value; }
		
		public function get texturePack():TexturePack { return _texturePack; }
		
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
				_commandQueue.push(new Command(setAnimationByName, [$name, $playImmediately]));
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
		
		public function getAnimationNames():Vector.<String>
		{
			var $namesVec:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < _animations.length; i++) 
			{
				$namesVec.push(_animations[i].name);
			}
			return $namesVec;
		}
		
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