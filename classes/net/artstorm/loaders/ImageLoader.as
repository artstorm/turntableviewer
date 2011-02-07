/**
* Model for playback of GIF/JPG/PNG images.
**/
package net.artstorm.loaders {

	import net.artstorm.events.*;
	import net.artstorm.turntable.LoaderManager;
	import net.artstorm.utils.Draw;

	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class ImageLoader extends AbstractLoader {

		/** Loader that loads the image. **/
		private var loader:Loader;
		/** ID for the position interval. **/
		private var interval:Number;
		
		/** Temp Sprite to hold the sequence **/
		var imgseq:Sprite;
		var frames:Number;
		var loadProgress:Boolean;
		var file:String;
		var fileNr:Number;
		var fileDigits:Number;
		var fileFmt:String;
		var fileHeight:Number;
		var fileWidth:Number;


	public function ImageLoader(lm:LoaderManager):void {
		super(lm);
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderHandler);
		loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		// temp init
		imgseq = new Sprite();
		frames = 0;
		loadProgress = false;
	}


	/** load image into screen **/
	override public function load(itm:Object):void {
		if (loadProgress == false) {
			item = itm;
			position = 0;
			// temp
			fileFmt = item['file'].substr(-4)
			// temp to find seq digits
			var s:Number = -5;
			var f:Boolean = false
			var ctr:Number = 0
			while (f == false) {
				var a:String = item['file'].substr(s,1);
				if (a == "0" || a == "1" || a == "2" || a == "3" || a == "4" || a == "5" || a == "6" || a == "7" || a == "8" || a == "9") {
					s -= 1;
					ctr++;
				} else {
					f = true;
					s += 1;
					file = item['file'];
					file = file.substr(0, file.length+s);
					fileDigits = ctr;
					fileNr = Number(item['file'].substr(s,ctr));
				}
			}
		}
		loadProgress = true;
		// Temp to build the string
		var zeros:String = "";
		if (fileNr < 10) { for (var i:int=0; i < fileDigits-1; i++) { zeros = zeros + "0"; } }
		if (fileNr > 9) { for (var j:int=0; j < fileDigits-2; j++) { zeros = zeros + "0"; } }
		if (fileNr > 99) { for (var k:int=0; k < fileDigits-3; k++) { zeros = zeros + "0"; } }
		var loadFile:String = file + zeros + fileNr + fileFmt;
//		trace (loadFile);
		loader.load(new URLRequest(loadFile),new LoaderContext(true));
		loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.BUFFERING});
		loaderManager.sendEvent(LoaderManagerEvent.BUFFER,{percentage:0});
	}


	/** Catch errors. **/
	private function errorHandler(e:ErrorEvent):void {
//		loaderManager.mediaHandler(loader);
//		loaderManager.mediaHandler(imgseq);
//		loaderManager.sendEvent(LoaderManagerEvent.META,{duration:0,
//														 height:e.target.height,
//														 width:e.target.width});
		loaderManager.sendEvent(LoaderManagerEvent.META,{duration:frames-1,
														 height:fileHeight,
														 width:fileWidth});
		loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.LOADED});
//		stop();
//		loaderManager.sendEvent(LoaderManagerEvent.ERROR,{message:e.text});

		loadProgress = false;
		frames = 0;
	}


	/** Load and place the image on stage. **/
	private function loaderHandler(e:Event):void {
			// Testar att ha den här istället
			loaderManager.mediaHandler(imgseq);
		// Make a copy of the bitmap and add it to the container
		var bitmapImage:Bitmap = new Bitmap(Bitmap(loader.content).bitmapData.clone());
		var bitmapCopy = imgseq.addChild(bitmapImage);
		bitmapCopy.name = frames;
		// Configure and position the bitmap
		bitmapCopy.smoothing = true;
		frames++;
		fileNr++;
		fileHeight = e.target.height;
		fileWidth = e.target.width;
		load(loader);




//		loaderManager.mediaHandler(loader);
//		try {
//			Bitmap(loader.content).smoothing = true;
//		} catch (err:Error) {}
//		loaderManager.sendEvent(LoaderManagerEvent.META,{duration:0,
//														 height:e.target.height,
//														 width:e.target.width});
//		Sprite(loader.content).gotoAndStop(1);
//		loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.LOADED});
	}




		/** Send load progress to viewer. **/
		private function progressHandler(e:ProgressEvent):void {
			var pct = Math.round(e.bytesLoaded/e.bytesTotal*100);
//			loaderManager.sendEvent(LoaderManagerEvent.BUFFER,{percentage:pct});
			loaderManager.sendEvent(LoaderManagerEvent.BUFFER,{percentage:0});
		}


		/** Go to to a certain position in the item. **/
		override public function goto(pos:Number):void {
//			MovieClip(loader.content).gotoAndStop(pos);
			position = pos;
//			trace (pos);
//			trace( imgseq.getChildByName(String(pos)) );
//			imgseq.swapChildren( imgseq.getChildByName(String(pos)) );
			var topPosition:uint = imgseq.numChildren - 1;
			imgseq.setChildIndex(imgseq.getChildByName(String(pos)), topPosition);
		}


		/** Stop the swf and unload it. **/
		override public function stop():void {
			if(loader.contentLoaderInfo.bytesLoaded != loader.contentLoaderInfo.bytesTotal) {
				loader.close();
			} else {
				loader.unload();
				Draw.clear(imgseq);
			}
			position = 0;
			loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.IDLE});
		}


};


}