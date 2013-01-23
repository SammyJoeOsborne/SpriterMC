package 
{
	import fl.controls.Slider;
	import fl.controls.SliderDirection;
	import fl.events.SliderEvent;
	import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import net.hires.debug.Stats;
    import starling.core.Starling;
	import starling.display.DisplayObject;
 
    public class Main extends Sprite 
    {
		public var speedTF:TextField;
		public var modeTF:TextField;
		public var warningMC:MovieClip;
        private var _starling:Starling;
 
        public function Main():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
 
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
			warningMC.visible = false;
			
            // entry point
            _starling = new Starling(Game, stage);
			_starling.showStats = true;
			_starling.antiAliasing = 1;
            _starling.start();
			
			var $timer:Timer = new Timer(3000, 1);
			$timer.addEventListener(TimerEvent.TIMER, getStarlingDriverInfo);
			$timer.start();
			
			//var $stats:Stats = new Stats();
			//addChild($stats);
			
			addSlider();
			
        }
		
		private function getStarlingDriverInfo(e:TimerEvent):void 
		{
			modeTF.text = Starling.current.context.driverInfo;
			if (modeTF.text.indexOf("Software") != -1)
			{
				showWarning();
			}
		}
		
		private function showWarning():void 
		{
			warningMC.alpha = 1;
			warningMC.visible = true;
		}
		
		private function addSlider():void
		{
			var $slider:Slider = new Slider();
			$slider.direction = SliderDirection.VERTICAL;
			$slider.height = 470;
			$slider.minimum = -10;
			$slider.maximum = 10;
			$slider.tickInterval = 1;
			$slider.snapInterval = .05;
			$slider.getChildAt(1).width = 25;
			$slider.getChildAt(1).height = 25;
			
			
			$slider.x = speedTF.x + speedTF.width / 2;
			$slider.y = speedTF.y + speedTF.height + 10;
			addChild($slider);
			
			$slider.addEventListener(SliderEvent.THUMB_DRAG, sliderChangeHandler);
			$slider.addEventListener(SliderEvent.CHANGE, sliderChangeHandler);
			$slider.value = -.75;
			setText($slider.value);
		}
		
		private function setText($value:Number):void 
		{
			speedTF.text = ($value * 100).toFixed(0) + "%";
		}
		
		private function sliderChangeHandler($e:SliderEvent):void 
		{
			setText($e.value);
			Game(_starling.root).setAnimationSpeed($e.value);
		}
		
		
    }
}