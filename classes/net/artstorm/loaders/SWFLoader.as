/**
* Model for playback of SWF Files.
**/
package net.artstorm.loaders {

	import net.artstorm.events.*;
	import net.artstorm.turntable.LoaderManager;

	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;


	public class SWFLoader extends AbstractLoader {

		/** Loader that loads the SWF. **/
		private var loader:Loader;


		/** Constructor; sets up listeners **/
		public function SWFLoader(lm:LoaderManager):void {
			super(lm);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderHandler);
			loader.contentLoaderInfo.addEventListener(Event.INIT,initHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		}

		/** load swf into memory **/
		override public function load(itm:Object):void {
			item = itm;
			position = 0;
			loader.load(new URLRequest(item['file']),new LoaderContext(true));
			loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.BUFFERING});
			loaderManager.sendEvent(LoaderManagerEvent.BUFFER,{percentage:0});
		}


		/** Catch errors. **/
		private function errorHandler(e:ErrorEvent):void {
			stop();
			loaderManager.sendEvent(LoaderManagerEvent.ERROR,{message:e.text});
		}


		private function initHandler(e:Event):void {
			// testar denna för att se när klippet laddas in
			loaderManager.mediaHandler(loader);
		}
		/** Place the swf on stage. **/
		private function loaderHandler(e:Event):void {
//			loaderManager.mediaHandler(loader);
			try {
				Bitmap(loader.content).smoothing = true;
			} catch (err:Error) {}
			loaderManager.sendEvent(LoaderManagerEvent.META,{duration:e.target.content.totalFrames,
															 height:e.target.height,
															 width:e.target.width});
			MovieClip(loader.content).gotoAndStop(1);
			loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.LOADED});
		}


		/** Send load progress to viewer. **/
		private function progressHandler(e:ProgressEvent):void {
			var pct = Math.round(e.bytesLoaded/e.bytesTotal*100);
			loaderManager.sendEvent(LoaderManagerEvent.BUFFER,{percentage:pct});
		}


		/** Go to to a certain position in the item. **/
		override public function goto(pos:Number):void {
			MovieClip(loader.content).gotoAndStop(pos);
			position = pos;
		}


		/** Stop the swf and unload it. **/
		override public function stop():void {
			if(loader.contentLoaderInfo.bytesLoaded != loader.contentLoaderInfo.bytesTotal) {
				loader.close();
			} else {
				loader.unload();
			}
			position = 0;
			loaderManager.sendEvent(LoaderManagerEvent.STATE,{newstate:LoaderStates.IDLE});
		}
	}
}