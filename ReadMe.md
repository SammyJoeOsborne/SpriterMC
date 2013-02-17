SpriterMC
=========
http://www.sammyjoeosborne.com/SpriterMC

SpriterMC is a Starling implementation for importing skeletal (and non-skeletal) animations generated with Spriter (http://www.brashmonkey.com/spriter.htm), complete with a familiar API mimicking Starling MovieClip. Features include SpriterMC generation from an existing TextureAtlas or individual assets (a TextureAtlas is generated from assets dynamicall), bone support, ability to create multiple instances with low overhead, Framerate-independant and adjustable playback speed and playback direction, swap entire texture sets at runtime, and more. It currently supports all features of the Spriter file format (version a4.1), with future support planned for any subsequent changes to the SCML format.

## Version .87

### Features
* Generates a SpriterMC (similar to a Starling MovieClip) from a provided SCML filepath (loading of the SCML file is handled for you)
* Accepts a preloaded TextureAtlas for assets, or loads the individual assets referenced in the SCML file and dynamically generates a TextureAtlas for you (uses a modified version of Emiliano Angelini's [Dynamic Texture Atlas Generator] (https://github.com/emibap/Dynamic-Texture-Atlas-Generator))
* Effortlessly create multiple instances of existing SpriterMCs with little to no additional memory or processing (100 instances at 60FPS in the [Benchmark] (http://www.sammyjoeosborne.com/SpriterMC/Benchmark.html)
* Framerate-irrelevant playback features ability to play and adjust your SpriterMC's playbackSpeed in real time, even reversing play direction altogether (by setting playbackSpeed to a negative)
* NEW: Ability to draw underlying bone structure (for debugging, if needed)
* NEW: Add Sounds to specific frames
* NEW: Add callbacks to specific frames
* Switch between Animations in the SpriterMC effortlessly (mySpriterMC.setAnimationByName("Running");)
* Switch out TexturePacks at runtime to completely change the graphics used (TexturePack must contain the same folder/file structure as the SpriterMC's original TexturePack)
* Friendly and familiar API featuring most (though not all) of the same methods of the [Starling MovieClip] (http://doc.starling-framework.org/core/starling/display/MovieClip.html)
* Queued commands that will execute once the SpriterMC is loaded and ready for display, so you don't have to wait on an event listener to start issuing calls such as play(), playbackSpeed = -1.5, currentFrame(), setAnimationByName(), etc. (You can still add an event listener to wait for the SpriterMC.SPRITER_MC_READY if you need to)

### TODO List
* Add ability to switch fluidly between Animations (it will tween between them instead of instantly switching as it currently does). Should be available next release.
* Optimize and cleanup code
* Add better Error checking
* Possibly add an adjustable rootPath variable to correct any relative pathing issues from the SWF when loading individual assets

Usage
=====
Until I can get ASDocs working to generate official documentation, I'll try to explain the most important aspects here and provide a general overview of how SpriterMC works and the various methods available.

## Creating a new SpriterMC
You will never create a new SpriterMC. Instead, the SpriterMCFactory will create one for you and return it. You then need to add it to the stage and to a Juggler, just like any other Starling MovieClip. There are two methods to create a SpriterMC:

* <b>SpriterMCFactory.createSpriterMC($name:String, $scmlPath:String, $textureAtlas:TextureAtlas = null, $onReadyCallback:Function = null, $returnInstance:Boolean = true):SpriterMC</b> -- defines and then returns a new SpriterMC for the first time. The only <b>required</b> parameters are $name and $scmlPath. $name must be a unique String used to identify this type of SpriterMC incase you want to generate more instances of it later, and ScmlPath is the path to the SCML file.

<b>SpriterMCFactory.generateInstance($name:String, $onReadyCallback:Function = null, $altTexturePack:String = ""):SpriterMC</b> -- returns a new instance (a duplicate) of an existing SpriterMC, using the $name as reference. You can optionally pass it an alternate TexturePack from an existing SpriterMC as long as they're compatible (advanced use only).

Ideally, for performance and memory considerations, you should also pass an already-created TextureAtlas containing the assets for your character as the $textureAtlas parameter. <b>This same TextureAtlas can be used for multiple SCML files as long as all the required assets are present!</b>. This is the most optimal situation possible.
However, you can also let SpriterMC load the individual assets listed in the SCML file and it will create a TextureAtlass for you. Be aware that this potentially uses more memory.

## Examples:
###Creating a new SpriterMC named "monster" without providing a TextureAtlas (Not Recommended)

```actionscript
var monster1:SpriterMC = SpriterMCFactory.createSpriterMC("monster", "xml/monster.scml");
monster1.play(); //Note: SpriterMC's will not actually start playing or show up on stage until SpriterMC.SPRITER_MC_READY is broadcast

//Add each SpriterMC to a Juggler, just like a regular Starling MovieClip
myJuggler.add(monster1);
```

###Creating a new SpriterMC named "monster" using an existing TextureAtlas (Recommended)
```actionscript
var monster1:SpriterMC = SpriterMCFactory.createSpriterMC("monster", "xml/monster.scml", _textureAtlas);
monster1.playbackSpeed = 1.5; //Demonstrating playbackSpeed, which is like Scale, 1 == 100%. You can also set negative values to play backward
monster1.play(); //Note: SpriterMC's will not actually start playing or show up on stage until SpriterMC.SPRITER_MC_READY is broadcast

//Add each SpriterMC to a Juggler, just like a regular Starling MovieClip
myJuggler.add(monster1);
```

###Creating a new SpriterMC named "monster" using a TextureAtlas, adding an onReady callback, and creating multiple instances
```actionsctipt
//create monster and call spriterReadyHandler when it is ready
var monster1:SpriterMC = SpriterMCFactory.createSpriterMC("monster", "xml/monster.scml", _textureAtlas, spriterReadyHandler);
monster1.play();

//generate a new instance of "monster", and call spriterReadyHandler when it is ready
var monster2:SpriterMC = SpriterMCFactory.generateInstance("monster", spriterReadyHandler);
monster2.setAnimationByName("Posture"); //set the animation to "Posture" instead of "Idle"
monster2.currentFrame = 4; //start it off at frame 4
monster2.play();

//Add each SpriterMC to a Juggler, just like a regular Starling MovieClip
myJuggler.add(monster1);
myJuggler.add(monster2);
```

Available Methods
=================
Most methods of SpriterMC are very similar to that of the Starling MovieClip, with a few exceptions. Below is a list of functions and a brief description:

###Properties:
* playbackSpeed - 1 is 100%, 2 is 200%, etc. Use negative value to play in reverse
* currentFrame - getter/setter. Setting out of bounds sets to the nearest limit
* isComplete - getter only. For non-looping animations, lets you know if the animation has reached its last frame (last frame is actually 0 if the animation is playing in reverse)
* loop - getter/setter, sets whether the animation should loop or not. Not to be confused with originallyLooped
* originallyLooped - getter only. Not to be confused with loop, this simply tells you if the animation was originally set to loop in the loaded SCML file powering this SpriterMC's ScmlData.
* numFrames - getter only. Total number of frames
* currentAnimation - getter only. The current Animation playing in this SpriterMC. Not recommended that you mess with it...
* spriterName - getter/setter. Not to be confused with DisplayObject.name, this is the name used by the SpriterMCFactory to generate more instances of a particular ScmlData/TexturePack combo. Do not change this...bad things.
* texturePack - getter only. The current TexturePack this SpriterMC instance is using. If you wish to use a separate one, use the applyTexturePack function

###Public Methods:
* play():void
* pause():void
* stop():void
* advanceTime():void
* applyTexturePack($texturePack:TexturePack, $disposeOld:Boolean = true):void
* getFrameDuration($frameID:uint):Number
* setAnimationByName($name:String, $playImmediately:Boolean = true):void
* setAnimationByID($id:uint, $playImmediately:Boolean = true):void
* getAnimationNames():Vector.<String>
* dispose():void


Common Mistakes / Errors
========================
### Loading Errors - BulkLoader cannot find files
* If you do not provide the SpriterMCFactory a TextureAtlas, it attempts to load the individual assets listed in the SCML file and generate a TextureAtlas dynamically. The paths to the files in the SCML file are relative to the SCML file itself, and so too are they relative to the main SWF of your application. If it can't find these individual files, be sure the pathing listed in the SCML is correct. 

###TextureAtlas pathing errors
* If you provide a TextureAtlas (which is the recommended method) rather than having SpriterMC generate one from the individual assets, you must make sure the assets are pathed the same in the SCML file as they are in Texture Packer. For example, if the SCML file lists "mon_legs/thigh_a.png", your TextPacker XML should also refer to that file as "mon_legs/thigh_a"

###OnReady never fires for new instances
* If you create a new instance of an existing SpriterMC, don't add the SpriterMC.SPRITER_MC_READY event listener, as the new instance is already ready and fires the SpriterMC.SPRITER_MC_READY event before you can add the listener. Instead, if you need the ready event to be called, pass the listener function in the generateInstance() constructor (second parameter, $onReadyCallback). You can also just start issuing calls to the new instance which will queue and fire automatically once the SpriterMC is ready.


How It Works
============
While you don't need to worry about the internals, it might be helpful to understand the components of a SpriterMC. Each SpriterMC has two pieces of data it relies on: an ScmlData object and a TexturePack. The ScmlData is parsed from the loaded SCML file provided when the SpriterMC is first created, and contains all relavant animation info. A TexturePack is the set of textures generated from a TextureAtlas, which is either provided at creation (by far the most recommended method) or generated dynamically from individual assets.
When the SpriterMCFactory defines a new SpriterMC, it is really just creating a ScmlData and a TexturePack and giving them each the provided name. It then creates a SpriterMC by passing these two objects to a new SpriterMC instance.
When the SpriterMCFactory generates a new instance of an existing SpriterMC, it's really just grabbing the previously created ScmlData and TextureAtlas by name, then creating a new SpriterMC instance with them and returning it.
So in essence, the SpriterMCFactory is storing all created ScmlData and TexturePack objects and only creating actual SpriterMC's on request.
This design allows multiple SpriterMC's to share the same ScmlDatas and TexturePacks, keeping memory low and allowing only one draw call per TextureAtlas used!

A SpriterMC is not considered "ready" until all required assets are fully loaded and parsed. SpriterMC dispatches "SpriterMC.SPRITER_MC_READY" when it is complete.

Each SpriterMC contains various Animation objects it is capable of playing and switching between (switch between them by using setAnimationByName or setAnimationByID). SpriterMC and Animation both implement Starling's IAnimatable interface. Any calls to SpriterMC such as play, stop, etc, are delegated to the current Animation it is playing.
Inside of Animation's advanceTime method, the number of milliseconds passed is retrieved, the current keyframe is calculated (depending on if it's playing forward or backward), and all data values are manually interpolated based on the playhead time between the current frame and next frame.
When Considering Bones, their data (position, rotation, scale, etc) is only relative to their immediate parent. This is true of any image that is a child of a Bone as well, therefore the entire Bone chain must be traversed and each Transform concatenated to calculate the final values. (Thanks to GrimFang for the tip to abondon Matrices...SCML does not use Matrix math).

