
package;

import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Cache extends FlxState 
{
    var toBeDone = 0;
	var done = 0;
    var barProgress:Float = 0;

	var loaded = false;
	
	var dog:FlxSprite;
	var text:FlxText;
	var BG:FlxSprite;
	var thing:String;
	var runningpaps:FlxSprite;

    var barBG:FlxSprite;
    var bar:FlxBar;

    var bitmapData:Map<String,FlxGraphic> = new Map<String,FlxGraphic>();

	var images = [];
	var music = [];
	var charts = [];

    override function create() 
    {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        
        FlxG.mouse.visible = false;
		FlxG.worldBounds.set(0, 0);
        #if sys
        for (i in FileSystem.readDirectory(FileSystem.absolutePath( "assets/shared/images/characters")))
        {
            if (!i.endsWith(".png"))
                continue;

            images.push(i);
        }
        #end
        BG = new FlxSprite().loadGraphic(Paths.image('bg paps'));

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 - 10 ,0,"Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.color = FlxColor.YELLOW;
		text.alpha = 1;

		runningpaps = new FlxSprite();
		runningpaps.frames = Paths.getSparrowAtlas('runnn');
		runningpaps.animation.addByPrefix('run', 'rumn', 30, true);
		runningpaps.setGraphicSize(Std.int(runningpaps.width * 0.6));
		runningpaps.animation.play('run');
		
		text.x -= 170;

		dog = new FlxSprite(520, FlxG.height / 2);
		dog.frames = Paths.getSparrowAtlas('loadingDog');
		dog.animation.addByPrefix('loadDog','loading dog');
		dog.setGraphicSize(Std.int(dog.width * 0.8));
        dog.antialiasing = true;
		dog.alpha = 1;
		dog.animation.play('loadDog');

        toBeDone = Lambda.count(images);
        
        barBG = new FlxSprite(50,FlxG.height / 2 + 180).loadGraphic(Paths.image('loadingbar'));
		barBG.screenCenter(X);

		bar = new FlxBar(barBG.x + 60,barBG.y + 100,FlxBarFillDirection.LEFT_TO_RIGHT,Std.int(barBG.width - 118), Std.int(barBG.height - 130) ,this,
        "barProgress",0,100);
		bar.numDivisions = 100;
		bar.createFilledBar(FlxColor.RED, FlxColor.YELLOW);
		runningpaps.x = bar.x;
		runningpaps.y = bar.y - 300;

        add(BG);
		add(bar);
		add(runningpaps);
		add(barBG);

		add(text);
		add(dog);
        

        sys.thread.Thread.create(() ->
		{
            for (i in images)
                {
                    thing = 'Bones';
                    var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
                    var graph = FlxGraphic.fromBitmapData(data);
                    graph.persist = true;
                    graph.destroyOnNoUse = false;
                    bitmapData.set(i.replace(".png", ""),graph);
                    updatePros();
                }
		});

        super.create();
    }
    override function update(elaspsed) 
    {
        super.update(elaspsed);			
        if (!loaded){
				if (barProgress != 100)
					{
						text.text = "Loading " + thing;
						runningpaps.x = bar.x - (bar.width * (FlxMath.remapToRange(bar.percent, 0, 100, 100, 0) * 0.01) - 700);
					}
                else{
                    
                    loaded = true;
                    cache(); 
                }
        }
    }
    //taken from kade
    function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

    function updatePros() 
    {
        done++;
        barProgress = truncateFloat(done / Lambda.count(images) * 100, 2);
        
    }
    function cache() 
    {
        var whobones:Int = FlxG.random.int(0,1);
        if (whobones == 1)
            text.text = 'LOADED AND PREPARED HUMAN!!';
        if (whobones == 0)
            text.text = 'loaded kid';
        text.screenCenter(X);
        dog.visible = false;
        runningpaps.visible = false;
        bar.visible = false;
        barBG.visible = false;
        FlxG.sound.play(Paths.sound('undertale Save'));
        FlxTween.tween(BG, {alpha: 0}, 1, {
            onComplete: function(twn:FlxTween)
				{
					FlxG.switchState(new TitleState());
				}
			});
    }
}