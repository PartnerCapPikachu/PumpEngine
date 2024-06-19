package states;

class PlayState extends FlxState {

	public var camHUD:FlxCamera;

	public var strumLineNotes:SprGrp<StrumNote>;
	public var opponentStrums:SprGrp<StrumNote>;
	public var playerStrums:SprGrp<StrumNote>;

	public var INST:FlxSound;
	public var VOCALS:Array<FlxSound>;

	override public function create():Void {

		Paths.clearStoredMemory();

		FlxG.cameras.add(camHUD = new FlxCamera());
		camHUD.bgColor = 0xff00ff00;

		add(strumLineNotes = new SprGrp<StrumNote>());
		strumLineNotes.cameras = [camHUD];

		opponentStrums = new SprGrp<StrumNote>();
		playerStrums = new SprGrp<StrumNote>();

		for (i in 0...8) {

			var strum:StrumNote = new StrumNote(i > 3 ? i - 4 : i, i > 3 ? 0 : 1);
			strumLineNotes.add(strum);

			strum.setPosition(100 + strum.noteData * StrumNote.swagWidth, FlxG.height * .01 * 2);
			if (strum.player == 0) {
				strum.x += FlxG.width * .5;
			}

			if (strum.player == 0) {
				playerStrums.add(strum);
			} else {
				opponentStrums.add(strum);
			}

		}

		VOCALS = [new FlxSound().loadEmbedded(Paths.voices('Test', 'Opponent')),
		new FlxSound().loadEmbedded(Paths.voices('Test', 'Player'))];

		FlxG.sound.list.add(VOCALS[0]);
		FlxG.sound.list.add(VOCALS[1]);
		FlxG.sound.list.add(FlxG.sound.music = INST = new FlxSound().loadEmbedded(Paths.inst('Test')));

		super.create();

		Paths.clearUnusedMemory();

		VOCALS[0].play();
		VOCALS[1].play();
		FlxG.sound.music.play();
		VOCALS[0].time = VOCALS[1].time = FlxG.sound.music.time = 0;

	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

}