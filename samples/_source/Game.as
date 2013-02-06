package
{
	import com.sammyjoeosborne.spriter.SpriterMC;
	import com.sammyjoeosborne.spriter.SpriterMCFactory;
	import flash.display.Bitmap;
	import flash.display.Loader;
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
 
    public class Game extends Sprite
    {
		private var _juggler:Juggler;
		private var _monster1:SpriterMC;
		private var _monster2:SpriterMC;
		private var _monster3:SpriterMC;
		private var _hero1:SpriterMC;
		private var _hero2:SpriterMC;
		private var _hero3:SpriterMC;
		
		private var $frameNum:int = 0;
		private var _characterTexture:Texture;
		private var _textureAtlas:TextureAtlas;
		
        public function Game()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
		
        private function onAddedToStage(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			loadTexture("spritesheets/charactersTA.png");
			_juggler = new Juggler();
        }
		
		/**********************************************
		 * LOADING FUNCTIONS
		 * *******************************************/		 
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
			
			_monster1 = SpriterMCFactory.createSpriterMC("monster", "xml/monster.scml", _textureAtlas, spriterReadyHandler, true);
			_monster1.loop = false;
			_monster1.currentFrame = 4;
			_monster1.play();
			//This is just an example to show how a non-looping SpriterMC Animation fires an Event.COMPLETE when it reaches its last frame
			_monster1.addEventListener(Event.COMPLETE, onAnimationCompleteHandler);
			
			_monster2 = SpriterMCFactory.generateInstance("monster", spriterReadyHandler);
			_monster2.setAnimationByName("Posture");
			_monster2.loop = true; //NOTE: we must set loop to true AFTER we set the current Animation, otherwise we'd be setting loop for the previous Animation.
			_monster2.playbackSpeed = 2;
			_monster2.play();
			
			_monster3 = SpriterMCFactory.generateInstance("monster", spriterReadyHandler);
			_monster3.loop = true;
			_monster3.playbackSpeed = -.75;
			_monster3.play();
			
			_hero1 = SpriterMCFactory.createSpriterMC("hero", "xml/hero.scml", _textureAtlas, spriterReadyHandler, true);
			_hero1.name = "hero1";
			_hero1.currentFrame = 4;
			_hero1.play();
			
			_hero2 = SpriterMCFactory.generateInstance("hero", spriterReadyHandler);
			_hero2.name = "hero2";
			_hero2.playbackSpeed = 2;
			_hero2.play();
			
			_hero3 = SpriterMCFactory.generateInstance("hero");
			_hero3.name = "hero3";
			_hero3.playbackSpeed = -.75;
			_hero3.play();
			
			addChild(_monster1);
			addChild(_monster2);
			addChild(_monster3);
			addChild(_hero1);
			addChild(_hero2);
			addChild(_hero3);
			
			_juggler.add(_monster1);
			_juggler.add(_monster2);
			_juggler.add(_monster3);
			_juggler.add(_hero1);
			_juggler.add(_hero2);
			_juggler.add(_hero3);
			
			
			_monster1.x = 100;
			_monster1.y = 320;
			_monster1.scaleX = _monster1.scaleY = .5;
			
			_monster2.x = 300;
			_monster2.y = 320;
			_monster2.scaleX = _monster2.scaleY = .5;
			
			_monster3.x = 520;
			_monster3.y = 320;
			_monster3.scaleX = _monster3.scaleY = .5;
			
			_hero1.x = 100;
			_hero1.y = 660;
			_hero1.scaleX = _hero1.scaleY = .5;
			
			_hero2.x = 300;
			_hero2.y = 660;
			_hero2.scaleX = _hero2.scaleY = .5;
			
			_hero3.x = 520;
			_hero3.y = 660;
			_hero3.scaleX = _hero3.scaleY = .5;
			
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
			_monster3.currentAnimation.playbackSpeed = $value;
			_hero3.currentAnimation.playbackSpeed = $value;
		}
		
    }
 }
