package options;
/**
	添加的界面
	BPE 的相关设置
    加项目：
    照葫芦画瓢就行了
    记得在ClientPref.hx里面补save,lord和定义，可以参照health drain
**/
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class BoolPESettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Boolean Psych Engine Setting';
		rpcTitle = 'Boolean Psych Engine Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('AutoPause',
			'If checked, this engine will pause when it loses focus.\nYou should restart the game to make sense.',
			'ifAutoPause',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Drain',
			'Health will lose 1% when opponent hits while stops when 4%',
			'openHealthDrain',
			'bool',
			true);
		addOption(option);

        var option:Option = new Option('Show Victory Windows',
			'The victory window after the song ends,\n Press 5 to end song if it didn\'t after the window closes.',
			'openVicWindow',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show msTiming',
			'If checked, the time difference will show when you hit notes.',
			'openMsTiming',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Combo Counter',
			'If checked, the combo counter will show when you play.',
			'openComboCounter',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Combo Counter Style',
			"The style of the combo counter",
			'comboCounterType',
			'string',
			'Num',
			['Num', 'Name:Num', 'N:Num']);
		addOption(option);

		var option:Option = new Option('Combo Counter Zoom',
			'If unchecked, the combo counter will not zoom when increase.',
			'zoomComboCounter',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Perfect gains : ',
			'How many times of health you want to gain when hitting Perfect',
			'perfectHealth',
			'float',
			1);
		option.displayFormat = '%vx';
		option.scrollSpeed = 5;
		option.minValue = -2;
		option.maxValue = 2;
		option.changeValue = 0.1;
		addOption(option);


		var option:Option = new Option('Sick gains : ',
			'How many times of health you want to gain when hitting Sick',
			'sickHealth',
			'float',
			1);
		option.displayFormat = '%vx';
		option.scrollSpeed = 5;
		option.minValue = -2;
		option.maxValue = 2;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Good gains : ',
			'How many times of health you want to gain when hitting good',
			'goodHealth',
			'float',
			1);
		option.displayFormat = '%vx';
		option.scrollSpeed = 5;
		option.minValue = -2;
		option.maxValue = 2;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Bad gains : ',
			'How many times of health you want to gain when hitting bad',
			'badHealth',
			'float',
			1);
		option.displayFormat = '%vx';
		option.scrollSpeed = 5;
		option.minValue = -2;
		option.maxValue = 2;
		option.changeValue = 0.1;
		addOption(option);


		var option:Option = new Option('Shit gains : ',
			'How many times of health you want to gain when hitting shit',
			'shitHealth',
			'float',
			1);
		option.displayFormat = '%vx';
		option.scrollSpeed = 5;
		option.minValue = -2;
		option.maxValue = 2;
		option.changeValue = 0.1;

		addOption(option);

/**	
    //I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

	
		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		
**/
		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}