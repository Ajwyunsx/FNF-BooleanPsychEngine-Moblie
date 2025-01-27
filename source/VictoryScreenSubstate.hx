package;

//显示胜利结算界面
//如果界面关闭但是没有正常退出，就再按5退出

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import Replay.Ana;
import haxe.Json;
#if desktop
import sys.io.File;
#end
class VictoryScreenSubstate extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];	

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	var saveAllowed:Bool = true;
	//在非开发者模式下，botplay是不允许进行保存的

	override public function update(elapsed:Float) {
		if(controls.ACCEPT #if android || FlxG.mouse.justPressed #end){
			PlayState.instance.exitVic();
			close();
		}
		if(FlxG.keys.justPressed.F3 #if android || FlxG.android.justReleased.BACK #end && saveAllowed){
			PlayState.instance.Repreced = false;
			PlayState.instance.saveRpl();
		}
	}

	public function new(score:Int,misses:Int,rank:String,accuracy:Float,ratingFC:String,totNoteHit:Int,perfectHit:Int,sickHit:Int,sickCombo:Int,hcombo:Int,goodHit:Int,badHit:Int,shitHit:Int,rpana:Array<Ana>,saveNotes:Array<Dynamic>,loadRep:Bool,isBot:Bool,repTimeStamp:String)
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var sCld:FlxText = new FlxText(40, 5, 1000, "", 32);
		sCld.text = "Song Cleared!";
		sCld.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sCld.updateHitbox();
		sCld.borderSize=2;
		add(sCld);

		var snameTxt:FlxText = new FlxText(60, 5, 1000, "", 16);
		snameTxt.text = PlayState.instance.curSongName;
		snameTxt.setFormat(Paths.font("YaHeiUI.ttf"), 20,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		snameTxt.updateHitbox();
		snameTxt.borderSize=2;

		snameTxt.text = snameTxt.text + "    " + Date.now();
		add(snameTxt);


		var scoreText:FlxText = new FlxText(60, 5,  1000, "", 32);
		scoreText.text = "Score : " + score;
		if(isBot){
			if(loadRep)scoreText.text = scoreText.text + " (REPLAY)";
			else scoreText.text = scoreText.text + " (BOTPLAY)";
		}

		scoreText.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.updateHitbox();
		scoreText.borderSize=2;

		add(scoreText);


		var hcomboTxt:FlxText = new FlxText(60, 5,  1000, "", 32);
		hcomboTxt.text = "Highest Combos : " + hcombo;
		hcomboTxt.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		hcomboTxt.updateHitbox();
		hcomboTxt.borderSize=2;

		add(hcomboTxt);

		var scombo:FlxText = new FlxText(60, 5,  1000, "", 32);
		scombo.text = "Highest Sick Combos: " + sickCombo;
		scombo.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scombo.updateHitbox();
		scombo.borderSize=2;

		add(scombo);

		var rankTxt:FlxText = new FlxText(60, 5, 1000, "", 32);
		rankTxt.text = "Rank : " + accuracy + "% (" + rank + ") " +ratingFC;
		rankTxt.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankTxt.updateHitbox();
		rankTxt.borderSize=2;

		add(rankTxt);

		var misTxt:FlxText = new FlxText(60, 5,  1000, "", 32);
		misTxt.text = "Combo Breaks : " + misses;
		misTxt.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		misTxt.updateHitbox();
		misTxt.borderSize=2;

		add(misTxt);

		var jdmt:FlxText = new FlxText(40, 5,  1000, "", 32);
		jdmt.text = "Judgements:";
		jdmt.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		jdmt.updateHitbox();
		jdmt.borderSize=2;

		add(jdmt);
		
		var totNtht:FlxText = new FlxText(60, 5, 1000, "", 32);
		totNtht.text = "Total Notes Hit:" + totNoteHit;
		totNtht.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		totNtht.updateHitbox();
		totNtht.borderSize=2;

		add(totNtht);

		var perfectNtht:FlxText = new FlxText(60, 5, 1000, "", 32);
		perfectNtht.text = "Perfect :" + perfectHit;
		perfectNtht.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		perfectNtht.updateHitbox();
		perfectNtht.borderSize=2;
		add(perfectNtht);

		var sickNtht:FlxText = new FlxText(60, 5, 1000, "", 32);
		sickNtht.text = "Sick :" + sickHit;
		sickNtht.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sickNtht.updateHitbox();
		sickNtht.borderSize=2;

		add(sickNtht);

		var goodNtht:FlxText = new FlxText(60, 5, 1000, "", 32);
		goodNtht.text = "Good :" + goodHit;
		goodNtht.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		goodNtht.updateHitbox();
		goodNtht.borderSize=2;

		add(goodNtht);

		var badNtht:FlxText = new FlxText(60, 5,  1000, "", 32);
		badNtht.text = "Bad  :" + badHit;
		badNtht.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		badNtht.updateHitbox();
		badNtht.borderSize=2;

		add(badNtht);

		var shitNtht:FlxText = new FlxText(60, 5, 1000, "", 32);
		shitNtht.text = "Shit :" + shitHit;
		shitNtht.setFormat(Paths.font("vcr.ttf"), 32,LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		shitNtht.updateHitbox();
		shitNtht.borderSize=2;

		add(shitNtht);

		var hintTxt1:FlxText = new FlxText(FlxG.width-1000, 5,  1000, "", 32);
		#if android
		hintTxt1.text="Press Touch to save replay. Press Back to exit";
		if(isBot && !loadRep){
			hintTxt1.text = "Press Back to exit";
			saveAllowed=false;
		}
		#else
		hintTxt1.text="Press F3 to save replay, Press Enter to exit";
		if(isBot && !loadRep){
			hintTxt1.text = "Press Enter to exit";
			saveAllowed=false;
		}
		#end
		hintTxt1.setFormat(Paths.font("vcr.ttf"), 20,RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		hintTxt1.updateHitbox();
		add(hintTxt1);


		var graph = new HitGraph(FlxG.width - 500, 45, 495, 240,rpana);
		graph.alpha = 1;
		trace(rpana.length);
		var cnt:Int = 0;
		for (i in 0...rpana.length)
			{
				// 0 = time
				// 1 = length
				// 2 = type
				// 3 = diff
				if(rpana[i] == null)continue;
				var obj = rpana[i].nearestNote;
				

				// judgement
				var obj1 = saveNotes[i][1];
				var obj3 = obj[0];
	
				var diff = rpana[i].hitTime - rpana[i].nearestNote[0];
				var judge = toJdmt(rpana[i].hitTime - rpana[i].nearestNote[0]);
	/*			trace(obj);
				trace(obj3);
				trace(diff);
				trace(judge);*/

				if (obj1 != -1){
					graph.addToHistory(diff, judge, obj3);
					cnt++;
				}	

			
			}
			trace(cnt);
			graph.update();


			var graphSprite = new OFLSprite(FlxG.width - 510, 0, 460, 240, graph);

			graphSprite.scrollFactor.set();
			graphSprite.alpha = 0;
			add(graphSprite);
		FlxTween.tween(bg, {alpha: 0.45}, 1, {ease: FlxEase.quartInOut});
		
		FlxTween.tween(sCld, {alpha: 1, y: sCld.y + 20}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		#if sys
		FlxTween.tween(snameTxt, {alpha: 1, y: 676}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		#end
		FlxTween.tween(scoreText, {alpha: 1, y: scoreText.y + 100}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(rankTxt, {alpha: 1, y: rankTxt.y + 140},1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(hcomboTxt, {alpha: 1, y: hcomboTxt.y + 180}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(scombo, {alpha: 1, y: scombo.y + 220}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(misTxt, {alpha: 1, y: misTxt.y + 260}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(jdmt, {alpha: 1, y: jdmt.y + 360}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(totNtht, {alpha: 1, y: totNtht.y + 400}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(perfectNtht, {alpha: 1, y: sickNtht.y + 440}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(sickNtht, {alpha: 1, y: sickNtht.y + 480}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(goodNtht, {alpha: 1, y: goodNtht.y + 520},1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(badNtht, {alpha: 1, y: badNtht.y + 560}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(shitNtht, {alpha: 1, y: shitNtht.y + 600}, 1, {ease: FlxEase.quartInOut, startDelay: 0});

		FlxTween.tween(hintTxt1, {alpha: 1, y: FlxG.height - 40}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
		FlxTween.tween(graphSprite, {alpha: 1, y: 70}, 1, {ease: FlxEase.quartInOut, startDelay: 0});



		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}


	//生成评价
	//5:perfect4：sick 3:good 2:bad 1:shit 0:其它
	public function toJdmt(delTime:Float):Int
		{
			delTime=Math.abs(delTime);
			if(delTime <= ClientPrefs.perfectWindow)
				return 5;
			if(delTime <= ClientPrefs.sickWindow)
				return 4;
			if(delTime <= ClientPrefs.goodWindow)
				return 3;
			if(delTime <= ClientPrefs.badWindow)
				return 2;
			if(delTime <= 166)
				return 1;
			return 0;

	}

}
