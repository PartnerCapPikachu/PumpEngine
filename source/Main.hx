package;

import objects.notes.StrumNote;
import openfl.Lib.current as curLib;

class Main extends openfl.display.Sprite {

	public var game:Dynamic = {width: 1280, height: 720, initialState: states.PlayState, zoom: -1., framerate: 60, skipSplash: true, startFullscreen: false};
	public var fps:FPSCounter;

	public function new():Void {

		super();

		if (game.zoom == -1.) {
			game.width = Math.ceil(curLib.stage.stageWidth / (game.zoom = Math.min(curLib.stage.stageWidth / game.width, curLib.stage.stageHeight / game.height)));
			game.height = Math.ceil(curLib.stage.stageHeight / game.zoom);
		}

		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < '5.0.0') game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		addChild(fps = new FPSCounter());

	}

}