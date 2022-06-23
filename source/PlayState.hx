package;

import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.display.FPS;
import ui.Hitbox;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var mania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9];

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	private var vocals:FlxSound;

	private var isEnd = false;
	private var dad:Character;
	private var dadRemastered:Character;
	private var curDad:Character;
	private var dad2:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	private var shaggyT:FlxTrail;
	private var ctrTime:Float = 0;
	private var notice:FlxText;
	private var nShadow:FlxText;

	var songEnded:Bool = false;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dface:Array<String> = ['f_bf'];
	var dside:Array<Int> = [1];

	var fc:Bool = true;

	var talking:Bool = true;
	public var songScore:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var burst:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	var cs_reset:Bool = false;

	var exDad:Bool = false;

	var dSound = 0;
	var dSoundList:Array<String> = ['fnf_loss_sfx', 'fnf_loss_shaggy', 'fnf_loss_matt'];

	var defaultYDad:Float = 0;

	var _hitbox:Hitbox;

	override public function create()
	{
		instance = this;

		theFunne = FlxG.save.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		dSound = 0;

		repPresses = 0;
		repReleases = 0;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		mania = SONG.mania;
		
		switch (SONG.song.toLowerCase())
		{
			//case 'tutorial':
			//	dialogue = ["Hey you're pretty cute.", 'suck my clit or you die.'];
			
			case 'velma-style-whats-new':
				dialogue = [
					"Beep!",
					"Oh hey, you must be that Boyfriend\nguy Shaggy told me about!",
					"What are you doing out here?",
					"Skebeep boop de bap",
					"Hmm, a rap battle?",
					"Well, Shaggy did mention you\nwere a fan of singing...",
					"So I'm glad he taught me all\nabout it!",
					"Beep ske boop?",
					"You can count on it!",
					"So... let's start with a song\nyou may be familiar with."
				];
				dface = [
						"f_bf_burn",
						"f_sh",
						"f_sh_pens",
						"f_bf_burn",
						"f_sh_ser",
						"f_sh_ser",
						"f_sh",
						"f_bf_a",
						"f_sh",
						"f_sh"
						];
				dside = [-1, 1, 1, -1, 1, 1, 1, -1, 1, 1];
			case 'surface':
				dialogue = [
					"ENOUGH, I WILL NOT TOLERATE YOUR INSULTS\nANYMORE, THIS IS NOT MORE A GAME,\nTHIS IS REALITY...",
					"Oops, I think I messed up..."
				];
				dface = [
						"f_sh_kill",
						"f_bf_scared"
						];
				dside = [1, -1];

			case 'the-end':
				dialogue = [
					"Oh, hey Shaggy...",
					"What's up Dinkley...",
					"What a great night...",
					"Yeah, it's like, amazing.",
					"Would you like to relax singing\na song?",
					"Sure, Dinkley, I also heard that\n'Boyfriend' guy, was here,\nis that true?",
					"Yeah, we sang some songs!",
					"I see...",
					"So, let's like get on the mood!",
					"Yeah, let's sing!",
				];
				dface = [
						"f_sh",
						"f_sh_con", 
						"f_sh",
						"f_sh_con",
						"f_sh", 
						"f_sh_con", 
						"f_sh",
						"f_sh_con", 
						"f_sh_con",
						"f_sh"
						];
				dside = [-1, 1, -1, 1, -1, 1, -1, 1, 1, -1];
			
			  case 'terror-time':
				dialogue = [
					"Shaggy really wasn't lying when\nhe said you had the skills...",
					"Bap beepabopa...",
					"You wanna sing another one? I have\nquite a few songs I'd like\nto show you.",
					"Bop bap boop!",
					"Ok, here we go!"
				];
				dface = [
						"f_sh",
						"f_bf",
						"f_sh_pens",
						"f_bf_burn",
						"f_sh"
						];
				dside = [1, -1, 1, -1, 1];
			case 'jinkies':
				dialogue = [
					"Jinkies! That was intense, wanna\ndo it again?",
					"...",
					"...?",
					"Okay, I'm tired of pretending.",
					"Huh?",
					"I hate to break it to ya but...",
					"Your songs are just blatantly\nboooooring.",
					"Jeez, I feel like I'm about to\nfall asleep.",
					"Why are you-",
					"I thought he would have taught\nyou better than this.",
					"Not that you could have been\nany better than him.",
					"To be honest, you were just a\nnerd who was lucky enough\nto appear in the show.",
					"...",
					"I'm just telling ya the truth.",
					"...",
					"Heh.",
					"Bold of you to assume this is\nall he taught me.",
					"We've only just started.",
					"...I might have spoken too soon."
				];
				dface = [
						"f_sh",
						"f_bf",
						"f_sh_ser",
						"f_bf",
						"f_sh_pens",
						"f_bf",
						"f_bf",
						"f_bf",
						"f_sh_ser",
						"f_bf",
						"f_bf",
						"f_bf",
						"f_sh_ser",
						"f_bf_burn",
						"f_sh_ser",
						"f_sh_kill",
						"f_sh_kill",
						"f_sh_kill",
						"f_bf"

						];
				dside = [1, -1, 1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, 1, 1, -1];
			case 'velmas-spam-challenge':
				dialogue = [
					"Impressive!", 
					"I never thought you would be this\ntalented, you even managed\nto beat me first try!", 
					"Emphasis on that 'first try'.",
					"Oh right, Shaggy did mention\nsomething about your\ntime resetting abilities...",
					"And I suppose it took you quite\nsome effort to get\npast this.",
					"...",
					"If I challenged you with one\nlast song, would you\nbe capable of-",
					"OF COURSE! BRING IT ON!",
					"Also, just one more thing.",
					"Hm?",
					"Sorry for being that rude\nearlier, I was just trying\nto test ya.",
					"I just really wanted to see\nwhat you could do, but I\nmight have taken it too far.",
					"You did say it quite suddenly,\nso I guess I shouldn't have\ntakenit that seriously, pfft...",
					"Anyway... you think you're up\nto this last challenge?",
					"You bet!"

				];
				dface = [

						"f_sh_ang",
						"f_sh_ang",
						"f_bf",
						"f_sh_happy",
						"f_sh_sad",
						"f_sh_sad",
						"f_sh",
						"f_bf_burn",
						"f_bf",
						"f_sh_pens",
						"f_bf",
						"f_bf",
						"f_sh",
						"f_sh",
						"f_bf_burn"

						];
				dside = [1, 1, -1, 1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, -1];
		}

		var sn = SONG.song.toLowerCase();

		if (sn == 'the-end' || sn == 'velma-style-whats-new' || sn == 'terror-time' || sn == 'jinkies')
		{
			//dad.powerup = true;
			defaultCamZoom = 0.9;
			curStage = 'stage_2';
			var bg:FlxSprite = new FlxSprite(-400, -160).loadGraphic(Paths.image('velmabackground'));
			bg.setGraphicSize(Std.int(bg.width * 1.5));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.95, 0.95);
			bg.active = false;
			add(bg);
		}
		else if (sn == 'surface' || sn == 'velmas-spam-challenge')
		{
			//dad.powerup = true;
			defaultCamZoom = 0.9;
			curStage = 'boxing';
			var bg:FlxSprite = new FlxSprite(-400, -220).loadGraphic(Paths.image('SkyBG'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.8, 0.8);
			bg.active = false;
			add(bg);
		}
		else
		{
			defaultCamZoom = 0.8;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-900, -700).loadGraphic(Paths.image('stageback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		dad = new Character(100, 100, SONG.player2);
		curDad = dad;

		isEnd = SONG.song == "the-end";
		
		if(isEnd) {
			dadRemastered = new Character(100, 100, "shagremaster");
			dadRemastered.active = false;
			dadRemastered.visible = false;
		}

		if (exDad)
		{
			dad2 = new Character(280, 100, "dad");
		}

		scoob = new Character(9000, 290, 'scooby', false);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case "spooky":
				dad.y += 200;
			case 'matt':
				dad.y += 320;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'velma':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'velmamad':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'velmagod':
				dad.x -= 150;
				dad.y += 50;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		defaultYDad = dad.y;

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'stage_2':
				boyfriend.y -= 20;
			case 'boxing':
				boyfriend.x += 130;
		}

		if (SONG.player2 == 'pshaggy')
		{
			shaggyT = new FlxTrail(dad, null, 5, 7, 0.3, 0.001);
			add(shaggyT);
		}

		if(SONG.player1 == "velma") {
			boyfriend.y -= 200;
		}

		if (exDad) add(dad2);
		add(dad);
		if(isEnd) add(dadRemastered);
		add(boyfriend);

		add(scoob);

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;


		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		var kadeEngineWatermark = new FlxText(4,FlxG.height - 4,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + " - KE " + MainMenuState.kadeEngineVer, 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		var icnChar = SONG.player2;
		if (exDad)
		{
			icnChar = 'both';
		}
		iconP2 = new HealthIcon(icnChar, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		var curcontrol:HitboxType = DEFAULT;

		switch (SONG.song.toLowerCase()){
			case 'surface' | 'velmas-spam-challenge':
				curcontrol = SIX;
			default:
				curcontrol = DEFAULT;
		}
		_hitbox = new Hitbox(curcontrol);

		var camcontrol = new FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		_hitbox.cameras = [camcontrol];

		_hitbox.visible = false;

		add(_hitbox);

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "tutorial":
					startCountdown();
					FlxG.camera.zoom = 1;

				case 'surface':
					imageIntro();

				default:
					if (!Main.skipDes)
					{
						schoolIntro(0);
						Main.skipDes = true;
					}
					else
					{
						startCountdown();
					}
			}
		}
		else
		{
			startCountdown();
		}

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}

	var tb_x = 60;
	var tb_y = 410;
	var tb_fx = -510 + 40;
	var tb_fy = 320;
	var tb_rx = 200 - 55;
	var jx:Int;

	var curr_char:Int;
	var curr_dial:Int;
	var dropText:FlxText;
	var tbox:FlxSprite;
	var talk:Int;
	var tb_appear:Int;
	var dcd:Int;
	var fimage:String;
	var fsprite:FlxSprite;
	var fside:Int;
	var black:FlxSprite;
	var tb_open:Bool = false;

	function imageIntro():Void
	{
		var black = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
		black.cameras = [camHUD];
		black.scrollFactor.set();
		var background:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('velmagodlol'));
		background.cameras = [camHUD];
		background.scrollFactor.set();
		background.setGraphicSize(1280, 720);
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = true;
		background.alpha = 0;

		add(black);
		add(background);

		FlxTween.tween(background, {alpha:1}, 2 /*seconds*/, {onComplete: (_) -> {
			remove(black);
		}});

		healthBarBG.visible = false;
		healthBar.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		new FlxTimer().start(20.0, function(tmr:FlxTimer)
		{
			FlxTween.tween(background, {alpha:0}, 2 /*seconds*/, {onComplete: (_) -> {
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
				remove(background);
				startCountdown();
			}});
		});
	}

	function schoolIntro(btrans:Int):Void
	{
		black = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var dim:FlxSprite = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		dim.alpha = 0;
		dim.scrollFactor.set();
		add(dim);

		if (black.alpha == 1)
		{
			dropText = new FlxText(140, tb_y + 25, 2000, "", 32);
			curr_char = 0;
			curr_dial = 0;
			talk = 1;
			tb_appear = 0;
			tbox = new FlxSprite(tb_x, tb_y, Paths.image('TextBox'));
			fimage = dface[0];
			faceRender();
			tbox.alpha = 0;
			dcd = 7;

			if (btrans != 1)
			{
				dcd = 2;
				black.alpha = 0.15;
			}
		}
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		if (!tb_open)
		{
			tb_open = true;
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				black.alpha -= 0.15;
				dcd --;
				if (dcd == 0)
				{
					tb_appear = 1;
				}
				tmr.reset(0.3);
			});
			if (talk == 1 || tbox.alpha >= 0)
			{
				new FlxTimer().start(0.03, function(ap_dp:FlxTimer)
				{
					
					if (tb_appear == 1)
					{
						if (tbox.alpha < 1)
						{
							tbox.alpha += 0.1;
						}
					}
					else
					{
						if (tbox.alpha > 0)
						{
							tbox.alpha -= 0.1;
						}
					}
					dropText.alpha = tbox.alpha;
					fsprite.alpha = tbox.alpha;
					dim.alpha = tbox.alpha / 2;
					ap_dp.reset(0.05);
				});
				var writing = dialogue[curr_dial];
				new FlxTimer().start(0.03, function(tmr2:FlxTimer)
				{
					if (talk == 1)
					{
						var newtxt = dialogue[curr_dial].substr(0, curr_char);
						if (curr_char <= dialogue[curr_dial].length && tb_appear == 1)
						{
							if (dside[curr_dial] == 1 || curSong.toLowerCase() != "revenge")
							{
								FlxG.sound.play(Paths.sound('pixelText'));
							}
							else
							{
								FlxG.sound.play(Paths.sound('pixelBText'));
							}
							curr_char ++;
						}

						fsprite.updateHitbox();
						fsprite.scrollFactor.set();
						if (dside[curr_dial] == -1)
						{
							fsprite.flipX = true;
						}
						add(fsprite);

						tbox.updateHitbox();
						tbox.scrollFactor.set();
						add(tbox);


						dropText.text = newtxt;
						dropText.font = 'Pixel Arial 11 Bold';
						dropText.color = 0x00000000;
						dropText.scrollFactor.set();
						add(dropText);
					}
					tmr2.reset(0.03);
				});

				new FlxTimer().start(0.001, function(prs:FlxTimer)
				{
					#if mobile
					var justTouched:Bool = false;

					for (touch in FlxG.touches.list)
					{
						justTouched = false;

						if (touch.justReleased){
							justTouched = true;
						}
					}
					#end

					var skip:Bool = false;
					if (FlxG.keys.justReleased.ANY #if mobile || justTouched #end || skip)
					{
						if ((curr_char <= dialogue[curr_dial].length) && !skip)
						{
							curr_char = dialogue[curr_dial].length;
						}
						else
						{
							curr_char = 0;
							curr_dial ++;

							if (curr_dial >= dialogue.length)
							{
								if (cs_reset)
								{
									if (skip)
									{
										tbox.alpha = 0;
									}
									cs_wait = false;
									cs_time ++;
								}
								else
								{
									startCountdown();
								}
								talk = 0;
								dropText.alpha = 0;
								curr_dial = 0;
								tb_appear = 0;
							}
							else
							{
								//if (dialogue[curr_dial] == sh_kill_line)
								//{
								//	cs_mus.stop();
								//}
								fimage = dface[curr_dial];
								if (fimage != "n")
								{
									fsprite.destroy();
									faceRender();
									fsprite.flipX = false;
									if (dside[curr_dial] == -1)
									{
										fsprite.flipX = true;
									}
								}
							}
						}
					}
					prs.reset(0.001 / (FlxG.elapsed / (1/60)));
				});
			}
		}
	}
	function faceRender():Void
	{
		jx = tb_fx;
		if (dside[curr_dial] == -1)
		{
			jx = tb_rx;
		}
		fsprite = new FlxSprite(tb_x + Std.int(tbox.width / 2) + jx, tb_y - tb_fy, Paths.image(fimage));
		fsprite.centerOffsets(true);
		fsprite.antialiasing = true;
		fsprite.updateHitbox();
		fsprite.scrollFactor.set();
		add(fsprite);
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var noticeB:Array<FlxText> = [];
	var nShadowB:Array<FlxText> = [];

	function startCountdown():Void
	{
	  _hitbox.visible = true;

		inCutscene = false;

		hudArrows = [];
		generateStaticArrows(0);
		generateStaticArrows(1);
		FlxG.camera.angle = 0;

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (SONG.song.toLowerCase() == "surface" || SONG.song.toLowerCase() == "velmas-spam-challenge")
		{
			new FlxTimer().start(0.002, function(cbt:FlxTimer)
			{
				if (ctrTime == 0)
				{
					var cText = "S      D      F      J      K      L";

					if (FlxG.save.data.dfjk == 0)
					{
						cText = "A      S      D";
					}
					else if (FlxG.save.data.dfjk == 2)
					{
						cText = "Z      X      C      1      2      3";
					}
					notice = new FlxText(0, 0, 0, cText, 32);
					notice.x = FlxG.width * 0.572;
					notice.y = 120;
					if (FlxG.save.data.downscroll)
					{
						notice.y = FlxG.height - 200;
					}
					notice.scrollFactor.set();

					nShadow = new FlxText(0, 0, 0, cText, 32);
					nShadow.x = notice.x + 4;
					nShadow.y = notice.y + 4;
					nShadow.scrollFactor.set();

					nShadow.alpha = notice.alpha;
					nShadow.color = 0x00000000;

					notice.alpha = 0;

					add(nShadow);
					add(notice);
				}
				else
				{
					if (ctrTime < 300)
					{
						if (notice.alpha < 1)
						{
							notice.alpha += 0.02;
						}
					}
					else
					{
						notice.alpha -= 0.02;
					}
				}
				nShadow.alpha = notice.alpha;

				ctrTime ++;
				cbt.reset(0.004 / (FlxG.elapsed / (1/60)));
			});
		}

		/*if (SONG.song.toLowerCase() == "final-destination")
		{
			new FlxTimer().start(0.002, function(cbt:FlxTimer)
			{
				if (ctrTime == 0)
				{
					var cText:Array<String> = ['A', 'S', 'D', 'F', 'S\nP\nA\nC\nE', 'H', 'J', 'K', 'L'];

					if (FlxG.save.data.dfjk == 2)
					{
						cText = ['A', 'S', 'D', 'F', 'S\nP\nA\nC\nE', '1', '2', '3', 'R\nE\nT\nU\nR\nN'];
					}
					var nJx = 70;
					for (i in 0...9)
					{
						noticeB[i] = new FlxText(0, 0, 0, cText[i], 24);
						noticeB[i].x = FlxG.width * 0.5 + nJx*i + 55;
						noticeB[i].y = 20;
						if (FlxG.save.data.downscroll)
						{
							noticeB[i].y = FlxG.height - 200;
							switch (i)
							{
								case 4:
									noticeB[i].y -= 140;
								case 8:
									if (FlxG.save.data.dfjk == 2)
									noticeB[i].y -= 150;
							}
						}
						else
						{
							noticeB[i].y += 70;
						}
						noticeB[i].scrollFactor.set();
						//notice[i].alpha = 0;
						noticeB[i].x -= 0;
						

						nShadowB[i] = new FlxText(0, 0, 0, cText[i], 24);
						nShadowB[i].x = noticeB[i].x + 4;
						nShadowB[i].y = noticeB[i].y + 4;
						nShadowB[i].scrollFactor.set();

						nShadowB[i].alpha = noticeB[i].alpha;
						nShadowB[i].color = 0x00000000;

						//notice.alpha = 0;

						add(nShadowB[i]);
						add(noticeB[i]);
					}

					
				}
				else
				{
					for (i in 0...9)
					{
						if (ctrTime < 600)
						{
							if (noticeB[i].alpha < 1)
							{
								noticeB[i].alpha += 0.02;
							}
						}
						else
						{
							noticeB[i].alpha -= 0.02;
						}
					}
				}
				for (i in 0...9)
				{
					nShadowB[i].alpha = noticeB[i].alpha;
				}
				ctrTime ++;
				cbt.reset(0.004);
			});
		}*/

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			if (exDad) dad2.dance();
			boyfriend.playAnim('idle');

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready'));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("set"));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("go"));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection> = songData.notes;

		//some 5note changes
		var mn:Int = keyAmmo[mania]; //new var to determine max notes
		var offset = FlxG.save.data.offset;
		var halfScreenW = FlxG.width / 2;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % (mn * 2) >= mn)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[unspawnNotes.length - 1];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.dType = section.dType;

				var susLength:Float = Math.max(swagNote.sustainLength, 0);

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[unspawnNotes.length - 1];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += halfScreenW; // general offset
					}
					else
					{
						sustainNote.strumTime -= offset;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += halfScreenW; // general offset
				}
				else
				{
					swagNote.strumTime -= offset;
				}
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	static function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var hudArrows:Array<FlxSprite>;
	var hudArrXPos:Array<Float>;
	var hudArrYPos:Array<Float>;
	private function generateStaticArrows(player:Int):Void
	{
		if (player == 1)
		{
			hudArrXPos = [];
			hudArrYPos = [];
		}
		for (i in 0...keyAmmo[mania])
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			hudArrows.push(babyArrow);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

			var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			var pPre:Array<String> = ['left', 'down', 'up', 'right'];
			switch (mania)
			{
				case 1:
					nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
					pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
				case 2:
					nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
					babyArrow.x -= Note.tooMuch;
			}
			babyArrow.x += Note.swagWidth * i;
			babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
			babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
			babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (player == 1)
			{
				hudArrXPos.push(babyArrow.x);
				hudArrYPos.push(babyArrow.y);
				playerStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	var oldSection:Int = -1;
	var fixedMustHit = false;
	var sShake:Float = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		if(SONG.player2 == "velmagod") {
			dad.y = defaultYDad + 100 * Math.sin(Conductor.songPosition / 1000);
		}

		super.update(elapsed);
		playerStrums.forEach(function(spr:FlxSprite)
		{
			spr.x = hudArrXPos[spr.ID];//spr.offset.set(spr.frameWidth / 2, spr.frameHeight / 2);
			spr.y = hudArrYPos[spr.ID];
			if (spr.animation.curAnim.name == 'confirm')
			{
				var jj:Array<Float> = [0, 3, 9];
				spr.x = hudArrXPos[spr.ID] + jj[mania];
				spr.y = hudArrYPos[spr.ID] + jj[mania];
			}
		});

		if (FlxG.save.data.accuracyDisplay)
		{
			scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% " + (fc ? "| FC" : misses == 0 ? "| A" : accuracy <= 75 ? "| BAD" : "");
		}
		else
		{
			scoreTxt.text = "Score:" + songScore; // + ' Section ${Std.int(curStep / 16)}';
		}

		var pauseBtt:Bool = FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end;
		if (Main.woops)
		{
			pauseBtt = FlxG.keys.justPressed.ESCAPE;
		}
		if (pauseBtt && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			Main.editor = true;
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		if (FlxG.keys.justPressed.ZERO)
			FlxG.switchState(new AnimationDebug(SONG.player1, true));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else if (!songEnded)
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		//if(FlxG.keys.justPressed.SHIFT) {
		//	trace('Section ${Std.int(curStep / 16)}');
		//	fixedMustHit = !fixedMustHit;
		//}

		if (generatedMusic && !songEnded)
		{
			var secNum = Std.int(curStep / 16);

			var sn = SONG.song.toLowerCase();
			if(oldSection != secNum) {
				oldSection = secNum;
				var cameraSwitch:Array<Int> = [];
				if(sn == "velma-style-whats-new") {
					cameraSwitch = [9,17,22,25,27,29,31,32,33,36,37,40,42,44,46,47,48,49,51,53,55,56,57,63,65,67,68,69];
				}
				else if(sn == "terror-time") {
					cameraSwitch = [1,2,4,6,16,24,26,28,40,49,52,55,59,65,71,76,84,92,96,100,103,108,116,124,126,128];
				}
				else if(sn == "jinkies") {
					cameraSwitch = [8,14,20,24,28,32,36,40,44,48,56,64,72,80,84,88,92,96,100,104,108,112,116,120,124,128,136,144,148,152,156,160,162,168];
				}
				else if(sn == "surface") {
					cameraSwitch = [2,4,6,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124,128,132,136,140,144,148,152,156,160,162,164,166,167];
				}
				else if(sn == "the-end") {
					cameraSwitch = [9,18,22,25,33,42,46,49,55,64];
				}

				if(cameraSwitch.contains(secNum)) {
					fixedMustHit = !fixedMustHit;
				}
			}

			var mustHit = false;
			if(sn == "velmas-spam-challenge") {
				mustHit = secNum % 8 >= 4;
			} else {
				mustHit = fixedMustHit;//PlayState.SONG.notes[secNum].mustHitSection;
			}

			if (camFollow.x != curDad.getMidpoint().x + 150 && !mustHit)
			{
				camFollow.setPosition(curDad.getMidpoint().x + 150, curDad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (curDad.curCharacter)
				{
					case 'dad':
						camFollow.y = curDad.getMidpoint().y - 100;
						camFollow.x = curDad.getMidpoint().x - 100;
					case 'shagremaster':
						camFollow.y = curDad.getMidpoint().y - 100;
						camFollow.x = curDad.getMidpoint().x - 100;
					case 'matt':
						if (exDad)
						{
							camFollow.y = curDad.getMidpoint().y - 200;
							camFollow.x = curDad.getMidpoint().x + 300;
						}
					case 'pshaggy':
						camFollow.y = curDad.getMidpoint().y + 0;
						camFollow.x = curDad.getMidpoint().x + 100;
				}
			}

			if (mustHit && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'stage_2':
						//camFollow.y = boyfriend.getMidpoint().y - 20;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (loadRep) // rep debug
		{
			FlxG.watch.addQuick('rep rpesses',repPresses);
			FlxG.watch.addQuick('rep releases',repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						camZooming = true;
	
						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}

						if (mania == 0)
						{
							switch (Math.abs(daNote.noteData))
							{
								case 2:
									curDad.playAnim('singUP' + altAnim, true);
									if(SONG.player2 == 'dad')
									{
										health -= 0.01;
									}
								case 3:
									curDad.playAnim('singRIGHT' + altAnim, true);
									if(SONG.player2 == 'dad')
									{
										health -= 0.01;
									}
								case 1:
									curDad.playAnim('singDOWN' + altAnim, true);
									if(SONG.player2 == 'dad')
									{
										health -= 0.01;
									}
								case 0:
									curDad.playAnim('singLEFT' + altAnim, true);
									if(SONG.player2 == 'dad')
									{
										health -= 0.01;
									}
							}
						}
						else if (mania == 1)
						{
							switch (Math.abs(daNote.noteData))
							{
								case 1:
									curDad.playAnim('singUP' + altAnim, true);
								case 0:
									curDad.playAnim('singLEFT' + altAnim, true);
								case 2:
									curDad.playAnim('singRIGHT' + altAnim, true);
								case 3:
									curDad.playAnim('singLEFT' + altAnim, true);
								case 4:
									curDad.playAnim('singDOWN' + altAnim, true);
								case 5:
									curDad.playAnim('singRIGHT' + altAnim, true);
							}
						}
						else
						{
							if (!exDad)
							{
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										curDad.playAnim('singLEFT' + altAnim, true);
									case 1:
										curDad.playAnim('singDOWN' + altAnim, true);
									case 2:
										curDad.playAnim('singUP' + altAnim, true);
									case 3:
										curDad.playAnim('singRIGHT' + altAnim, true);
									case 4:
										curDad.playAnim('singUP' + altAnim, true);
									case 5:
										curDad.playAnim('singLEFT' + altAnim, true);
									case 6:
										curDad.playAnim('singDOWN' + altAnim, true);
									case 7:
										curDad.playAnim('singUP' + altAnim, true);
									case 8:
										curDad.playAnim('singRIGHT' + altAnim, true);
								}
							}
							else
							{
								var targ:Character = curDad;
								var both:Bool = false;
								if (daNote.dType == 0) targ = dad2;
								else if (daNote.dType == 2)
								{
									if (daNote.noteData <= 3) targ = dad2;
									if (daNote.noteData == 4) both = true;
								}

								switch (Math.abs(daNote.noteData))
								{
									case 0:
										targ.playAnim('singLEFT' + altAnim, true);
									case 1:
										targ.playAnim('singDOWN' + altAnim, true);
									case 2:
										targ.playAnim('singUP' + altAnim, true);
									case 3:
										targ.playAnim('singRIGHT' + altAnim, true);
									case 4:
										targ.playAnim('singUP' + altAnim, true);

										if (both) dad2.playAnim('singUP' + altAnim, true);
									case 5:
										targ.playAnim('singLEFT' + altAnim, true);
									case 6:
										targ.playAnim('singDOWN' + altAnim, true);
									case 7:
										targ.playAnim('singUP' + altAnim, true);
									case 8:
										targ.playAnim('singRIGHT' + altAnim, true);
								}
							}
						}
	
						curDad.holdTimer = 0;
						if (exDad) dad2.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
	
					if (FlxG.save.data.downscroll)
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
					else
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
					{
						//now with different conditions depending on the note type
						switch (daNote.noteType)
						{
							case 0: //normal
								if (daNote.isSustainNote && daNote.wasGoodHit)
								{
									daNote.kill();
									notes.remove(daNote, true);
									daNote.destroy();
								}
								else
								{
									if (daNote.mustPress)
									{
										health -= 0.075;
										vocals.volume = 0;
										if (theFunne)
											noteMiss(daNote.noteData);
									}
								}
			
								daNote.active = false;
								daNote.visible = false;
			
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							case 1: //kill note
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							case 2: //live note
								dSound = 2;
								health = 0;
						}
					}
				});
			}
		
		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		songEnded = true;
		/*if (!loadRep)
			rep.SaveReplay();*/

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			new FlxTimer().start(0.003, function(fadear:FlxTimer)
			{
				var decAl:Float = 0.01;
				for (i in 0...hudArrows.length)
				{
					hudArrows[i].alpha -= decAl;
				}
				healthBarBG.alpha -= decAl;
				healthBar.alpha -= decAl;
				iconP1.alpha -= decAl;
				iconP2.alpha -= decAl;
				scoreTxt.alpha -= decAl;
				fadear.reset(0.003);
			});

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				if(SONG.song == "the-end") {
					FlxG.switchState(new EndImageState());
				} else {
					FlxG.switchState(new MainMenuState());
				}

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					#if newgrounds
					NGio.unlockMedal(60961);
					#end
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				Main.skipDes = false;
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var sjy = 0;
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y += sjy;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
			
		if (noteDiff > Conductor.safeZoneOffset * 2)
			{
				daRating = 'shit';
				totalNotesHit -= 2;
				ss = false;
				if (theFunne)
					{
						score = -3000;
						combo = 0;
						misses++;
						health -= 0.2;
					}
				shits++;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -2)
			{
				daRating = 'shit';
				totalNotesHit -= 2;
				if (theFunne)
				{
					score = -3000;
					combo = 0;
					misses++;
					health -= 0.2;
				}
				ss = false;
				shits++;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.45)
			{
				daRating = 'bad';
				totalNotesHit += 0.2;
				if (theFunne)
				{
					score = -1000;
					health -= 0.03;
				}
				else
					score = 100;
				ss = false;
				bads++;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.45)
			{
				daRating = 'bad';
				totalNotesHit += 0.2;
				if (theFunne)
					{
						score = -1000;
						health -= 0.03;
					}
					else
						score = 100;
				ss = false;
				bads++;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -0.25)
			{
				daRating = 'good';
				totalNotesHit += 0.65;
				if (theFunne)
				{
					score = 200;
					//health -= 0.01;
				}
				else
					score = 200;
				ss = false;
				goods++;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.25)
			{
				daRating = 'good';
				totalNotesHit += 0.65;
				if (theFunne)
					{
						score = 200;
						//health -= 0.01;
					}
					else
						score = 200;
				ss = false;
				goods++;
			}
		if (daRating == 'sick')
		{
			totalNotesHit += 1;
			if (health < 2)
				health += 0.1;
			sicks++;
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += score;

			rating.loadGraphic(Paths.image(daRating));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.y += sjy;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.y += sjy;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			add(rating);

			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;

			comboSpr.updateHitbox();
			rating.updateHitbox();

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;

				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (combo >= 10 || combo == 0)
					add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();

					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}
	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	var l1Hold:Bool = false;
	var uHold:Bool = false;
	var r1Hold:Bool = false;
	var l2Hold:Bool = false;
	var dHold:Bool = false;
	var r2Hold:Bool = false;

	var n0Hold:Bool = false;
	var n1Hold:Bool = false;
	var n2Hold:Bool = false;
	var n3Hold:Bool = false;
	var n4Hold:Bool = false;
	var n5Hold:Bool = false;
	var n6Hold:Bool = false;
	var n7Hold:Bool = false;
	var n8Hold:Bool = false;

	private function keyShit():Void
	{
		// HOLDING
		/*var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;*/

		// ---------- default ------------
		var upP = _hitbox.buttonUp.justPressed;
		var rightP = _hitbox.buttonRight.justPressed;
		var downP = _hitbox.buttonDown.justPressed;
		var leftP = _hitbox.buttonLeft.justPressed;

		var up = _hitbox.buttonUp.pressed;
		var right = _hitbox.buttonRight.pressed;
		var down = _hitbox.buttonDown.pressed;
		var left = _hitbox.buttonLeft.pressed;

		var upR = _hitbox.buttonUp.justReleased;
		var rightR = _hitbox.buttonRight.justReleased;
		var downR = _hitbox.buttonDown.justReleased;
		var leftR = _hitbox.buttonLeft.justReleased;

		// --------- six control --------
		var l1 = controls.L1 || _hitbox.buttonLeft.pressed; // 3
		var u = controls.U1 || _hitbox.buttonDown.pressed; // 2
		var r1 = controls.R1 || _hitbox.buttonUp.pressed; // 1
		var l2 = controls.L2 || _hitbox.buttonRight.pressed; // 4
		var d = controls.D1 || _hitbox.buttonUp2.pressed; // 5
		var r2 = controls.R2 || _hitbox.buttonRight2.pressed; // 6

		var l1P = controls.L1_P || _hitbox.buttonLeft.justPressed;
		var uP = controls.U1_P || _hitbox.buttonDown.justPressed;
		var r1P = controls.R1_P || _hitbox.buttonUp.justPressed;
		var l2P = controls.L2_P || _hitbox.buttonRight.justPressed;
		var dP = controls.D1_P || _hitbox.buttonUp2.justPressed;
		var r2P = controls.R2_P || _hitbox.buttonRight2.justPressed;

		var l1R = controls.L1_R || _hitbox.buttonLeft.justReleased;
		var uR = controls.U1_R || _hitbox.buttonDown.justReleased;
		var r1R = controls.R1_R || _hitbox.buttonUp.justReleased;
		var l2R = controls.L2_R || _hitbox.buttonRight.justReleased;
		var dR = controls.D1_R || _hitbox.buttonUp2.justReleased;
		var r2R = controls.R2_R || _hitbox.buttonRight2.justReleased;

		// ------- nine control ---------
		var n0 = controls.N0 || _hitbox.buttonLeft.pressed;
		var n1 = controls.N1 || _hitbox.buttonDown.pressed;
		var n2 = controls.N2 || _hitbox.buttonUp.pressed;
		var n3 = controls.N3 || _hitbox.buttonRight.pressed;
		var n4 = controls.N4 || _hitbox.buttonUp2.pressed;
		var n5 = controls.N5 || _hitbox.buttonRight2.pressed;
		var n6 = controls.N6 || _hitbox.buttonLeft2.pressed;
		var n7 = controls.N7 || _hitbox.buttonDown2.pressed;
		var n8 = controls.N8 || _hitbox.buttonLeft3.pressed;

		var n0P = controls.N0_P || _hitbox.buttonLeft.justPressed;
		var n1P = controls.N1_P || _hitbox.buttonDown.justPressed;
		var n2P = controls.N2_P || _hitbox.buttonUp.justPressed;
		var n3P = controls.N3_P || _hitbox.buttonRight.justPressed;
		var n4P = controls.N4_P || _hitbox.buttonUp2.justPressed;
		var n5P = controls.N5_P || _hitbox.buttonRight2.justPressed;
		var n6P = controls.N6_P || _hitbox.buttonLeft2.justPressed;
		var n7P = controls.N7_P || _hitbox.buttonDown2.justPressed;
		var n8P = controls.N8_P || _hitbox.buttonLeft3.justPressed;

		var n0R = controls.N0_R || _hitbox.buttonLeft.justReleased;
		var n1R = controls.N1_R || _hitbox.buttonDown.justReleased;
		var n2R = controls.N2_R || _hitbox.buttonUp.justReleased;
		var n3R = controls.N3_R || _hitbox.buttonRight.justReleased;
		var n4R = controls.N4_R || _hitbox.buttonUp2.justReleased;
		var n5R = controls.N5_R || _hitbox.buttonRight2.justReleased;
		var n6R = controls.N6_R || _hitbox.buttonLeft2.justReleased;
		var n7R = controls.N7_R || _hitbox.buttonDown2.justReleased;
		var n8R = controls.N8_R || _hitbox.buttonLeft3.justReleased;

		if (loadRep) // replay code
		{
			// disable input
			up = false;
			down = false;
			right = false;
			left = false;

			// new input


			//if (rep.replay.keys[repPresses].time == Conductor.songPosition)
			//	trace('DO IT!!!!!');

			//timeCurrently = Math.abs(rep.replay.keyPresses[repPresses].time - Conductor.songPosition);
			//timeCurrentlyR = Math.abs(rep.replay.keyReleases[repReleases].time - Conductor.songPosition);

			
			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition) && rep.replay.keyPresses[repPresses].key == "up";
				rightP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition) && rep.replay.keyPresses[repPresses].key == "right";
				downP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition) && rep.replay.keyPresses[repPresses].key == "down";
				leftP = NearlyEquals(rep.replay.keyPresses[repPresses].time, Conductor.songPosition)  && rep.replay.keyPresses[repPresses].key == "left";	

				upR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "up";
				rightR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "right";
				downR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "down";
				leftR = NearlyEquals(rep.replay.keyReleases[repReleases].time, Conductor.songPosition) && rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else if (!loadRep) // record replay code
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		var ankey = (upP || rightP || downP || leftP);
		if (mania == 1)
		{ 
			ankey = (l1P || uP || r1P || l2P || dP || r2P);
			controlArray = [l1P, uP, r1P, l2P, dP, r2P];
		}
		else if (mania == 2)
		{
			ankey = (n0P || n1P || n2P || n3P || n4P || n5P || n6P || n7P || n8P);
			controlArray = [n0P, n1P, n2P, n3P, n4P, n5P, n6P, n7P, n8P];
		}
		if (ankey && !boyfriend.stunned && generatedMusic)
			{
				repPresses++;
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				});
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{
								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
									if (!inIgnoreList && !theFunne && startedCountdown && !cs_reset && !grace)
										badNoteCheck();
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (loadRep)
							{
								if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
								{
									goodNoteHit(daNote);
									trace('force note hit');
								}
								else
									noteCheck(controlArray, daNote);
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (loadRep)
									{
										if (NearlyEquals(coolNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
										{
											goodNoteHit(coolNote);
											trace('force note hit');
										}
										else
											noteCheck(controlArray, daNote);
									}
								else
									noteCheck(controlArray, coolNote);
							}
						}
					}
					else // regular notes?
					{	
						if (loadRep)
						{
							if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
							{
								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
							noteCheck(controlArray, daNote);
					}
					/* 
						if (controlArray[daNote.noteData])
							goodNoteHit(daNote);
					 */
					// trace(daNote.noteData);
					/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}
					 */
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
				else if (!theFunne && startedCountdown && !cs_reset && !grace)
				{
					badNoteCheck();
				}
			}
			
			var condition = ((up || right || down || left) && generatedMusic || (upHold || downHold || leftHold || rightHold) && loadRep && generatedMusic);
			if (mania == 1)
			{
				condition = ((l1 || u || r1 || l2 || d || r2) && generatedMusic || (l1Hold || uHold || r1Hold || l2Hold || dHold || r2Hold) && loadRep && generatedMusic);
			}
			else if (mania == 2)
			{
				condition = ((n0 || n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8) && generatedMusic || (n0Hold || n1Hold || n2Hold || n3Hold || n4Hold || n5Hold || n6Hold || n7Hold || n8Hold) && loadRep && generatedMusic);
			}
			if (condition)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						if (mania == 0)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 2:
									if (up || upHold)
										goodNoteHit(daNote);
								case 3:
									if (right || rightHold)
										goodNoteHit(daNote);
								case 1:
									if (down || downHold)
										goodNoteHit(daNote);
								case 0:
									if (left || leftHold)
										goodNoteHit(daNote);
							}
						}
						else if (mania == 1)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0:
									if (l1 || l1Hold)
										goodNoteHit(daNote);
								case 1:
									if (u || uHold)
										goodNoteHit(daNote);
								case 2:
									if (r1 || r1Hold)
										goodNoteHit(daNote);
								case 3:
									if (l2 || l2Hold)
										goodNoteHit(daNote);
								case 4:
									if (d || dHold)
										goodNoteHit(daNote);
								case 5:
									if (r2 || r2Hold)
										goodNoteHit(daNote);
							}
						}
						else
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 0: if (n0 || n0Hold) goodNoteHit(daNote);
								case 1: if (n1 || n1Hold) goodNoteHit(daNote);
								case 2: if (n2 || n2Hold) goodNoteHit(daNote);
								case 3: if (n3 || n3Hold) goodNoteHit(daNote);
								case 4: if (n4 || n4Hold) goodNoteHit(daNote);
								case 5: if (n5 || n5Hold) goodNoteHit(daNote);
								case 6: if (n6 || n6Hold) goodNoteHit(daNote);
								case 7: if (n7 || n7Hold) goodNoteHit(daNote);
								case 8: if (n8 || n8Hold) goodNoteHit(daNote);
							}
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (mania == 0)
				{
					switch (spr.ID)
					{
						case 2:
							if (upP && spr.animation.curAnim.name != 'confirm')
							{
								spr.animation.play('pressed');
							}
							if (upR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 3:
							if (rightP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (rightR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 1:
							if (downP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (downR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 0:
							if (leftP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (leftR)
							{
								spr.animation.play('static');
								repReleases++;
							}
					}
				}
				else if (mania == 1)
				{
					switch (spr.ID)
					{
						case 0:
							if (l1P && spr.animation.curAnim.name != 'confirm')
							{
								spr.animation.play('pressed');
							}
							if (l1R)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 1:
							if (uP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (uR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 2:
							if (r1P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (r1R)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 3:
							if (l2P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (l2R)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 4:
							if (dP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (dR)
							{
								spr.animation.play('static');
								repReleases++;
							}
						case 5:
							if (r2P && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (r2R)
							{
								spr.animation.play('static');
								repReleases++;
							}
					}
				}
				else if (mania == 2)
				{
					switch (spr.ID)
					{
						case 0:
							if (n0P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n0R) spr.animation.play('static');
						case 1:
							if (n1P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n1R) spr.animation.play('static');
						case 2:
							if (n2P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n2R) spr.animation.play('static');
						case 3:
							if (n3P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n3R) spr.animation.play('static');
						case 4:
							if (n4P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n4R) spr.animation.play('static');
						case 5:
							if (n5P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n5R) spr.animation.play('static');
						case 6:
							if (n6P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n6R) spr.animation.play('static');
						case 7:
							if (n7P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n7R) spr.animation.play('static');
						case 8:
							if (n8P && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
							if (n8R) spr.animation.play('static');
					}
				}

				spr.centerOffsets();
				
				if (spr.animation.curAnim.name == 'confirm')
				{
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
			});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			combo = 0;
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if(SONG.player1 != "velma") {
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 4:
						boyfriend.playAnim('singDOWNmiss', true);
					case 5:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 6:
						boyfriend.playAnim('singDOWNmiss', true);
					case 7:
						boyfriend.playAnim('singUPmiss', true);
					case 8:
						boyfriend.playAnim('singRIGHTmiss', true);
				}
			}

			updateAccuracy();
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		/*var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;*/
		var upP = _hitbox.buttonUp.justPressed;
		var rightP = _hitbox.buttonRight.justPressed;
		var downP = _hitbox.buttonDown.justPressed;
		var leftP = _hitbox.buttonLeft.justPressed;

		/*var l1P = controls.L1_P;
		var uP = controls.U1_P;
		var r1P = controls.R1_P;
		var l2P = controls.L2_P;
		var dP = controls.D1_P;
		var r2P = controls.R2_P;*/

		var l1P = controls.L1_P || _hitbox.buttonLeft.justPressed;
		var uP = controls.U1_P || _hitbox.buttonDown.justPressed;
		var r1P = controls.R1_P || _hitbox.buttonUp.justPressed;
		var l2P = controls.L2_P || _hitbox.buttonRight.justPressed;
		var dP = controls.D1_P || _hitbox.buttonUp2.justPressed;
		var r2P = controls.R2_P || _hitbox.buttonRight2.justPressed;

		var n0P = controls.N0_P || _hitbox.buttonLeft.justPressed;
		var n1P = controls.N1_P || _hitbox.buttonDown.justPressed;
		var n2P = controls.N2_P || _hitbox.buttonUp.justPressed;
		var n3P = controls.N3_P || _hitbox.buttonRight.justPressed;
		var n4P = controls.N4_P || _hitbox.buttonUp2.justPressed;
		var n5P = controls.N5_P || _hitbox.buttonRight2.justPressed;
		var n6P = controls.N6_P || _hitbox.buttonLeft2.justPressed;
		var n7P = controls.N7_P || _hitbox.buttonDown2.justPressed;
		var n8P = controls.N8_P || _hitbox.buttonLeft3.justPressed;
		
		if (mania == 0)
		{
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
		}
		else if (mania == 1)
		{
			if (l1P)
				noteMiss(0);
			else if (uP)
				noteMiss(1);
			else if (r1P)
				noteMiss(2);
			else if (l2P)
				noteMiss(3);
			else if (dP)
				noteMiss(4);
			else if (r2P)
				noteMiss(5);
		}
		else
		{
			if (n0P) noteMiss(0);
			if (n1P) noteMiss(1);
			if (n2P) noteMiss(2);
			if (n3P) noteMiss(3);
			if (n4P) noteMiss(4);
			if (n5P) noteMiss(5);
			if (n6P) noteMiss(6);
			if (n7P) noteMiss(7);
			if (n8P) noteMiss(8);
		}
		updateAccuracy();
	}

	function updateAccuracy()
	{
		if (misses > 0 || accuracy < 96)
			fc = false;
		else
			fc = true;
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var grace:Bool = false;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		if (loadRep)
		{
			if (controlArray[note.noteData])
				goodNoteHit(note);
			else if (!theFunne && startedCountdown && !cs_reset) 
				badNoteCheck();
			else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
			{
				if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
				{
					goodNoteHit(note);
				}
				else if (!theFunne && startedCountdown && !cs_reset) 
					badNoteCheck();
			}
		}
		else if (controlArray[note.noteData])
		{
			for (b in controlArray) {
				if (b)
					mashing++;
			}

			if (true)
				goodNoteHit(note);
			else
			{
				playerStrums.members[note.noteData].animation.play('static');
				trace('mash ' + mashing);
			}
		}
		else if (!theFunne && startedCountdown && !cs_reset && !grace)
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (mashing != 0)
			mashing = 0;
		if (!note.wasGoodHit)
		{
			switch (note.noteType)
			{
				case 0 | 2: //normal and live notes
					if (!note.isSustainNote)
					{
						popUpScore(note.strumTime);
						combo += 1;
					}
					else
						totalNotesHit += 1;
	
					var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					if (mania == 1)
					{
						sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
					}
					else if (mania == 2)
					{
						sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
					}

					boyfriend.playAnim('sing' + sDir[note.noteData], true);
		
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
						//spr.updateHitbox();
					});
		
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();

					grace = true;
					new FlxTimer().start(0.15, function(tmr:FlxTimer)
					{
						grace = false;
					});
				case 1: //kill note
					if (NearlyEquals(note.strumTime, Conductor.songPosition, 30))
					{
						dSound = 1;
						health = 0;
					}
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(isEnd) {
			if(curStep == 314) { // if(curStep == 85) {
				burstRelease(dad.getMidpoint().x, dad.getMidpoint().y);
				dad.active = false;
				dad.visible = false;
				iconP2.animation.play("shagremaster");
				dadRemastered.active = true;
				dadRemastered.visible = true;
				curDad = dadRemastered;
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes

			if (curDad.animation.curAnim.name.startsWith("idle") || SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				curDad.dance();
			if (exDad)
			{
				dad2.dance();
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.animation.curAnim.name.startsWith("scared"))
		{
			boyfriend.playAnim('idle');
		}
	}

	var scoob:Character;
	var cs_time:Int = 0;
	var cs_wait:Bool = false;
	var cs_zoom:Float = 1;
	//var cs_sfx:FlxSound;
	var cs_mus:FlxSound;
	var cs_cam:FlxObject;
	//var cs_black:FlxSprite;

	public function endingDialogue()
	{
		cs_cam = new FlxObject(0, 0, 1, 1);
		cs_cam.x = 605;
		cs_cam.y = 410;
		add(cs_cam);
		remove(camFollow);
		camFollow.destroy();
		FlxG.camera.follow(cs_cam, LOCKON, 0.01);

		new FlxTimer().start(0.002, function(tmr:FlxTimer)
		{
			switch (cs_time)
			{
				case 1:
					cs_zoom = 0.65;
				case 3:
					if (!cs_wait)
					{
						csDial('ending_dialogue');
						schoolIntro(0);
						cs_wait = true;
						cs_reset = true;

						cs_mus.stop();
						cs_mus = FlxG.sound.load(Paths.sound('cs_drums'));
						cs_mus.play();
						cs_mus.looped = true;
					}
				case 10:
					//cs_black.alpha = 2;
					cs_mus.stop();
				case 110:
					endSong();
			}

			FlxG.camera.zoom += (cs_zoom - FlxG.camera.zoom) / 12;
			FlxG.camera.angle += (0 - FlxG.camera.angle) / 12;
			if (!cs_wait)
			{
				cs_time ++;
			}
			tmr.reset(0.002);
		});
	}
	
	public function burstRelease(bX:Float, bY:Float)
	{
		FlxG.sound.play(Paths.sound('burst'));
		remove(burst);
		burst = new FlxSprite(bX - 1000, bY - 100);
		burst.frames = Paths.getSparrowAtlas('shaggy');
		burst.animation.addByPrefix('burst', "burst", 30);
		burst.animation.play('burst');
		//burst.setGraphicSize(Std.int(burst.width * 1.5));
		burst.antialiasing = true;
		add(burst);
		new FlxTimer().start(0.5, function(rem:FlxTimer)
		{
			remove(burst);
		});
	}
	//var sh_kill_line:String = "Oh and next time you cut scooby in half I'm\nnot gonna pretend like singing is\nmy only option again.";
	public function csDial(csIndex:String)
	{
		switch (csIndex)
		{
			case 'end':
				dialogue = [
					"Man...",
					"Stop like, thinking about it.",
					"We just have to accept it.",
					"Yeah but",
					"What would've happened if he\ngave up?",
					"What?",
					"Like, if he dies and decides to not\nrevert time...",
					"What would happen to us?",
					"...",
					"..."
				];
				dface = [
						"f_matt",
						"f_sh", "f_sh",
						"f_matt", "f_matt_down",
						"f_sh_smug",
						"f_matt_down", "f_matt_ang",
						"f_sh", "f_sh_kill"
						];
				dside = [1, -1, -1, 1, 1, -1, 1, 1, -1, -1];
			/*case 'scooby_hold_talk':
				dialogue = [
					"Like, what's wrong scoob?",
					"The monster shraggy...",
					"She's mean!",
					"She scares me...",
					"What are you talking about?\nThis lady?",
					"She's like, totally cool man!",
					"Why are you saying that"
				];
				dface = [
						"f_sh_ser",
						"f_scb_scared", "n", "n",
						"f_sh_con", "f_sh_smug", "f_sh"
						];
				dside = [1, 1, 1, 1, 1, 1, 1];
			case 'gf_sass':
				dialogue = [
					"BEP?!",
					"Will that get you to sing for real\nthis time?"
				];
				dface = [
						"f_bf_scared",
						"f_gf"
						];
				dside = [-1, -1];
			case 'sh_amazing':
				dialogue = [
					"...",
					"Amazing!"
				];
				dface = [
						"f_sh_smug",
						"f_sh_smug"
						];
				dside = [1, 1];
			case 'sh_expo':
				dialogue = [
					"I scared you didn't I?",
					"bee",
					"I don't even need a finger snap to like,\nbring every dead being in this planet\nback to life",
					"Wouldn't have killed your dog if\nI didn't know that",
					"...",
					"Anyways, to tell you the truth Scooby\nwas looking for you.",
					"We came to your universe because we\nheard a teenager was like, immortal",
					"And you beat me first try!",
					"From my perspective at least...",
					"I'm guessing you have some time resetting\nability so I'm glad I didn't go\nfull power against you.",
					"baap be?",
					"0.002%",
					"a",
					"Welp, we gotta go and stuff."
				];
				dface = [
						"f_sh_smug",
						"f_bf_a",
						"f_sh",
						"f_gf",
						"f_sh_ser", "f_sh", "n", "f_sh_smug", "f_sh_con", "n",
						"f_bf",
						"f_sh",
						"f_bf_a",
						"f_sh"
						];
				dside = [1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, 1, -1, 1];
			case "sh_bye":
				dialogue = [
					"I heard they're gathering up some powerful\nindividuals for a tournament in\na universe close by...",
					"And if saitama's gonna be there, I can't\nmiss it.",
					"So like, goodbye! For now at least.",
					sh_kill_line
				];
				dface = [
						"f_sh",
						"f_sh_smug",
						"f_sh",
						"f_sh_kill"
				];
				dside = [1, 1, 1, 1];
			case "troleo":
				dialogue = [
					"Chupenme la corneta giles culiaooos!!!!",
					"You speak everything but english huh"
				];
				dface = [
						"f_bf_burn",
						"f_gf"
				];
				dside = [-1, -1];*/
		}
	}
}
