package
{
	import com.sammyjoeosborne.spriter.SpriterMC;
	import com.sammyjoeosborne.spriter.SpriterMCFactory;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import starling.animation.Juggler;
    import starling.display.Quad;
    import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
    import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
 
    public class GameBenchmark extends Sprite
    {
		private var _juggler:Juggler;
		
		private var $frameNum:int = 0;
		private var _characterTexture:Texture;
		private var _textureAtlas:TextureAtlas;
		private var _timer:Timer;
		private var _numInstances:uint = 0;
		private var _spriterMC:SpriterMC;
		private var _tf:TextField;
		private var _quad:Quad;
		private var _frame:uint;
		
		private var _frameRate:Number;
		private var _frameCount:int = 0;
		private var _totalTime:Number = 0;
		
        public function GameBenchmark()
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
			
			start();
		}
		/*********** END LOADING FUNCTIONS ***********
		 *********************************************/
		 
		 
		 /***/
		private function start():void
		{
			
			_quad = new Quad(stage.stageWidth, 50, 0x000000);
			_quad.x = 0;
			_quad.y = stage.stageHeight - _quad.height;
			addChild(_quad)
			
			//create textfield
			_tf = new TextField(100, 20, "text", "Arial", 12, Color.WHITE);
			_tf.width = 400;
			_tf.height = 50
			_tf.hAlign = HAlign.CENTER;  // horizontal alignment
			_tf.vAlign = VAlign.CENTER; // vertical alignment
			_tf.fontSize = 25;
			_tf.bold = true;
			_tf.text = "1";
			_tf.x = stage.stageWidth / 2 - _tf.width / 2;
			_tf.y = stage.stageHeight - _tf.height;
			addChild(_tf);
			
			//Using bones
			_spriterMC = SpriterMCFactory.createSpriterMC("hero", "xml/hero.scml", _textureAtlas, spriterReadyHandler);
			//Not using bones
			//_spriterMC = SpriterMCFactory.createSpriterMC("hero", "xml/monster.scml", _textureAtlas, spriterReadyHandler);
			
			_spriterMC.touchable = false;
			_spriterMC.x = 50; 
			_spriterMC.y = 350;
			_spriterMC.scaleX = _spriterMC.scaleY = .5;
			_spriterMC.play();
			_juggler.add(_spriterMC);
			addChildAt(_spriterMC, 0);
			updateNumInstances();
		}
		
		private function updateNumInstances():void 
		{
			_numInstances++;
			_tf.text = "Number of instances: " + _numInstances//_numInstances.toString();
			/*addChild(_quad); //keping them both on top
			addChild(_tf);//keeping it on top*/
		}
		
		private function duplicateCharacter():void
		{
			var $spriterMC2:SpriterMC = SpriterMCFactory.generateInstance("hero");
			$spriterMC2.touchable = false;
			$spriterMC2.scaleX = $spriterMC2.scaleY = .5;
			$spriterMC2.x = randomNum(30, stage.stageWidth - 30);
			$spriterMC2.y = randomNum(30, stage.stageHeight - 30);
			$spriterMC2.rotation = randomNum(-3.14, 3.14)
			_juggler.add($spriterMC2);
			$spriterMC2.play();
			addChildAt($spriterMC2,0);
			updateNumInstances();			
		}
		
		private function spriterReadyHandler($e:Event):void 
		{
			//var $spriterMC:SpriterMC = $e.target as SpriterMC;
			/*_timer = new Timer(20, 429);
			_timer.addEventListener(TimerEvent.TIMER, duplicateCharacter);
			_timer.start();*/
			updateNumInstances();
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler($e:EnterFrameEvent):void
		{			
			_juggler.advanceTime($e.passedTime);
			
			_totalTime += $e.passedTime;
			if (++_frameCount % 60 == 0)
			{
				_frameRate = _frameCount / _totalTime;
				_frameCount = _totalTime = 0;
			}
			
			_frame++;
			if (_frame == 3) {
				_frame = 0;
				if (_frameRate > 58)
				{
					duplicateCharacter();
				}
			}
			
			
		}
		
		private function getFPS():void
		{
			
		}
		
		public function setAnimationSpeed($value:Number):void
		{
			_monster3.currentAnimation.playbackSpeed = $value;
			_hero3.currentAnimation.playbackSpeed = $value;
		}
		
		private function randomNum(lowVal:Number, highVal:Number):Number {
			if (lowVal <= highVal) {
				return(lowVal + Math.random() * (highVal - lowVal + 1));
			}else {
				throw(new Error("Low value higher than high value"));
			}
		}
		
    }
 }
