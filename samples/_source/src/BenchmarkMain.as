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
 
    public class BenchmarkMain extends Sprite 
    {
		public var modeTF:TextField;
		public var warningMC:MovieClip;
        private var _starling:Starling;
 
        public function BenchmarkMain():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
 
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
			warningMC.visible = false;
			
            // entry point
            _starling = new Starling(GameBenchmark, stage);
			_starling.showStats = true;
			_starling.antiAliasing = 1;
            _starling.start();
			
			var $timer:Timer = new Timer(3000, 1);
			$timer.addEventListener(TimerEvent.TIMER, getStarlingDriverInfo);
			$timer.start();
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
		
    }
}