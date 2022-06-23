package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		super();

		var wasAtTime = Conductor.songPosition;

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, 'bf');
		add(bf);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if(PlayState.SONG.song == "velmas-spam-challenge") {
			var seconds = wasAtTime/1000;
			var minutes = Math.floor(seconds / 60);
			var hours = Math.floor(minutes / 60);

			seconds = Math.floor(seconds) % 60;

			var sMin = Std.string(minutes % 60);
			var sHr = Std.string(hours % 24);

			var dateString = '';
			if(sHr != "0") {
				dateString += sHr + ' hour';
				if(sHr != "1") dateString += "s";
				dateString += " ";
			}
			if(sHr != "0" || sMin != "0") {
				dateString += sMin + ' minute';
				if(sMin != "1") dateString += "s";
				dateString += " ";
			}
			dateString += Std.string(seconds) + ' second';
			if(seconds != 1) dateString += "s";

			var lasted = new FlxText(0, 20, 0, 'You lasted\n$dateString\n', 64);
			lasted.setFormat("VCR OSD Mono", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			lasted.scrollFactor.set();
			lasted.screenCenter(X);
			add(lasted);

			var scoreText = new FlxText(0, FlxG.height - 128, 0, 'SCORE\n${PlayState.instance.songScore}\n', 64);
			scoreText.setFormat("VCR OSD Mono", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreText.scrollFactor.set();
			scoreText.screenCenter(X);
			add(scoreText);
		}

		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		#if mobileC
		addVirtualPad(NONE, A_B);
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new MainMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
