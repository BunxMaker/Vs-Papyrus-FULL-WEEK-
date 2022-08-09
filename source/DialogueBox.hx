package;

import flixel.FlxObject;
import lime.media.FlashAudioContext;
import flixel.system.FlxSound;
import haxe.CallStack.StackItem;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.gamepad.id.SwitchJoyconRightID;
import haxe.macro.Expr.Case;
import haxe.io.Path;
import haxe.display.Display.Package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

//Probably "Inspired"
class Portrait extends FlxSprite
{
    private var posX:Float;
    private var posY:Float;
	var emoteArray:Array<Array<String>> = [[]];

    public function new(x:Float, y:Float,character:String) 
    {
        super(x, y);
		switch (character)
		{
			case 'bf': emoteArray = [
				['normal', 'BF express Normal']
			];
			case "pap": emoteArray = [
				['normal','Paps express Normal'],
				['proud','Paps expression Proud'],
				['happy','Paps expression hapy'],
				['think','Paps expression think'],
				['ego','Paps expression ego'],
				['angry','Angry paps']
				];
			case "sans": emoteArray = [
				['normal','sans normal'],
				['comic','sans comic'],
				['wink','sans wink'],
				['bad','sans bad'],
				['closed','sans closed']
			];
		}



        chars_(emoteArray,character);
        scrollFactor.set();
        antialiasing = true;

        posX = x;
        posY = y;
        playanim();
        hide();
    }
    public function chars_(emote:Array<Array<String>>, character:String) {
		frames = Paths.getSparrowAtlas("UT dialogue/" + character,'shared');
		
		for (i in 0...emote.length)
		{
			animation.addByPrefix(emote[i][0], emote[i][1],24,true);
			animation.addByIndices(emote[i][0] + 'Idle', emote[i][1],[1],"",24,false);
		}
		animation.play('normal');
		
	}
    public function playanim(?frame:String = 'normal'){

        visible = true;
        animation.play(frame);
        updateHitbox();

        x = posX;
        y = posY;

    }
    public function hide() {
        visible = false;   
    }

}


class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var curAnim:String = '';
	var emoteanim:String = '';
	
	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var gasterdial:FlxTypeText;
	var numchar:Int = 0;
	var skip:FlxText;

	var dropText:FlxText;
	var finishedtext:Bool = false;
	public var cheating:Bool = false;
	public var campointing:Array<Float> = [0,0];
	var music:FlxSound;

	public var finishThing:Void->Void;
	public var camPointdial:Array<Float>->Void;

	var portraitPAP:Portrait;
	var portraitSANS:Portrait;
	var portraitBF:Portrait;

	var arrayea:Array<Portrait>;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new( ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;

		box = new FlxSprite(0, 470);

		switch (PlayState.SONG.player2)
		{
			case 'papyrus', 'papTwo':
				music = new FlxSound().loadEmbedded(Paths.music('Undertale Nyeh Heh Heh!'),true, true);
				FlxG.sound.list.add(music);
			case 'MysteryMan':
				music = new FlxSound().loadEmbedded(Paths.music('Undertale Premonition'),true, true);
				FlxG.sound.list.add(music);
		}

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{	
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('UT dialogue/UT Dial', 'shared');
				box.animation.addByPrefix('normalOpen', 'BOX', 24, false);
				box.animation.addByIndices('normal', 'BOX Normal', [0], "", 24);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

		box.animation.play('normalOpen');
		add(box);
		box.screenCenter(X);

		portraitBF = new Portrait(130, 490,'bf');
		add(portraitBF);
		portraitPAP = new Portrait(150, 490,'pap');
		add(portraitPAP);
		portraitSANS = new Portrait(150, 490,'sans');
		add(portraitSANS);

		arrayea = [portraitBF,portraitPAP,portraitSANS];

		if (PlayState.SONG.player2 == 'MysteryMan')
			{
				gasterdial = new FlxTypeText(150, 502, Std.int(FlxG.width * 0.6), "", 32);
				gasterdial.font = 'Determination Sans';
				gasterdial.color = 0xffffffff;
				gasterdial.alpha = 0;
				add(gasterdial);
			}
	
		swagDialogue = new FlxTypeText(402, 502, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Determination Sans';
		swagDialogue.color = 0xffffffff;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		skip = new FlxText(20, (FlxG.height * 0.1) - 55, 0, "Press Esc to skip dialogue");
		skip.setFormat(Paths.font("DTM-Sans.otf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(skip);
		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
		if (ClientPrefs.languageType == "Espanol")
			skip.text = "Presiona ESC para saltear el dialogo";
	}
	var ok:FlxTextFormat = new FlxTextFormat(0xFFF8FF00,false,false,0xFFF8FF00);
	var markerBool:Bool = false;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dog:Bool = false;
	var oGCamZoom:Float = PlayState.defaultCamZoom;

	override function update(elapsed:Float)
	{
		
		if (dog){
			campoint("DOG");
		}
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			if(cheating)
				remove(skip);
			startDialogue();
			dialogueStarted = true;	
			if (!cheating){
				music.volume = 0.4;	
				music.play();
			}
		}

		if (PlayerSettings.player1.controls.BACK && dialogueStarted && !isEnding && !cheating)
		{
			isEnding = true;

			if (music != null && music.playing)
				music.fadeOut(2);
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
						
					portraitBF.visible = false;
					portraitPAP.visible = false;
					portraitSANS.visible = false;
					swagDialogue.alpha -= 1 / 5;
				}, 5);
	
				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					FlxG.sound.music.stop();
					finishThing();
					kill();
				});
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (music != null && music.playing)
						music.fadeOut(2);
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						
						portraitBF.visible = false;
						portraitPAP.visible = false;
						portraitSANS.visible = false;
						swagDialogue.alpha -= 1 / 5;
					}, 5);
					
					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						PlayState.defaultCamZoom = oGCamZoom;
						FlxG.camera.zoom = oGCamZoom;
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;
	var textendeded:Bool = false;
	var eventsList:Array<String> = [""];
	var eventsParam:Array<Array<String>> = [[""]];
	var cutoff:Bool = false;

	function gasterWindings() 
	{
		
		new FlxTimer().start(0.1, function(tmr:FlxTimer) 
		{
			var tim:Int = FlxG.random.int(1,7);
			var bool:Bool = false;

			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('WingDing_Talk($tim)'), 0.6)];

			if (textendeded)
				bool = true;
			if (!bool)
			{
				tmr.reset(0.1);
			}

		});
	}

	function enddial() 
	{
		if (cutoff){
			new FlxTimer().start(0.2, function(tmr:FlxTimer) 
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
				cutoff = false;
			});
		}
		if (numchar != 6)
			arrayea[numchar].playanim(curAnim +'Idle');
		textendeded = true;

		if (gasterdial != null && numchar == 6)
			{
				swagDialogue.alpha = 0.3;
				gasterdial.alpha = 1;
			}
	}


	function startDialogue():Void
	{
		numchar = 0;
		textendeded = false;
		swagDialogue.x = 402;
		
		var skipDial:Bool = false;
		box.visible = true;	
		var marker:FlxTextFormatMarkerPair = new FlxTextFormatMarkerPair(ok,'@');

		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);
		for (i in 0...arrayea.length){
			arrayea[i].hide();
		}
		// swagDialogue.text = ;
		if (gasterdial != null)
		{
			swagDialogue.alpha = 1;
			gasterdial.alpha = 0;

			gasterdial.resetText(dialogueList[0]);
			gasterdial.start(0.04,true);
		}
		switch (curCharacter)
		{   case 'bf':
				
				numchar = 0;
				portraitBF.playanim(curAnim);
				if (emoteanim != ""){
					PlayState.dialBOY.playAnim(emoteanim);
					campoint('bf');
				}
				swagDialogue.x = 450;
				swagDialogue.font = 'Determination Sans';
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bf'), 0.6)];
				
			case 'pap':	
				numchar = 1;
				if (emoteanim != ""){
					PlayState.dialDAD.playAnim(emoteanim);
					campoint('dad');
				}
				portraitPAP.playanim(curAnim);
				swagDialogue.font = 'Papyrus';
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('Pap talk'), 0.6)];
				
			case 'sansgf' | 'sans':			
				numchar = 2;
				if (curCharacter == 'sansgf' && emoteanim != ""){
					campoint('gf');
					PlayState.dialGF.playAnim(emoteanim);
				}
				else if (emoteanim != ""){
					campoint('sans');
					PlayState.sansdad.playAnim(emoteanim);
				}
				portraitSANS.playanim(curAnim);
				swagDialogue.font = 'Comic Sans MS';
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('San talk'), 0.6)];
			case 'gaster':
				numchar = 6;
				swagDialogue.x = 150;
				
				swagDialogue.font = 'Wingdings';// gotta fix the font thing
				if (emoteanim != ""){
					PlayState.dialDAD.playAnim(emoteanim);
					campoint('dad');
				}
				gasterWindings();
				// make a image with the wingdings alr made
			case 'effect':
				eventsList.push(curAnim);
				var slpiiit:Array<String> = emoteanim.split("|");
				eventsParam.push(slpiiit);
				trace(eventsParam);
				if(!(curAnim == "DogEvent"))
					skipDial = true;
			case 'text':
				numchar = 6;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
				swagDialogue.x = 150;
				swagDialogue.font = 'Determination Sans';
		}		
		if (!skipDial){
			swagDialogue.applyMarkup(dialogueList[0],[marker]);	
			swagDialogue.start(0.04, true);
			swagDialogue.completeCallback = enddial;
			eventsshit();
		}
		else{
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
		
	}

	function cleanDialog():Void
	{

		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curAnim = splitName[2];
		emoteanim = splitName[3];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + splitName[3].length + 4).trim();
	}

	function eventsshit() 
	{
		for (i in 0...eventsList.length)
		{
			switch (eventsList[i])
			{
				case "CamZoom":
					PlayState.defaultCamZoom = Std.parseFloat(eventsParam[i][0]);
					FlxG.camera.zoom = Std.parseFloat(eventsParam[i][0]);
					trace(Std.parseFloat(eventsParam[i][0]));
					
					trace(eventsParam[i]);
				case "DogEvent":
					dogevent();
				case "cutoff":
					cutoff = true;
				case "PlayMusic":
					var ok:String = "";
					var music:FlxSound;
					switch (eventsParam[i][0])
					{
						case 'nyeh': ok = 'Undertale Nyeh Heh Heh!';
						case 'gast': ok = 'Undertale Premonition';
						case 'dog': ok = 'Undertale Dogsong';
					}
					FlxG.sound.music.stop();
					music = new FlxSound().loadEmbedded(Paths.music(ok),true,true);
					music.volume = 0.4;
					music.play();
					FlxG.sound.list.add(music);
				case "MusicFadeout":
					music.fadeOut(Std.parseFloat(eventsParam[i][0]));
					trace('ok');
				case "MusicStop":
					FlxG.sound.music.stop();
			}
		}
		eventsList = [""];
		eventsParam = [[""]];
	}
	function campoint(cha:String) 
	{
		switch (cha)
		{
			case "bf":
				campointing =[
					PlayState.dialBOY.getMidpoint().x,
					PlayState.dialBOY.getMidpoint().y
				];
			case "dad":
				campointing =[
					PlayState.dialDAD.getMidpoint().x  - 100,
					PlayState.dialDAD.getMidpoint().y - 100
				];
			case "gf":
				campointing =[
					PlayState.dialGF.getMidpoint().x - 100,
					PlayState.dialGF.getMidpoint().y - 100
				];
			case "DOG":
				campointing =[
					PlayState.dog.getMidpoint().x - 100,
					PlayState.dog.getMidpoint().y - 100
				];
			case "sans":
				campointing =[
					PlayState.sansdad.getMidpoint().x - 100,
					PlayState.sansdad.getMidpoint().y - 100
				];
		}	
		if(!cheating)
			camPointdial(campointing);
	}
	function dogevent() 
	{
		box.visible = false;
		FlxTween.tween(PlayState.dog, {x: 2100}, 8, {ease: FlxEase.sineInOut});	
		
		new FlxTimer().start(2,function(tmr:FlxTimer) 
		{
			dog = true;
			FlxG.sound.playMusic(Paths.music('Undertale Dogsong'));
		});	
		new FlxTimer().start(5,function(tmr:FlxTimer) 
		{
			dog = false;
			campoint("bf");
			FlxG.sound.music.fadeOut(2);
		});
			
	}
}
