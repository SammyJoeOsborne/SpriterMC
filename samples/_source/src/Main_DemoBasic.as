package 
{
	import fl.controls.Slider;
	import fl.controls.CheckBox;
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
 
    public class Main_DemoBasic extends Sprite 
    {
		public var speedTF:TextField;
		public var modeTF:TextField;
		public var warningMC:MovieClip;
		public var cb_playSounds:CheckBox;
		public var cb_showBones:CheckBox;
        private var _starling:Starling;
 
        public function Main_DemoBasic():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
 
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
			warningMC.visible = false;
			
            // entry point
            _starling = new Starling(Game_DemoBasic, stage);
			_starling.showStats = true;
			_starling.antiAliasing = 1;
            _starling.start();
			
			var $timer:Timer = new Timer(3000, 1);
			$timer.addEventListener(TimerEvent.TIMER, getStarlingDriverInfo);
			$timer.start();
			
			setupComponents();
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
		
		private function setupComponents():void
		{
			cb_playSounds.addEventListener(Event.CHANGE, checkBoxClicked);
			cb_showBones.addEventListener(Event.CHANGE, checkBoxClicked);
			
			//setup slider
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
			$slider.value = 1.5;
			setText($slider.value);
		}
		
		private function checkBoxClicked($e:Event):void 
		{
			var $cb:CheckBox = $e.target as CheckBox;
			if ($cb == cb_playSounds)
			{
				Game_DemoBasic(_starling.root).setPlaySounds($cb.selected);
			}
			else
			{
				Game_DemoBasic(_starling.root).setShowBones($cb.selected);
			}
		}
		
		private function setText($value:Number):void 
		{
			speedTF.text = ($value * 100).toFixed(0) + "%";
		}
		
		private function sliderChangeHandler($e:SliderEvent):void 
		{
			setText($e.value);
			Game_DemoBasic(_starling.root).setAnimationSpeed($e.value);
		}
    }
}