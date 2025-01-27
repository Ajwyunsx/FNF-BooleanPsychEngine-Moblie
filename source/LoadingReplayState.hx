package;
//加载replay的入口界面
//Freeplay界面选择一项后按F2键进入
//在/replays文件夹下自动搜索并筛选songName符合条件的replay文件并打印评价信息。


import haxe.macro.Context.Message;
import openfl.net.FileReference;
import flixel.ui.FlxButton;

import flixel.math.FlxMath;
import openfl.net.FileReference;
import flixel.FlxG;
import flixel.FlxSprite;
import flash.net.FileFilter;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.events.Event;
import haxe.Json;

using StringTools;

class LoadingReplayState extends MusicBeatState
{
	public static var sName:String;

	var bg:FlxSprite = null;
	var exitButton:FlxButton;
	var playButton:FlxButton;
	var fileInfoText:FlxText;
	var judgeTxt:FlxText;
	var hintTxt:FlxText;
	var GpSettingTxt:FlxText;

	var fullPath:String = "";
	var curDirectory = 0;
	var directoryTxt:FlxText;
	var availFiles:Array<String> = [];

	var songName:String;
	var songDiff:Int;
	var timeStamp:String;
	var songScore:Int = 0;
	var rank:String;
	var hCombo:Int = 0;
	var sCombo:Int = 0;
	var cBreaks:Int = 0;
	var totNhit:Int = 0;
	var perfectNhit:Int = 0;
	var sickNhit:Int = 0;
	var goodNhit:Int = 0;
	var badNhit:Int = 0;
	var shitNhit:Int = 0;
	var songSpeedType:String;
	var scrollSpeed:Float;

	var idx:Int = 0;
	var _file:FileReference;

	var jsonFile:Dynamic;
	#if sys
	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;
	

		readFiles();
		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.getPath('images/menuBGBlue.png', IMAGE));
		bg.alpha = 1;
		bg.scrollFactor.set();
		add(bg);

		fileInfoText=new FlxText(100, 90,1150, "", 32);
		
		fileInfoText.text = "Record:\n  Difficulty : [No replay file load]\n  Time stamp : \n  Score : \n  Rank :\n  Combo breaks :\n";
		fileInfoText.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fileInfoText.updateHitbox();
		fileInfoText.borderSize=1.75;
		add(fileInfoText);

		judgeTxt=new FlxText(100, 410,1150, "", 32);
	
		judgeTxt.text = "Judgements :\n  Total notes hit :\n  Sick :\n  Good :\n  Bad :\n  Shit :\n";
		judgeTxt.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgeTxt.updateHitbox();
		judgeTxt.borderSize=1.75;
		add(judgeTxt);

		hintTxt=new FlxText(860, 410,420, "", 16);
		hintTxt.text = "Up/down : Select the replay file\nEsc/Backspace : Exit the replay page\nEnter : Play on this replay file";
		hintTxt.setFormat(Paths.font("vcr.ttf"), 16,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		hintTxt.updateHitbox();
		hintTxt.borderSize=1;
		add(hintTxt);

		GpSettingTxt=new FlxText(860, 90,420, "", 16);
		GpSettingTxt.text = "Gameplay Setting:";
		GpSettingTxt.setFormat(Paths.font("vcr.ttf"), 16,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		GpSettingTxt.updateHitbox();
		GpSettingTxt.borderSize=1;
		add(GpSettingTxt);

		
		directoryTxt = new FlxText(20,20, FlxG.width, "" + sName + " : " + (idx+1) + "/" +availFiles.length + " replay", 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		directoryTxt.updateHitbox();
		directoryTxt.borderSize=1.75;
		directoryTxt.scrollFactor.set();
		add(directoryTxt);
		try{
			fullPath = Sys.getCwd() + "replays/" + availFiles[idx];

			var rawJson:String = File.getContent(fullPath);
			trace("Successfully loaded file: " + fullPath);
			jsonFile = cast Json.parse(rawJson);
		}
		catch(e){
			fileInfoText.text = "No Replays Available!!";
		}
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}


	private function updateInfo(i:Int = 0,elapsed:Float){
		if(availFiles.length == 0)return;
		
		fileInfoText.text = "Record\n  Difficulty : " + CoolUtil.getDifficultyFilePath(songDiff) +
		 "\n  Time stamp : " + timeStamp + "\n  Score : " + 
		 Math.floor(FlxMath.lerp(songScore, Std.parseInt(jsonFile.songScore), CoolUtil.boundTo(elapsed * 6, 0, 1)))
		+ "\n  Rank :" + rank + "\n  Combo breaks : " + 
		Math.floor(FlxMath.lerp(cBreaks, Std.parseInt(jsonFile.comboBreaks), CoolUtil.boundTo(elapsed * 0.12, 0, 1)));
		
		judgeTxt.text = "Judgements :\n  Total notes hit : " +  
		Math.floor(FlxMath.lerp(totNhit , Std.parseInt(jsonFile.totNoteHit), CoolUtil.boundTo(elapsed * 0.12, 0, 1)) )
		+ (Std.parseInt(jsonFile.replayGameVer)<2?"":("\n  Perfect : " + 
		Math.floor(FlxMath.lerp(perfectNhit , Std.parseInt(jsonFile.totPerfect), CoolUtil.boundTo(elapsed *0.12, 0, 1))  )))
	//以往版本没有perfect这个等级
		+ "\n  Sick : " + 
		Math.floor(FlxMath.lerp(sickNhit , Std.parseInt(jsonFile.totSick), CoolUtil.boundTo(elapsed *0.12, 0, 1))  )
		+ "\n  Good : " + 
		Math.floor(FlxMath.lerp(goodNhit, Std.parseInt(jsonFile.totGood), CoolUtil.boundTo(elapsed * 0.12, 0, 1)) )
		+ "\n  Bad : " +
		Math.floor(FlxMath.lerp(badNhit , Std.parseInt(jsonFile.totBad), CoolUtil.boundTo(elapsed * 0.12, 0, 1)))
		   + "\n  Shit : " +
		Math.floor(FlxMath.lerp(shitNhit , Std.parseInt(jsonFile.totShit), CoolUtil.boundTo(elapsed * 0.12, 0, 1)))
		;
		directoryTxt.text = "" + sName + " : " + (idx+1) + "/" +availFiles.length + " replay";

		songDiff = Std.parseInt(jsonFile.songDiff);
		songName = jsonFile.songName;
		timeStamp = jsonFile.timestamp;
		songScore = Std.parseInt(jsonFile.songScore);
		rank = jsonFile.rank;
		cBreaks = Std.parseInt(jsonFile.comboBreaks);
		totNhit = Std.parseInt(jsonFile.totNoteHit);
		perfectNhit = Std.parseInt(jsonFile.totPerfect);
		sickNhit = Std.parseInt(jsonFile.totSick);
		goodNhit = Std.parseInt(jsonFile.totGood);
		badNhit = Std.parseInt(jsonFile.totBad);
		shitNhit = Std.parseInt(jsonFile.totShit);

		scrollSpeed = Std.parseFloat(jsonFile.scrollSpeed);
		if(Math.isNaN(scrollSpeed))scrollSpeed = 1;
		songSpeedType = jsonFile.songSpeedType;
		if(songSpeedType == null)songSpeedType = "multiplicative";

		GpSettingTxt.text = "Gameplay Setting : \nSong Speed Type : "+ songSpeedType + "\nScroll Speed : " + scrollSpeed + ((songSpeedType == "multiplicative") ? "x" : '') + "\n ";
		//这里是为了兼容之前的replay
		if(jsonFile.perfectWindow)
			GpSettingTxt.text = GpSettingTxt.text + 
			"\n Perfect  " + jsonFile.perfectWindow + "ms" + 
			"\n Sick     " + jsonFile.sickWindow + "ms"+
			"\n Good     " + jsonFile.goodWindow + "ms"+
			"\n Bad      " + jsonFile.badWindow + "ms";		

	}

	//读取replays目录下replay文件
	private function readFiles(){
		var files = FileSystem.readDirectory(Sys.getCwd() + "replays/");
		trace(files);

		for (file in files){
			try{
				var rawJson:String = File.getContent(Sys.getCwd() + "replays/" + file);
				var jsonFile = cast Json.parse(rawJson);
				trace(jsonFile.songName);
				if(jsonFile.songName.toLowerCase() == sName.toLowerCase())	
					availFiles.push(file);

			}catch(e){
				continue;
			}
		}

		trace(availFiles);
	}
	
	override function update(elapsed:Float)
	{
		if(FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN){
			if(availFiles.length == 0)return;
			if(FlxG.keys.justPressed.UP)idx--;
			if(FlxG.keys.justPressed.DOWN)idx++;
			if(idx == -1)idx = availFiles.length - 1;
			if(idx >= availFiles.length)idx = 0;

			fullPath = Sys.getCwd() + "replays/" + availFiles[idx];

			var rawJson:String = File.getContent(fullPath);
			trace("Successfully loaded file: " + fullPath);
			jsonFile = cast Json.parse(rawJson);
		}
		updateInfo(idx,elapsed);
		if(FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE){
			trace("Back to freeplay");
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplayState());
		}

		if(FlxG.keys.justPressed.ENTER){
			try{
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songName);
				var poop:String = Highscore.formatSong(songLowercase, songDiff);
			
			
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = songDiff;
				PlayState.loadRep = true;
				PlayState.repPath = fullPath;
	
	
				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				FlxG.mouse.visible = false;
				LoadingState.loadAndSwitchState(new PlayState());

				FlxG.sound.music.volume = 0;
						
				trace("Start Playing!!");
			}catch(e){				
				trace("Play failed!");
				return;
			}
		}
		
		super.update(elapsed);
	}
#end

}

