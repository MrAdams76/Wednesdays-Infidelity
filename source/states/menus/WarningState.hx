package states.menus;

import data.ClientPrefs;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Alphabet;
import gameObjects.AttachedText;
import gameObjects.CheckboxThingie;
import gameObjects.Option;
import openfl.Lib;
import util.CoolUtil;

class WarningState extends MusicBeatState
{
	private var canMove:Bool = false;

	private var canPressSpace:Bool = false;

	private var warnText:FlxText;
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;

	private var camGame:FlxCamera;
	private var camHUD:FlxCamera;

	private var optionTitle:Alphabet;
	private var warnTitle:FlxText;
	private var infoTexts:Array<FlxText> = [];
	#if ios
	private var mobileButtons:Array<FlxText> = [];
	#end

	override function create()
	{
		super.create();

		if (ClientPrefs.doNotShowWarnings)
		{
			MusicBeatState.switchState(new TitleState());

			return;
		}

		Lib.application.window.title = "Wednesday's Infidelity - WARNING";

		camGame = new FlxCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		camFollow = new FlxPoint((FlxG.width / 2), (FlxG.height / 2));
		camFollowPos = new FlxObject((FlxG.width / 2), (FlxG.height / 2), 1, 1);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.focusOn(camFollow);

		addInfoTexts();

		FlxTween.tween(warnTitle, {y: 140}, 1, {
			ease: FlxEase.backOut,
			startDelay: 0,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.color(warnTitle, 1, FlxColor.WHITE, FlxColor.YELLOW, {type: PINGPONG});
				FlxTween.tween(warnText, {y: 460}, 1, {
					startDelay: 0.5,
					ease: FlxEase.backOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(warnTitle, {x: (FlxG.width / 3) - 160, y: 100 - 55, size: 120}, 1.5, {startDelay: 0.1, ease: FlxEase.circInOut});

						FlxTween.tween(warnText, {
							x: 560,
							y: 230 - 55,
							size: 30,
							height: 57,
							fieldWidth: 700
						}, 1.5, {
							startDelay: 0.1,
							ease: FlxEase.circInOut
						});

						new FlxTimer().start(0.7, function(tmr:FlxTimer)
						{
							tweenOptions();
						});
					}
				});
			}
		});

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		var option:Option = new Option('Do Not Show Again', "", 'doNotShowWarnings', 'bool', false);
		addOption(option);

		var option:Option = new Option('Flashing Lights', "", 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Screen Shake', "", 'shake', 'bool', true);
		addOption(option);

		var option:Option = new Option('Shaders', "", 'shaders', 'bool', true);
		addOption(option);

		var option:Option = new Option('Intensive Shaders', "Uncheck this if you don't want to run Intensive Shaders!", 'intensiveShaders', 'bool', true);
		addOption(option);

		genOptions();
		#if ios
		addMobileButtons();
		#end
	}

	#if ios
	private function addMobileButtons():Void
	{
		var labels = ['UP', 'DOWN', 'SELECT', 'CONTINUE'];
		for (i in 0...labels.length)
		{
			var bx:Float = FlxG.width * (0.03 + i * 0.245);
			var bg = new FlxSprite(bx, FlxG.height - 120).makeGraphic(Std.int(FlxG.width * 0.22), 90, FlxColor.BLACK);
			bg.alpha = 0.75;
			bg.cameras = [camHUD];
			add(bg);
			var b = new FlxText(bx, FlxG.height - 105, FlxG.width * 0.22, labels[i], 27);
			b.setFormat(null, 27, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			b.borderSize = 3;
			b.cameras = [camHUD];
			add(b);
			mobileButtons.push(b);
		}
	}
	#end

	function addOption(option:Option)
	{
		if (optionsArray == null || optionsArray.length < 1)
			optionsArray = [];
		optionsArray.push(option);
	}

	function addInfoTexts()
	{
		warnTitle = new FlxText(0, -340, FlxG.width, "WARNING", 21);
		warnTitle.setFormat("VCR OSD Mono", 200, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnTitle.cameras = [camHUD];
		add(warnTitle);

		warnText = new FlxText(0, 850, FlxG.width, "This mod contains Flashing Lights, Loud Effects, and Screen Shake.", 21);
		warnText.setFormat("VCR OSD Mono", 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.applyMarkup("This mod contains $Flashing Lights$, $Loud Effects$, and $Screen Shake$.",
			[new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "$")]);
		warnText.cameras = [camHUD];
		add(warnText);

		var text:FlxText = new FlxText(560 + 700, 400, 700, "", 21);
		text.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.applyMarkup("It is reccomended to check the full $options$ menu.", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.YELLOW), "$")]);
		text.cameras = [camHUD];
		add(text);

		infoTexts.push(text);

		var text:FlxText = new FlxText(560 + 700, 650, 700, "", 21);
		text.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.applyMarkup("Tap the bottom of the screen to continue.", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.YELLOW), "$")]);
		text.cameras = [camHUD];
		add(text);

		infoTexts.push(text);
	}

	function tweenInfoTexts()
	{
		for (text in infoTexts)
		{
			FlxTween.tween(text, {x: text.x - 700}, 1, {startDelay: 0.5 + (0.3 * infoTexts.indexOf(text)), ease: FlxEase.backOut});
		}

		new FlxTimer().start(1 + (0.5 + (0.3 * (infoTexts.length - 1))), function(tmr:FlxTimer)
		{
			canPressSpace = true;
		});
	}

	function genOptions()
	{
		optionTitle = new Alphabet(0, 0, "accessibility", true, false, 0, 0.9);
		optionTitle.isMenuItem = false;
		optionTitle.alpha = 0.5;
		optionTitle.x = 50;
		optionTitle.y = -100;
		optionTitle.cameras = [camGame];
		add(optionTitle);

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, optionsArray[i].name, true, false, 0, 0.5);
			optionText.isMenuItem = false;
			optionText.cameras = [camGame];

			optionText.y = 250 + (150 * i);
			optionText.x = 215 + (30 * i);

			optionText.x -= 700;

			grpOptions.add(optionText);

			var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue());
			checkbox.sprTracker = optionText;
			checkbox.scale.set(0.8, 0.8);
			checkbox.updateHitbox();
			checkbox.ID = i;
			checkbox.cameras = [camGame];

			@:privateAccess
			checkbox.animationFinished(checkbox.daValue ? 'checking' : 'unchecking');

			checkbox.offsetY = -65;
			checkbox.offsetX = -5;

			switch (i)
			{
				case 0:
					checkbox.offsetX += 1;
				case 1:
					checkbox.offsetX -= 3;
				case 2 | 3:
					checkbox.offsetX -= 1;
			}

			checkboxGroup.add(checkbox);
		}

		changeSelection();
		reloadCheckboxes();
	}

	function tweenOptions()
	{
		FlxTween.tween(optionTitle, {y: 90}, 0.9, {
			ease: FlxEase.circInOut,
			onComplete: function(twn:FlxTween)
			{
				tweenInfoTexts();
			}
		});

		for (option in grpOptions)
		{
			FlxTween.tween(option, {x: option.x + 700}, 0.7, {
				ease: FlxEase.backOut,
				onComplete: function(twn:FlxTween)
				{
					canMove = true;
				},
				startDelay: 0.35 * grpOptions.members.indexOf(option)
			});
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		for (item in grpOptions.members)
		{
			item.alpha = 0.5;

			if (grpOptions.members.indexOf(item) == curSelected)
				item.alpha = 0.9;
		}
		for (text in grpTexts)
		{
			text.alpha = 0.5;
			if (text.ID == curSelected)
			{
				text.alpha = 0.9;
			}
		}

		curOption = optionsArray[curSelected];

		camFollow.set((FlxG.width / 2) + (2 * curSelected), (FlxG.height / 2) + (100 * curSelected));

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes()
	{
		for (checkbox in checkboxGroup)
		{
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (camFollow != null && camFollowPos != null)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 10, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		#if ios
		if (canMove)
		{
			for (touch in FlxG.touches.list)
			{
				if (!touch.justPressed) continue;
				var point = touch.getScreenPosition(camHUD);
				if (point.y >= FlxG.height - 125)
				{
					var index = Std.int(point.x / (FlxG.width * 0.245));
					switch (index)
					{
						case 0: changeSelection(-1);
						case 1: changeSelection(1);
						case 2:
							curOption.setValue(!curOption.getValue());
							curOption.change();
							reloadCheckboxes();
						case 3 | 4:
							continueFromWarning();
						}
					return;
				}
			}
		}
		#end

		if (canMove)
		{
			if (controls.UI_UP_P)
				changeSelection(-1);

			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (FlxG.keys.justPressed.ENTER)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curOption.setValue((curOption.getValue() == true) ? false : true);
				curOption.change();
				reloadCheckboxes();
			}

			if (FlxG.keys.justPressed.SPACE && canPressSpace)
			{
				continueFromWarning();
			}
		}
	}

	private function continueFromWarning():Void
	{
		if (!canMove || !canPressSpace) return;
		canMove = false;

		#if ios
		// Diagnostic: isolate iOS warning-screen confirmation effects.
		// Avoid sound playback, flicker, and settings I/O in this test build.
		// Bypass desktop CustomFadeTransition while diagnosing iOS state crashes.
		// Diagnostic: go directly to the title, skipping UnfinishedState.
		FlxG.switchState(new TitleState());
		#else
		FlxTween.tween(camGame, {alpha: 0}, 1);
		FlxTween.tween(camHUD, {alpha: 0}, 1);

		FlxG.sound.play(Paths.sound('confirmMenu'));

		FlxFlicker.flicker(infoTexts[1]);

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			ClientPrefs.saveSettings();

			MusicBeatState.switchState(new UnfinishedState());
		});
		#end
	}
}