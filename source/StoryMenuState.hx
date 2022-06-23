package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

//---------------------------------------
//THIS HOLE THING IS OBSOLETE
//---------------------------------------

class StoryMenuState extends MusicBeatState
{
	var weekData:Array<Dynamic> = [
		['velma-style-whats-new', 'terror-time', 'jinkies', 'surface', 'velmas-spam-challenge', 'the-end'] 
	];
	var curDifficulty:Int = 2;

	public static var weekUnlocked:Array<Bool> = [true];

	var weekCharacters:Array<Dynamic> = [
		['dad', 'bf', 'gf']
	];

	var weekNames:Array<String> = [
		"Velma Chaos Remastered Week",
	];

	var curWeek:Int = 0;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}
		if (FlxG.save.data.progress > 0)
		{
			weekUnlocked[2] = true;
			if (FlxG.save.data.progress > 1)
			{
				weekUnlocked[3] = true;
			}
		}

		persistentUpdate = persistentDraw = true;

		selectWeek();
	}

	override function update(elapsed:Float)
	{
		Main.skipDes = false;

		super.update(elapsed);
	}

	var selectedWeek:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			if (Main.diff == 1) diffic = '-hard';

			PlayState.storyDifficulty = Main.diff + 1;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			LoadingState.loadAndSwitchState(new PlayState(), true);
		}
	}
}
