package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;
	var blockRetry:Bool = false;
	var disableMecha:Bool = false;

	var failDialogue:Array<String> = [
		"YOU LOST HUMAN, NOW ILL TAKE YOU TO THE CAPTURE ZONE!!",
		"PSST, HUMAN, BLUE MEANS THAT YOU HAVE TO STOP MOVING...OR SINGING",
		"NYEH HEH HEH ITS SEEMS THAT I, THE GREAT PAPYRUS IS THE BETTER SINGER",
		"DON'T TOUCH THOSE RED NOTES!!, SANS SPILLED KETCHUP ALL OVER THEM",
		"YOU CAN DO BETTER, KEEP GOING HUMAN!!",
		"SANS WHAT DOES 'BLUE BALLED' MEAN!!",
	];
	var stageSuffix:String = "";
	var act:Bool = true;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{	
		super();

		if (ClientPrefs.languageType == "Espanol"){
			failDialogue = [
				"PERDISTE HUMANO, AHORA TE LLEVARE A LA ZONA DE CAPTURA!!",
				"PSST, HUMANO, AZUL SIGNIFICA QUE NO TE TIENES QUE MOVER... O CANTAR",
				"NYEH HEH HEH PARECE QUE YO, EL GRAN PAPYRUS ES EL MEJOR CANTANTE",
				"NO TOQUES ESAS NOTAS ROJAS, SANS DERRAMO KETCHUP SOBRE ELLAS",
				"LO PUEDES HACER MEJOR, SIGUE INTENTANDO HUMANO!!",
				"SANS QUE SIGNIFICA LAS 'BOLAS AZULES'!!",
				"ASI QUE.... HUMANO..... TE GUSTAN LOS PUZZLES?",
				"HUMANO, TE VES FAMILIAR.... NOS HEMOS CONOCIDO ANTES??",
			];
		}
		
		var Ran:Int = FlxG.random.int(0, 5);
		resetVariables();

		var offset:Float = 0;
		if(PlayState.dialBOY.curCharacter == 'bf-papyrus'){
			characterName += 'paps';
			deathSoundName = 'papy loss';
			loopSoundName = 'PapsGameOver';
		}
		else if(PlayState.dialBOY.curCharacter == 'bf-butFuckingdead'){
			characterName += 'ButevenmoreDead';
		}
		else {
			if (PlayState.blastedBF){
				characterName += 'Toasted';
				deathSoundName = 'blasted';
				offset = -500;
			}
			if (PlayState.curStage == 'forest'){
				characterName += 'bones';
				deathSoundName = "bonked";
			}
		}


		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y + offset) ;

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		if (PlayState.deathCounter == 5 && !ClientPrefs.disableMecha){
			blockRetry = true;
			act = false;
		}
		if(PlayState.deathCounter != 5 && PlayState.SONG.player2 == 'papyrus' || PlayState.deathCounter != 5 && PlayState.SONG.player2 == 'papTwo')
		{
			PlayState.failDial.resetText("*" + failDialogue[Ran]);
			add(PlayState.failBox);
			PlayState.failBox.animation.play('normal');
			add(PlayState.failDial);
			PlayState.failDial.start(0.04,true);

		}	
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var changeMechaDial:Array<String> = [
			"* YOU SEEM TO BE STRUGGLING HUMAN.. WOULD YOU LIKE TO DISABLE MECHANICS?",
			"* Do you want to disable mechanics?",
			"* ALRIGHTY THEN!!",
			"* OH... REMEMBER THAT YOU CAN DISABLE THEM ON THE OPTIONS MENU!"
		];
		if (ClientPrefs.languageType == "Espanol"){
			changeMechaDial = [
				"* PARACE QUE TIENES PROBLEMAS HUMANO.. QUIERES DESACTIVAR LAS MECHANICAS?",
				"* Quieres desactivar las mechanicas?",
				"* MUY BIEN ENTONCES",
				"* OH... RECUERDA QUE PUEDES DESACTIVARLAS EN EL MENU DE OPCIONES!"
			];
		}
		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (act && controls.ACCEPT)
			{
				if(!blockRetry)
					endBullshit();
				else
				{
					act = false;
					ClientPrefs.disableMecha = disableMecha;
					FlxG.save.flush();
					remove(PlayState.accept);
					remove(PlayState.decline);
					PlayState.failDial.sounds = [FlxG.sound.load(Paths.sound('Pap talk'), 0.6)];
					PlayState.failDial.font = "Papyrus";
					if (disableMecha)
						PlayState.failDial.resetText(changeMechaDial[2]);
					else
						PlayState.failDial.resetText(changeMechaDial[3]);
					PlayState.failDial.start(0.04,true, false, null, function() 
						{
							blockRetry = false;
							act = true;
						});
				}
			}

		if (act && controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}
		if (blockRetry && controls.UI_LEFT_P && PlayState.decline.color == FlxColor.YELLOW)
		{
			disableMecha = true;
			PlayState.decline.color = FlxColor.WHITE;
			PlayState.accept.color = FlxColor.YELLOW;
		}
		else if (blockRetry && controls.UI_RIGHT_P && PlayState.accept.color == FlxColor.YELLOW)
		{
			disableMecha = false;
			PlayState.decline.color = FlxColor.YELLOW;
			PlayState.accept.color = FlxColor.WHITE;
		}
		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else
				{
					if (PlayState.deathCounter == 5 && !ClientPrefs.disableMecha)
						{				
							add(PlayState.failBox);
							PlayState.failBox.animation.play('normal');
							add(PlayState.failDial);							
			
							PlayState.failDial.resetText(changeMechaDial[0]);
							PlayState.failDial.start(0.04,true, false, null, function() 
							{
								new FlxTimer().start(2, function(tmr:FlxTimer) 
								{
									PlayState.failDial.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
									PlayState.failDial.resetText(changeMechaDial[1]);
									PlayState.failDial.font = "Determination Sans";
									PlayState.failDial.start(0.04,true, false, null, function() 
									{
										trace("add");
											add(PlayState.accept);
											add(PlayState.decline);		
											act = true;
									});
								});
			
							});
						}
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					if (PlayState.tutorialDeath){
						FlxG.sound.music.play();
						PlayState.endsongonDeath();
					}
					else{
						MusicBeatState.resetState();
					}
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
