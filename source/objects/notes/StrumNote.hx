package objects.notes;

class StrumNote extends FlxSprite {

  public static final swagWidth:Float = 160 * 0.7;

  public var noteData:Int;
  public var player:Int;

  public function new(d:Int, p:Int):Void {

    super();

    angle = (noteData = d) == 1 ? 180 : d == 2 ? 0 : d == 3 ? 90 : -90;
    player = p;

    frames = Paths.getSparrowAtlas('NOTES/STRUM');
    animation.addByPrefix('static', 'STATIC', 1, true);
    animation.addByPrefix('confirm', 'CONFIRM', 24, false);
    animation.addByPrefix('pressed', 'PRESSED', 24, false);
    animation.play('static');

    setGraphicSize(109, 109);
    updateHitbox();

    antialiasing = true;

  }

}