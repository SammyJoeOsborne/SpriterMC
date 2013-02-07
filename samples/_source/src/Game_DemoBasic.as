package
{
	import com.sammyjoeosborne.spriter.shapes.BonePoly;
	import com.sammyjoeosborne.spriter.SpriterMC;
	import com.sammyjoeosborne.spriter.SpriterMCFactory;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.core.StatsDisplay;
    import starling.display.Quad;
    import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
    import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
 
    public class Game_DemoBasic extends Sprite
    {
		private var _juggler:Juggler;
		private var _hero1:SpriterMC;
		
		private var $frameNum:int = 0;
		private var _characterTexture:Texture;
		private var _textureAtlas:TextureAtlas;
		private var _footStep1:Sound;
		
        public function Game_DemoBasic()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
		
        private function onAddedToStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			loadTexture("spritesheets/charactersTA.png");
			loadSounds();
			_juggler = new Juggler();
        }
		
		/**********************************************
		 * LOADING FUNCTIONS
		 * *******************************************/
		private function loadSounds():void 
		{
			_footStep1 = new Sound(new URLRequest("sounds/footstep01.mp3"));
		}
		 
		private function loadTexture($path:String):void
		{
			var $loader:Loader = new Loader();
			$loader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureLoadedHandler);
			$loader.load(new URLRequest($path));
		}
		
		private function textureLoadedHandler($e:*):void 
		{
			trace("texture loaded");
			_characterTexture = Texture.fromBitmap(Bitmap($e.target.loader.content));
			loadTextureAtlasXML("xml/charactersTA.xml");
		}
		
		private function loadTextureAtlasXML($path:String):void 
		{
			var $urlLoader:URLLoader = new URLLoader(new URLRequest($path));
			$urlLoader.addEventListener(Event.COMPLETE, atlasXMLLoadedHandler);
		}
		
		private function atlasXMLLoadedHandler($e:*):void 
		{
			var $atlasXML:XML = XML($e.target.data);
			_textureAtlas = new TextureAtlas(_characterTexture, $atlasXML);
			createCharacters();
		}
		/*********** END LOADING FUNCTIONS ***********
		 *********************************************/
		 
		 
		 /***/
		private function createCharacters():void
		{		
			_hero1 = SpriterMCFactory.createSpriterMC("hero", "xml/hero.scml", _textureAtlas, spriterReadyHandler, true);
			_hero1.name = "hero1";
			_hero1.playbackSpeed = 1.5
			_hero1.play();
			
			_hero1.x = stage.stageWidth / 2 - _hero1.width / 2;
			_hero1.y = 700;
			
			addChild(_hero1);
			
			_juggler.add(_hero1);			
			
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		//This is just an example to show that the Event.COMPLETE event fires after a non-looping animation finishes playing
		private function onAnimationCompleteHandler($e:Event):void 
		{
			trace("Animation complete: " + SpriterMC($e.target).currentAnimation.name);
			SpriterMC($e.target).play();
		}
		
		private function duplicateCharacters():void
		{
				//_spriter.play();
		}
		
		private function spriterReadyHandler($e:Event):void 
		{
			var $spriterMC:SpriterMC = $e.target as SpriterMC;
			trace("SpriterMC ready: " + $spriterMC.spriterName);
			//Now that SpriterMC is ready, do something if you so desire...
		}
		
		private function onEnterFrameHandler($e:EnterFrameEvent):void
		{
			_juggler.advanceTime($e.passedTime);
		}
		
		public function setAnimationSpeed($value:Number):void
		{
			_hero1.currentAnimation.playbackSpeed = $value;
		}
		
		public function setShowBones($val:Boolean)
		{
			_hero1.showBones = $val;
		}
		
		public function setPlaySounds($val:Boolean)
		{
			if ($val)
			{
				_hero1.setFrameSound(3, _footStep1);
				_hero1.setFrameSound(6, _footStep1);
			}
			else
			{
				_hero1.removeAllFrameSounds(3);
				_hero1.removeAllFrameSounds(6);
			}
		}
		
    }
 }
