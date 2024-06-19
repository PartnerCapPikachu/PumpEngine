package backend;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;

import lime.utils.Assets;
import flash.media.Sound;

import haxe.Json;

@:access(openfl.display.BitmapData)
class Paths {

	public static var SOUND_EXT:String = #if web 'mp3' #else 'ogg' #end;
	public static var VIDEO_EXT:String = 'mp4';

	public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];
	public static var localTrackedAssets:Array<String> = [];
	public static var currentLevel:String;
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function excludeAsset(key:String):Void {
		if (!dumpExclusions.contains(key)) {
			dumpExclusions.push(key);
		}
	}

	public static function clearUnusedMemory():Void {
		for (key in currentTrackedAssets.keys()) {
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}
		System.gc();
	}

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory():Void {
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedAssets.exists(key)) {
				destroyGraphic(FlxG.bitmap.get(key));
			}
		}
		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		localTrackedAssets = [];
		#if !html5
		openfl.Assets.cache.clear('songs');
		#end
	}

	public static function destroyGraphic(graphic:FlxGraphic):Void {
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null) {
			graphic.bitmap.__texture.dispose();
		}
		FlxG.bitmap.remove(graphic);
	}

	public static function setCurrentLevel(name:String):Void {
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentfolder:String):String {
		if (parentfolder != null) {
			return getFolderPath(file, parentfolder);
		}
		if (currentLevel != null && currentLevel != 'shared') {
			final levelPath:String = getFolderPath(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type)) {
				return levelPath;
			}
		}
		return getSharedPath(file);
	}

	inline public static function getFolderPath(file:String, ?folder:String = 'shared'):String {
		return 'assets/$folder/$file';
	}

	inline public static function getSharedPath(?file:String = ''):String {
		return 'assets/shared/$file';
	}

	inline public static function font(key:String):String {
		return 'assets/fonts/$key';
	}

	inline static public function txt(key:String, ?folder:String):String {
		return getPath('data/$key.txt', TEXT, folder);
	}

	inline static public function xml(key:String, ?folder:String):String {
		return getPath('data/$key.xml', TEXT, folder);
	}

	inline static public function json(key:String, ?folder:String):String {
		return getPath('data/$key.json', TEXT, folder);
	}

	inline static public function shaderFragment(key:String, ?folder:String):String {
		return getPath('shaders/$key.frag', TEXT, folder);
	}

	inline static public function shaderVertex(key:String, ?folder:String):String {
		return getPath('shaders/$key.vert', TEXT, folder);
	}

	inline static public function lua(key:String, ?folder:String):String {
		return getPath('$key.lua', TEXT, folder);
	}

	inline public static function video(key:String):String {
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	inline static public function sound(key:String):Sound {
		return returnSound('sounds/$key');
	}

	inline static public function music(key:String):Sound {
		return returnSound('music/$key');
	}

	inline static public function inst(song:String):Sound {
		return returnSound('${formatToSongPath(song)}/Inst', 'songs');
	}

	inline static public function voices(song:String, ?postfix:String = null):Sound {
		return returnSound('${formatToSongPath(song)}/Voices${postfix != null ? '-$postfix' : ''}', 'songs', false);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int):Sound {
		return sound(key + FlxG.random.int(min, max));
	}

	inline public static function image(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxGraphic {
		key = 'images/$key';
		if (key.lastIndexOf('.') < 0) {
			key += '.png';
		}
		if (currentTrackedAssets.exists(key)) {
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		return cacheBitmap(key, parentFolder, null, allowGPU);
	}

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic {
		if (bitmap == null) {
			final file:String = getPath(key, IMAGE, parentFolder);
			if (OpenFlAssets.exists(file, IMAGE)) {
				bitmap = OpenFlAssets.getBitmapData(file);
			}
			if (bitmap == null) {
				trace('null file: $file');
				return null;
			}
		}
		if (allowGPU && bitmap.image != null) {
			bitmap.lock();
			if (bitmap.__texture == null) {
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}
		final graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;
		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}

	inline public static function getTextFromFile(key:String, ?ignoreMods:Bool = false):String {
		final path:String = getPath(key, TEXT);
		return #if sys FileSystem.exists(path) ? File.getContent(path) : null #else OpenFlAssets.exists(path, TEXT) ? Assets.getText(path) : null #end;
	}

	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?parentFolder:String = null) {
		return OpenFlAssets.exists(getPath(key, type, parentFolder));
	}

	inline public static function getAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		final imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		final myXml:Dynamic = getPath('images/$key.xml', TEXT, parentFolder);
		if (OpenFlAssets.exists(myXml)) {
			return FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
		} else {
			final myJson:Dynamic = getPath('images/$key.json', TEXT, parentFolder);
			if (OpenFlAssets.exists(myJson)) {
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, myJson);
			}
		}
		return getPackerAtlas(key, parentFolder);
	}

	inline public static function getSparrowAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key, parentFolder, allowGPU), getPath('images/$key.xml', TEXT, parentFolder));
	}

	inline public static function getPackerAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, parentFolder, allowGPU), getPath('images/$key.txt', TEXT, parentFolder));
	}

	inline public static function getAsepriteAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromTexturePackerJson(image(key, parentFolder, allowGPU), getPath('images/$key.json', TEXT, parentFolder));
	}

	inline public static function formatToSongPath(path:String):String {
		return ~/[.,'"%?!]/.split(~/[~&\\;:<>#]/.split(path.replace(' ', '-')).join('-')).join('').toLowerCase();
	}

	public static function returnSound(key:String, ?path:String, ?beepOnNull:Bool = true):Sound {
		final file:String = getPath('$key.$SOUND_EXT', SOUND, path);
		if (!currentTrackedSounds.exists(file)) {
			#if sys if (FileSystem.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
			} #else if (OpenFlAssets.exists(file, SOUND)) {
				currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
			} #end else if (beepOnNull) {
				final e:String = 'SOUND NOT FOUND: $key, PATH: $path';
				trace(e);
				FlxG.log.error(e);
				return FlxAssets.getSound('flixel/sounds/beep');
			}
		}
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}

}