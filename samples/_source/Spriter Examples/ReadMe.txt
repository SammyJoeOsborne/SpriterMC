These are the original Spriter files. You can open each SCML file in Spriter if you wish to see how they were constructed.

"hero" is a example of an animation using bones.

"monster" is the example provided by BrashMonkey (the creators of Spriter), and does not use bones.

Noticed, the SCML files are both located next to their graphic assets. This is necessary when creating a Spriter animation, as the asset paths inside of the SCML file are relative to the location of the SCML file.

When you go to import the SCML file to your flash project using SpriterMC, you may load the SCML from whereever you wish, but if you are not providing SpriterMC a TextureAtlas, the pathing to the graphic assets must remain relative to your main SWF, or it will not be able to find the graphics!

For example, Consider the following folder structure for your application. If you have a folder called Main, and inside of it you have your SWF, an scml folder, and a graphics folder. Lets say the graphics inside of your SCML file are listed as "graphics/hero/image.jpg", and you have moved your SCML file is inside of the scml folder.

- [Main]
  |
  |-> main.swf
  |-> [scml]
      |
      |-> hero.scml

  |-> [graphics]
      |
      |->[hero]
         |
         |-> image.jpg

This is totally fine for your application, as your main.swf will know to look in graphics/hero for the file "image.jpg" since that path is relative to the SWF. However, just be aware that because you moved the SCML file, your graphic paths are no longer relative to the SCML file, so if you try opening hero.scml in Spriter, it will not open properly as Spriter will not be able to locate the images.
Not a big deal...just move the scml file back out to the [Main] folder if you ever need to edit your animation. Or just have a full copy of the scml and graphics folder structure somewhere else.

