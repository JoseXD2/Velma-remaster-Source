package;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class EndImageState extends MusicBeatState
{
	override public function create():Void
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		var endImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image("endImage"));
		endImage.antialiasing = true;
		endImage.setGraphicSize(1280);
		endImage.updateHitbox();
		endImage.screenCenter();
		endImage.alpha = 0;
		add(endImage);

		FlxTween.tween(endImage, {alpha:1}, 2, {onComplete: function(_) {
			new FlxTimer().start(20.0, function(tmr:FlxTimer) {
				FlxTween.tween(endImage, {alpha:0}, 3);

				new FlxTimer().start(4, function(tmr:FlxTimer) {
					FlxG.switchState(new MainMenuState());
				});
			});
		}});
	}
}
