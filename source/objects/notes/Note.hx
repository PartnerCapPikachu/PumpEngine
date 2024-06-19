package objects.notes;

class Note extends FlxSprite {

  public var parent:Note;
  public var tail:Array<Note>;

  public var parentStrum:StrumNote;

  public var mustPress:Bool;
  public var noteData:Int;

  public function new(leStrum:StrumNote, ?anim:String = 'note'):Void {

    super();

    parentStrum = leStrum;
    mustPress = leStrum.player == 1;

    setPosition(parentStrum.x, parentStrum.y);

    frames = Paths.getSparrowAtlas('NOTES/NOTE');
    animation = new PsychAnimationController(this);
    animation.addByPrefix('note', 'NOTE');
    animation.addByPrefix('hold', 'HOLD');
    animation.addByPrefix('end', 'END');
    animation.play(anim);

    if (anim == 'note') {
      angle = (noteData = leStrum.noteData) == 1 ? 180 : noteData == 2 ? 0 : noteData == 3 ? 90 : -90;
      setGraphicSize(109, 109);
    }
    updateHitbox();

    antialiasing = true;

    x = parentStrum.x;

  }

}