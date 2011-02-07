/**
* Handles all the loading of different clips and the preview image.
**/
/*
	exec order:
	1. väntar på ett ControllerEvent.GALLERY för att start
	2. går till galleryHandler()

*/

package net.artstorm.turntable {

	import net.artstorm.events.*;
	import net.artstorm.loaders.AbstractLoader;
	import net.artstorm.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;


	public class LoaderManager extends EventDispatcher {

		/** Object with all configuration variables. **/
		public var config:Object;
		/** Reference to the display MovieClip. **/
		public var display:Sprite;
		/** Object with all display variables. **/
		private var assetManager:AssetManager;
		/** Reference to the viewer's controller. **/
		private var controller:Controller;
	
		/** Loader for the preview image. **/
		private var preview:Loader;
		/** The list with all active loaders. **/
		private var loaders:Object;
		/** Save the currently playing playlist item. **/
		private var item:Object;
		/** Save the current image url to prevent duplicate loading. **/
		private var image:String;

		/** Constructor, save references, setup listeners and init preview loader. **/
		public function LoaderManager(cfg:Object,skn:Sprite, am:AssetManager, ctr:Controller):void {
			config = cfg;
			display = Sprite(skn.getChildByName('display'));
			assetManager = am;
			controller = ctr;

			controller.addEventListener(ControllerEvent.LOADITEM,itemHandler);
			controller.addEventListener(ControllerEvent.GALLERY, galleryHandler); 
			controller.addEventListener(ControllerEvent.RESIZE,resizeHandler);
			controller.addEventListener(ControllerEvent.SCRUB,scrubHandler);
			controller.addEventListener(ControllerEvent.STOP,stopHandler);

			preview = new Loader();
			preview.contentLoaderInfo.addEventListener(Event.COMPLETE,previewHandler);
			preview.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,previewHandler);
			Draw.clear(display["media"]);
			display.addChildAt(preview,display.getChildIndex(display["media"]));
			display["media"].visible = false;
	
			loaders = new Object();
		}
		
			/** Add a new loader class. **/
			public function addLoader(ldr:AbstractLoader,typ:String):void {
				loaders[typ] = ldr;
			}
	
	/** Load the preview image. **/
	private function galleryHandler(evt:ControllerEvent):void {
//		trace ("LM: gallery handler");
//		var img:String = controller.gallery[config['item']]['image'];
		var img:String = config["preview"];
		if (img) {
//		if(img && img != image) {
			image = img;
			preview.load(new URLRequest(img),new LoaderContext(true));
		}
	};
	
	
		/** Item change: stop the old model and start the new one. **/
	private function itemHandler(evt:ControllerEvent):void {
		if(item) {
			loaders[item['type']].stop();
		}
		item = controller.gallery[config['item']];
//		trace ("playlist: " + item);
			for (var i in loaders) {
//    			trace(i + ' = ' + models[i]);
      		}
//		trace (item['type']);
		if(loaders[item['type']]) {
			loaders[item['type']].load(item);
		} else {
			sendEvent(LoaderManagerEvent.ERROR,{message:'No suiteable loader found for playback of this file.'});
		}
		if(item['image']) {
//			trace ("LM ItemHandler vilken1: " + item['image']);
//			if(item['image'] != image) {
//				image = item['image'];
//				thumb.load(new URLRequest(item['image']),new LoaderContext(true));
//			}
//		} else if(image) {
//			trace ("LM ItemHandler: vilken2");
//			image = undefined;
//			thumb.unload();
		}
		// Temp for unloading preview
		if (image) {
			image = undefined;
			preview.unload();
		}
	};


	/** 
	* Place the mediafile fro the current model on stage.
	* 
	* @param obj	The displayobject (MovieClip/Video/Loader) to display.
	**/
	public function mediaHandler(obj:DisplayObject=undefined):void {
//		trace ("I MEDIA HANDLER");
//		trace (obj.name);
		Draw.clear(display["media"]);
		display["media"].addChild(obj);
//		Draw.clear(display.media);
//		display.media.addChild(obj);
		resizeHandler();
	};







	/** Resize the media and thumb. **/
	private function resizeHandler(evt:Event=null):void {
		var wid:Number = assetManager.getAsset('display').config['width'];
		var hei:Number = assetManager.getAsset('display').config['height'];
//		trace ("wid: " + wid);
//		trace ("hei: " + hei);
//		Stretcher.stretch(display.media,wid,hei,config['stretching']);
//		Stretcher.stretch(display["media"],wid,hei,config['stretching']);
		Stretcher.stretch(display["media"],wid,hei,config['stretching']);
		if(preview.width > 10) {
			Stretcher.stretch(preview,wid,hei,config['stretching']);
		}
	};


	/** Make the current model seek. **/
	private function scrubHandler(evt:ControllerEvent):void {
		if(item && config['state'] == LoaderStates.LOADED) {
			loaders[item['type']].goto(evt.data.position);
		}
	}


	/** Make the current model stop and show the thumb. **/
	private function stopHandler(evt:ControllerEvent=undefined):void {
		if(item) {
			loaders[item['type']].stop();
		}
	};


	/**  
	* Dispatch events to the View/ Controller.
	* When switching states, the thumbnail is shown/hidden.
	* 
	* @param typ	The eventtype to dispatch.
	* @param dat	An object with data to send along.
	* @see 			ModelEvent
	**/
	public function sendEvent(typ:String,dat:Object):void {
		if(typ == LoaderManagerEvent.STATE) {
			dat['oldstate'] = config['state'];
			config['state'] = dat.newstate;
			switch(dat['newstate']) {
				case LoaderStates.IDLE:
//					trace ("idle");
					display["media"].visible = true;
					sendEvent(LoaderManagerEvent.LOADED,{loaded:0,offset:0,total:0});
					break;
				case LoaderStates.LOADED:
//					trace ("loaded");
//					display["media"].visible = true;
					sendEvent(LoaderManagerEvent.LOADED,{loaded:0,offset:0,total:0});
					break;
				case LoaderStates.BUFFERING:
//					trace ("buffering");
					break;
				
/*				case LoaderStates.COMPLETED:
					thumb.visible = true;
//					display.media.visible = false;
					display["media"].visible = false;
					sendEvent(LoaderManagerEvent.TIME,{position:0,duration:item['duration']});
					break;
				case LoaderStates.PLAYING:
					if(item['file'].indexOf('m4a') == -1
						&& item['file'].indexOf('mp3') == -1
						&& item['file'].indexOf('aac') == -1) {
						thumb.visible = false;
						display["media"].visible = true;
					} else { 
						thumb.visible = true;
//						display.media.visible = false;
						display["media"].visible = false;
					}
					break;*/
			}
		} else if(dat.width) {
			resizeHandler();
		}
		dispatchEvent(new LoaderManagerEvent(typ,dat));
	};


		/** Thumb loaded, try to antialias it before resizing. **/
		private function previewHandler(evt:Event) {
			try {
				Bitmap(preview.content).smoothing = true;
			} catch (err:Error) {}
			resizeHandler();
			// temp ?
			display["media"].visible = true;
		}
	}
}