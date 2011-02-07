/**
* Handles all the logic of the application
**/
/*
Exec Order:
1. Load Event Sent from turntable.as - ControllerEvent.LOAD
2. Går till loadHandler().
3. Om galleri -> start load (som sen ger ett loaderHandler event), om single item, gå till (5) galleryHandler().

// Var gallery - följ denna
4. Går till loaderHandler som laddar in och parsar XML gallerylistan

// Samma igen både single o gallery hamnat i galleryhandler nu
5. galleryHandler()

6. Sen skickads en ControllEvent.GALLERY när galleriet är redo och appen kan börja användas. (listeners - loadermanager, display, gallery)

*/

package net.artstorm.turntable {

	import net.artstorm.events.*;
	import net.artstorm.utils.*;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.net.*;
	import flash.events.*;


	public class Controller extends AbstractController {

		/** Object with all configuration parameters **/
		private var _config:Object;
		/** Reference to all stage graphics. **/
		private var _theme:Sprite;
		/** Reference to the display Sprite. **/
		public var display:Sprite;
		/** Object that handles all the assets. **/
		private var assetManager:AssetManager;
		/** Object that handles clip loaders. **/
		private var loaderManager:LoaderManager;
		/** Gallerylist for the viewer. **/
		private var _gallery:Array;
		/** Object that manages loading of XML playlist. **/
		private var loader:URLLoader;
		/** File extensions of all supported mediatypes. **/
		private var EXTENSIONS:Object = {
//			'3g2':'video',
//			'3gp':'video',
//			'aac':'video',
//			'f4b':'video',
//			'f4p':'video',
//			'f4v':'video',
//			'flv':'video',
			'gif':'image',
			'jpg':'image',
//			'm4a':'video',
//			'm4v':'video',
//			'mov':'swf', // var video
//			'mp3':'sound',
//			'mp4':'video',
			'png':'image',
//			'rbs':'sound',
//			'sdp':'video',
			'swf':'swf'		// var image
//			'vp6':'video'
		};
		/** Elements of config that are part of the playlist. **/
		private var ELEMENTS:Object = {
			duration:0,
			file:undefined,
			thumb:undefined,
			start:0,
			type:undefined
		};

		/** Constructor **/
		public function Controller(config:Object, theme:Sprite, am:AssetManager) {
			_config = config;
			assetManager = am;
			display = Sprite(theme.getChildByName('display'));
			_theme = theme;
			_theme.stage.align     = StageAlign.TOP_LEFT;
			_theme.stage.scaleMode = StageScaleMode.NO_SCALE;
			_theme.stage.addEventListener(Event.RESIZE,resizeHandler);
			// XML Playlist loader			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,loaderHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		}


		/**  Getters for the config parameters, theme and gallery. **/
		override public function get config():Object { return _config; };
		override public function get gallery():Array { return _gallery; };
		override public function get theme():Sprite { return _theme; };
		/**  Subscribers to the controller. **/
		override public function addControllerListener(typ:String,fcn:Function):void {
			this.addEventListener(typ.toUpperCase(),fcn);
		}
		/**  Subscribers to the loaderManager. **/
		override public function addLoaderManagerListener(typ:String,fcn:Function):void {
			loaderManager.addEventListener(typ.toUpperCase(),fcn);
		}


		/** Register loadmanager with the controller and assign the listeners. **/
		public function endInit(lm:LoaderManager):void {
			addControllerListener(ControllerEvent.ITEM, itemHandler);
			addControllerListener(ControllerEvent.LOAD, loadHandler);
			addControllerListener(ControllerEvent.REDRAW, resizeHandler);
			loaderManager= lm;
			addLoaderManagerListener(LoaderManagerEvent.META,metaHandler);
		}


		/** Return the type of specific gallery item (the Loader to play it with) **/
		private function getModelType(itm:Object,sub:Boolean):String {
			if(!itm['file']) {
				return null;
			} else { 
				 return EXTENSIONS[itm['file'].substr(-3).toLowerCase()];
			}
		}


		/** Load a new gallery, or creates a pseudo gallery from a single file. **/
		private function loadHandler(e:ControllerEvent):void {
			if(config['state'] != 'IDLE') {
				sendEvent(ControllerEvent.STOP);
			}
			var obj:Object = new Object();
			// Create an object of the default file/gallery
			if (e.data.object['file']) {
				for(var itm:String in ELEMENTS) {
					if(e.data.object[itm]) {
						obj[itm] = Strings.serialize(e.data.object[itm]);
					}
				}
			}
			if(obj['file']) {
				if(getModelType(obj,false) == null) {
					// No loader class for default file, load as gallery xml.
					loader.load(new URLRequest(obj['file']));
					return;
				} else {
					// loader class existed for default file, create a single item gallery for it.
					galleryHandler(new Array(obj));
				}
			}
		}

		/** Check new playlist for playeable files and setup randomizing/autostart. **/
		private function galleryHandler(ply:Array):void {
			for(var i:Number = ply.length-1; i > -1; i--) {
				if(!ply[i]['duration'] || isNaN(ply[i]['duration'])) { ply[i]['duration'] = 0; }
				if(!ply[i]['start'] || isNaN(ply[i]['start'])) { ply[i]['start'] = 0; }

				ply[i]['type'] = getModelType(ply[i],true);
				if(!ply[i]['type']) { ply.splice(i,1); }
			}
			if(ply.length > 0) {
//				trace ("blev en playlist");
				_gallery = ply;
			} else {
//				trace ("blev ingen playlist");
				sendEvent(ControllerEvent.ERROR,{message:'No valid filetypes found in the gallery.'});
				return;
			}
			if(config['shuffle'] == true) {
	//			randomizer = new Randomizer(playlist.length);
	//			config['item'] = randomizer.pick();
			} else if (config['item'] >= gallery.length) {
				config['item'] = gallery.length-1;
			}
			sendEvent(ControllerEvent.GALLERY,{gallery:gallery});
		}



		
		/** Update playlist item duration. **/
		private function metaHandler(evt:LoaderManagerEvent):void {
//			trace ("I META HANDLER");
			if(evt.data.duration && gallery[config['item']]['duration'] == 0) {
				gallery[config['item']]['duration'] = evt.data.duration;
			}
			if(evt.data.width) {
				gallery[config['item']]['width'] = evt.data.width;
				gallery[config['item']]['height'] = evt.data.height;
			} 
//			trace ("playlist: " + playlist[config['item']]['height']);
		}





import net.artstorm.parsers.*;
	/** Loads and parses the XML gallery. **/
	private function loaderHandler(evt:Event):void {
		try {
			var dat:XML = XML(evt.target.data);
			var fmt:String = dat.localName().toLowerCase();
		} catch (err:Error) {
			sendEvent(ControllerEvent.ERROR,{message:'The gallery file is not a valid XML file.'});
			return;
		}
//		trace (fmt);
		switch (fmt) {
			case 'turntable':
				galleryHandler(XMLParser.parse(dat));
				break;
			default:
				sendEvent(ControllerEvent.ERROR,{message:'Unknown gallery format: '+fmt});
				return;
		}
	}
	/** Catch errors dispatched by the playlister. **/
	private function errorHandler(evt:ErrorEvent):void {
		sendEvent(ControllerEvent.ERROR,{message:evt.text});
	}
	
	



		/** Jump to a userdefined item in the playlist. **/
		private function itemHandler(evt:ControllerEvent):void {
			var itm:Number = evt.data.index;
			if (itm < 0) {
				playItem(0);
			} else if (itm > gallery.length-1) {
				playItem(gallery.length-1);
			} else if (!isNaN(itm)) {
				playItem(itm);
			}
		}
		
		
	/** Direct the model to play a new item. **/
	private function playItem(nbr:Number=undefined):void {
		if(!isNaN(nbr)) {
			config['item'] = nbr;
		}
		sendEvent(ControllerEvent.LOADITEM,{index:config['item']});
	}


		/** Send a redraw request when the stage is resized. **/
		private function resizeHandler(e:Event=null):void {
			config['width'] = theme.stage.stageWidth;
			config['height'] = theme.stage.stageHeight;
			assetManager.layoutAssets();
			dispatchEvent(new ControllerEvent(ControllerEvent.RESIZE));
		}
		
		
		/**  Dispatch events. **/
		override public function sendEvent(typ:String,prm:Object=undefined):void {
			typ = typ.toUpperCase();
			var dat:Object = new Object();
			switch(typ) {
				case 'ERROR':
					dat = prm;
					break;
				case 'LOAD':
					dat['object'] = prm;
					break;
				case 'ITEM':
					dat['index'] = prm;
					break;
				case 'SCRUB':
					dat['position'] = prm;
					break;
				default:
					if(prm == true || prm == 'true') {
						dat['state'] = true;
					} else if(prm === false || prm == 'false') {
						dat['state'] = false;
					}
					break;
			}
			dispatchEvent(new ControllerEvent(typ,dat));
		}
	}
}