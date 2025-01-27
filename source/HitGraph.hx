import flixel.FlxG;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

import Replay.Ana;

/**
 * stolen from https://github.com/HaxeFlixel/flixel/blob/master/flixel/system/debug/stats/StatsGraph.hx

 从Kade Engine拷贝并改编的代码
 在BPE的结算界面里面显示跟KE一样的按键散点图

 
 */
class HitGraph extends Sprite
{
	static inline var AXIS_COLOR:FlxColor = 0xffffff;
	static inline var AXIS_ALPHA:Float = 0.5;
	inline static var HISTORY_MAX:Int = 30;

	public var minLabel:TextField;
	public var curLabel:TextField;
	public var maxLabel:TextField;
	public var avgLabel:TextField;

	public var minValue:Float = -(Math.floor((ClientPrefs.safeFrames / 60) * 1000) + 95);
	public var maxValue:Float = Math.floor((ClientPrefs.safeFrames / 60) * 1000) + 95;

	public var showInput:Bool = FlxG.save.data.inputShow;

	public var graphColor:FlxColor;

	public var history:Array<Dynamic> = [];

	public var bitmap:Bitmap;

	public var ts:Float;

	var _axis:Shape;
	var _width:Int;
	var _height:Int;
	var _unit:String;
	var _labelWidth:Int;
	var _label:String;

	var ana0:Array<Ana> = [];

	public function new(X:Int, Y:Int, Width:Int, Height:Int ,rpana:Array<Ana>)
	{
		super();
		ana0 = rpana;
		x = X;
		y = Y;
		_width = Width;
		_height = Height;

		var bm = new BitmapData(Width, Height);
		bm.draw(this);
		bitmap = new Bitmap(bm);

		_axis = new Shape();
		_axis.x = _labelWidth + 10;

		ts = Math.floor((ClientPrefs.safeFrames / 60) * 1000) / 166;

		var early = createTextField(10, 10, FlxColor.WHITE, 12);
		var late = createTextField(10, _height - 20, FlxColor.WHITE, 12);

		early.text = "Early (" + -166 * ts + "ms)";
		late.text = "Late (" + 166 * ts + "ms)";

		addChild(early);
		addChild(late);

		addChild(_axis);

		drawAxes();

	}

	/**
	 * Redraws the axes of the graph.
	 */
	function drawAxes():Void
	{
		var gfx = _axis.graphics;
		gfx.clear();
		gfx.lineStyle(1, AXIS_COLOR, AXIS_ALPHA);

		// y-Axis
		gfx.moveTo(0, 0);
		gfx.lineTo(0, _height);

		// x-Axis
		gfx.moveTo(0, _height);
		gfx.lineTo(_width, _height);

		gfx.moveTo(0, _height / 2);
		gfx.lineTo(_width, _height / 2);
	}

	public static function createTextField(X:Float = 0, Y:Float = 0, Color:FlxColor = FlxColor.WHITE, Size:Int = 12):TextField
	{
		return initTextField(new TextField(), X, Y, Color, Size);
	}

	public static function initTextField<T:TextField>(tf:T, X:Float = 0, Y:Float = 0, Color:FlxColor = FlxColor.WHITE, Size:Int = 12):T
	{
		tf.x = X;
		tf.y = Y;
		tf.multiline = false;
		tf.wordWrap = false;
		tf.embedFonts = true;
		tf.selectable = false;
		#if flash
		tf.antiAliasType = AntiAliasType.NORMAL;
		tf.gridFitType = GridFitType.PIXEL;
		#end
		tf.defaultTextFormat = new TextFormat("assets/fonts/vcr.ttf", Size, Color.to24Bit());
		tf.alpha = Color.alphaFloat;
		tf.autoSize = TextFieldAutoSize.LEFT;
		return tf;
	}

	function drawJudgementLine(ms:Float,color:Int):Void
	{
		var gfx:Graphics = graphics;
		graphColor = color;

		gfx.lineStyle(1, graphColor, 0.3);

		var ts = Math.floor((ClientPrefs.safeFrames / 60) * 1000) / 166;
		var range:Float = Math.max(maxValue - minValue, maxValue * 0.1);



		var value = ((ms * ts) - minValue) / range;



		var pointY = _axis.y + ((-value * _height - 1) + _height);

		var graphX = _axis.x + 1;

		if (ms == 45)
			gfx.moveTo(graphX, _axis.y + pointY);

		var graphX = _axis.x + 1;

		gfx.drawRect(graphX, pointY, _width, 1);

		gfx.lineStyle(1, graphColor, 1);

	}

	/**
	 * Redraws the graph based on the values stored in the history.
	 */
	function drawGraph():Void
	{

		var gfx:Graphics = graphics;
		gfx.clear();
		gfx.lineStyle(1, graphColor, 1);

		gfx.beginFill(0x00FF00);
		drawJudgementLine(ClientPrefs.sickWindow,0x00FF00);
		gfx.endFill();

		gfx.beginFill(0xFF0000);
		drawJudgementLine(ClientPrefs.goodWindow,0xFF0000);
		gfx.endFill();

		gfx.beginFill(0x8b0000);
		drawJudgementLine(ClientPrefs.badWindow,0x8b0000);
		gfx.endFill();

		gfx.beginFill(0x580000);
		drawJudgementLine(166,0x580000);
		gfx.endFill();

		gfx.beginFill(0x00FF00);
		drawJudgementLine(-ClientPrefs.sickWindow,0x00FF00);
		gfx.endFill();

		gfx.beginFill(0xFF0000);
		drawJudgementLine(-ClientPrefs.goodWindow,0xFF0000);
		gfx.endFill();

		gfx.beginFill(0x8b0000);
		drawJudgementLine(-ClientPrefs.badWindow,0x8b0000);
		gfx.endFill();

		gfx.beginFill(0x580000);
		drawJudgementLine(-166,0x580000);
		gfx.endFill();

		var range:Float = Math.max(maxValue - minValue, maxValue * 0.1);
		var graphX = _axis.x + 1;

		for (i in 0...ana0.length)
		{
			if(ana0[i] == null)continue;
			var ana = ana0[i];

			var value = ((ana0[i].hitTime - ana0[i].nearestNote[0]) * 25 - minValue) / range;


			if (ana.hit)
				gfx.beginFill(0xFFFF00);
			else
				gfx.beginFill(0xC2B280);

			if (ana.hitTime < 0)
				continue;

			var pointY = (-value * _height - 1) + _height;
			gfx.drawRect(graphX + fitX(ana.hitTime), pointY, 2, 2);
			gfx.endFill();
		}

		for (i in 0...history.length)
		{
			var value = (history[i][0] - minValue) / range;
			var judge = history[i][1];
			switch (judge)
			{
				case 5:
					gfx.beginFill(0x00FFFF);
				case 4:
					gfx.beginFill(0xC8FF00);
				case 3:
					gfx.beginFill(0x00FF00);
				case 2:
					gfx.beginFill(0xFF0000);
				case 1:
					gfx.beginFill(0x8b0000);
				default:
					gfx.beginFill(0x000000);
			}
			var pointY = ((-value * _height - 1) + _height);


			/*if (i == 0)
				gfx.moveTo(graphX, _axis.y + pointY); */
			gfx.drawRect(fitX(history[i][2]), pointY, 4, 4);

			gfx.endFill();
		}

		var bm = new BitmapData(_width, _height);
		bm.draw(this);
		bitmap = new Bitmap(bm);
	}

	public function fitX(x:Float)
	{
		return ((x / (FlxG.sound.music.length)) * width);
	}

	public function addToHistory(diff:Float, judge:Int, time:Float)
	{
		history.push([diff, judge, time]);
	}

	public function update():Void
	{
		drawGraph();
	}

	public function average():Float
	{
		var sum:Float = 0;
		for (value in history)
			sum += value;
		return sum / history.length;
	}

	public function destroy():Void
	{
		_axis = FlxDestroyUtil.removeChild(this, _axis);
		history = null;
	}
}
