package debug;

class FPSCounter extends openfl.text.TextField {

	public var currentFPS(default, null):Int;
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;
	@:noCompletion private var daTime:Float;

	public function new():Void {
		super();
		this.x = this.y = 0;
		currentFPS = 0;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat('_sans', 14, 0xff000000);
		autoSize = LEFT;
		multiline = true;
		times = [];
		daTime = 0;
	}

	private override function __enterFrame(deltaTime:Float):Void {
		times.push(daTime += deltaTime);
		while (times[0] < daTime - 1000) {times.shift();}
		currentFPS = times.length;
		updateText();
	}

	public dynamic function updateText():Void {
		text = 'FPS: $currentFPS\nGCM: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
		textColor = currentFPS < FlxG.drawFramerate * 0.5 ? 0xffff0000 : 0xffffffff;
	}

	inline public function get_memoryMegas():Float {
		return cast (openfl.system.System.totalMemory, UInt);
	}

}