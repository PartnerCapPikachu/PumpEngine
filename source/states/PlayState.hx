package states;

class PlayState extends FlxState {

	public var camHUD:FlxCamera;

	public var strumLineNotes:FlxSpriteGroup;
	public var opponentStrums:FlxSpriteGroup;
	public var playerStrums:FlxSpriteGroup;

	override public function create():Void {

		FlxG.cameras.add(camHUD = new FlxCamera());
		camHUD.bgColor = 0xff00ff00;

		add(strumLineNotes = new FlxSpriteGroup());
		strumLineNotes.cameras = [camHUD];

		for (i in 0...8) {

			var strum:StrumNote = new StrumNote(i > 3 ? i - 4 : i, i < 4 ? 0 : 1);
			strumLineNotes.add(strum);

			strum.setPosition(100 + strum.noteData * StrumNote.swagWidth, FlxG.height * .01 * 2);
			if (strum.player == 1) {
				strum.x += FlxG.width * .5;
			}

			if (strum.player == 0) {
				playerStrums.add(strum);
			} else {
				opponentStrums.add(strum);
			}

		}

		super.create();

	}

	override public function update(elapsed:Float):Void {

		super.update(elapsed);

	}

}