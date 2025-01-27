package;
//Replay回放以及显示胜利界面散点图相关
import Controls.Control;
import flixel.FlxG;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Dictionary;
class Ana
{
	public var hitTime:Float;
	public var nearestNote:Array<Dynamic>;
	public var hit:Bool;
	public var hitJudge:String;

	public function new(_hitTime:Float, _nearestNote:Array<Dynamic>, _hit:Bool, _hitJudge:String)
	{
		hitTime = _hitTime;
		nearestNote = _nearestNote;
		hit = _hit;
		hitJudge = _hitJudge;
	}
}

class Analysis
{
	public var anaArray:Array<Ana>;

	public function new()
	{
		anaArray = [];
	}
}

typedef ReplayJSON =
{
	public var replayGameVer:String;
	public var songScore: Int;
	public var comboBreaks:Int;
	public var rank:String;
	public var totNoteHit:Int;
	public var totPerfect:Int;
	public var totSick:Int;
	public var totGood:Int;
	public var totBad:Int;
	public var totShit:Int;
	public var timestamp:Date;
	public var songName:String;
	public var songDiff:Int;
	public var songNotes:Array<Dynamic>;
	public var songJudgements:Array<String>;
	public var noteSpeed:Float;
	public var isDownscroll:Bool;
	public var sf:Float;
	public var sm:Bool;
	public var ana:Analysis;
	public var songSpeedType:String;
	public var scrollSpeed:Float;
	public var perfectWindow:Int;
	public var sickWindow:Int;
	public var goodWindow:Int;
	public var badWindow:Int;
}

class Replay
{
	public static var version:String = "2.0"; // replay file version

	public var path:String = "";
	public var replay:ReplayJSON;

	public function new(path:String)
	{
		this.path = path;
		replay = {
			songName: "No Song Found",
			songDiff: 1,
			noteSpeed: 1.5,
			isDownscroll: false,
			songNotes: [],
			replayGameVer: version,
			songScore: 0,
			comboBreaks:0,
			rank:"?", 
			totNoteHit:0,
			totPerfect:0,
			totSick:0,
			totGood:0,
			totBad:0,
			totShit:0,
			sm: false,
			timestamp: Date.now(),
			sf: ClientPrefs.safeFrames,
			ana: new Analysis(),
			songJudgements: [],
			songSpeedType:'',
			scrollSpeed:1,
			perfectWindow:0,
			sickWindow:0,
			goodWindow:0,
			badWindow:0,
		};
	}


	public function SaveReplay(score:Int,misses:Int,rank:String,accuracy:Float,ratingFC:String,totNoteHit:Int,perfectHit:Int,sickHit:Int,sickCombo:Int,hcombo:Int,goodHit:Int,badHit:Int,shitHit:Int,notearray:Array<Dynamic>,  ana:Array<Ana>,songSpeedType:String,scrollSpeed:Float,repTimeStamp:String)
	{

		var json = {
			"songName": PlayState.SONG.song,
			"songDiff": PlayState.storyDifficulty,
			"timestamp": Date.now(),
			"songScore": score,
			"comboBreaks":misses,
			"rank":"" + accuracy + "% - " + rank + " - " +ratingFC, 
			"totNoteHit":totNoteHit,
			"totPerfect":perfectHit,
			"totSick":sickHit,
			"totGood":goodHit,
			"totBad":badHit,
			"totShit":shitHit,
			"replayGameVer": version,
			"sf": ClientPrefs.safeFrames,
			"noteSpeed": (FlxG.save.data.scrollSpeed > 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed),
			"isDownscroll": FlxG.save.data.downscroll,
			"songNotes": notearray,
			"ana": ana,
			"songSpeedType":songSpeedType,
			"scrollSpeed":scrollSpeed,
			"perfectWindow":ClientPrefs.perfectWindow,
			"sickWindow":ClientPrefs.sickWindow,
			"goodWindow":ClientPrefs.goodWindow,
			"badWindow":ClientPrefs.badWindow
		};

		var data:String = Json.stringify(json, null, "");

		var time = Date.now().getTime();

		var file:FileReference = new FileReference();
		file.save(data,"replays/replay-" + PlayState.SONG.song + "-time" + time + ".replay");
		//如果想要自动读取的话，放在程序目录下的replays文件夹下。当然这个功能还在做。
	}
}
