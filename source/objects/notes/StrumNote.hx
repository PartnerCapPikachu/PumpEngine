package objects.notes;

class StrumNote extends FlxSprite {

  public static final swagWidth:Float = 160 * 0.7;

  public var noteData:Int;
  public var player:Int;

  public function new(noteDataOfStrum:Int, isPlayer:Int):Void {

    super();

    angle = (noteData = noteDataOfStrum) == 1 ? 180 : noteData == 2 ? 0 : noteData == 3 ? 90 : -90;
    player = isPlayer;

    frames = Paths.getSparrowAtlas('NOTES/STRUM');
    animation = new PsychAnimationController(this);
    animation.addByPrefix('static', 'STATIC', 1);
    animation.addByPrefix('confirm', 'CONFIRM', 24, false);
    animation.addByPrefix('pressed', 'PRESSED', 24, false);
    animation.play('static');

    setGraphicSize(109, 109);
    updateHitbox();

    antialiasing = true;

  }

}