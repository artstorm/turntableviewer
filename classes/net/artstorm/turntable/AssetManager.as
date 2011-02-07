package net.artstorm.turntable {
	import net.artstorm.events.AssetManagerEvent;

	import flash.display.Sprite;
	import flash.events.*;

	public class AssetManager extends EventDispatcher {

		/** Reference to the controller config. **/
		private var config:Object;
		/** Reference to the theme. **/
		private var theme:Sprite;
		/** Reference to the viewer. **/
		private var turntable:Turntable;
		/** List with all the assets. **/
		private var assets:Array;

		/** Constructor, references  **/
		public function AssetManager(tt:Turntable) {
			config = tt.config;
			theme = tt.theme;
			turntable = tt;
			assets = new Array();
		}
		
		
		/** Add an asset to the application. **/
		public function addAsset(asset:Object, nam:String):void {
			var obj:Object = { reference:asset,name:nam,x:0,y:0,width:500,height:400};
			// Get the controlbar clip
			var cbr:Sprite = Sprite(theme.getChildByName('controlbar'));
			if(nam == 'controlbar') {
				config['controlbar.position'] = "bottom";
				config['controlbar.size'] = cbr.height;
				config['controlbar.margin'] = cbr.x;
			}
			// load config for plugin
			try {
				for(var org:String in asset.config) {
					obj[org] = asset.config[org];
				}
			} catch (err:Error) {}
			for(var str:String in config) {
				if (str.indexOf(nam + ".") == 0) {
					obj[str.substring(nam.length + 1)] = config[str];
				}
			}
			//Add asset to stage or create a new sprite for the aset
			var clp:Sprite;
			if(theme.getChildByName(nam)) {
				clp = Sprite(theme.getChildByName(nam));
			} else {
				clp = new Sprite();
				clp.name = nam;
				theme.addChildAt(clp,1);
			}
			// add asset to array and initialize
			assets.push(obj);
			try { 
				asset.config = obj;
				asset.clip = clp; 
			} catch (err:Error) {}
			if(cbr) { theme.setChildIndex(cbr,theme.numChildren-1); }
			asset.initAsset(turntable.controller);
		}


		/** Get a reference to a specific asset. **/
		public function getAsset(nam:String):Object {
			for(var i:Number=0; i<assets.length; i++) { 
				if(assets[i]['name'] == nam) {
					return assets[i]['reference'];
				}
			}
			return null;
		}
	
		
		/** Start loading the theme, or broadcast if there's none. **/
		public function loadTheme():void {
			if(config['theme']) {
				loadSWF(config['theme'],true);
			} else {
				dispatchEvent(new AssetManagerEvent(AssetManagerEvent.THEME));
			}
		}
		
import flash.display.*;
import flash.events.*;
import flash.net.URLRequest;
import flash.system.*;

/** Load a particular SWF file. **/
	private function loadSWF(str:String,skn:Boolean):void {
		if(str.substr(-4) == '.swf') { str = str.substr(0, str.length-4); }
		var ldr:Loader = new Loader();
		if(skn) {
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,skinError);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,skinHandler);
		}
		str += '.swf';
		if(theme.loaderInfo.url.indexOf('http') == 0) {
//			trace ("http");
			var ctx:LoaderContext = new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain);
			ldr.load(new URLRequest(str),ctx);
		} else {
//			trace ("ej http");
			ldr.load(new URLRequest(str));
		}
	};
	
		/** Skin loading failed; use default skin. **/
	private function skinError(evt:IOErrorEvent=null):void {
		dispatchEvent(new AssetManagerEvent(AssetManagerEvent.THEME));
	};


	/** Skin loading completed; add to stage and populate. **/
	private function skinHandler(evt:Event):void {
		try {
			var skn:MovieClip = evt.target.content['turntable'];
			while(skn.numChildren > 0) {
				var chd:DisplayObject = theme.getChildByName(skn.getChildAt(0).name);
				
				if(chd) {
					var idx:Number = theme.getChildIndex(chd);
					theme.removeChild(chd);
					theme.addChildAt(skn.getChildAt(0),idx);
					theme.getChildByName(chd.name).visible = false;
				} else { 
					theme.addChild(skn.getChildAt(0));
				}
			}
			dispatchEvent(new AssetManagerEvent(AssetManagerEvent.THEME));
		} catch (err:Error) {}
	};


		/** Layout all assets when resizing. **/
		public function layoutAssets():void {
			var bounds:Object = {x:0,y:0,width:config['width'],height:config['height']};
			var overs:Array = new Array();
			for(var i:Number = assets.length-1; i>=0; i--) {
				switch(assets[i]['position']) {
					case "left":
						assets[i]['x'] = bounds.x;
						assets[i]['y'] = bounds.y;
						assets[i]['width'] = assets[i]['size'];
						assets[i]['height'] = bounds.height;
						assets[i]['visible'] = true;
						bounds.x += assets[i]['size'];
						bounds.width -= assets[i]['size'];
						break;
					case "top":
						assets[i]['x'] = bounds.x;
						assets[i]['y'] = bounds.y;
						assets[i]['width'] = bounds.width;
						assets[i]['height'] = assets[i]['size'];
						assets[i]['visible'] = true;
						bounds.y += assets[i]['size'];
						bounds.height -= assets[i]['size'];
						break;
					case "right":
						assets[i]['x'] = bounds.x + bounds.width - assets[i]['size'];
						assets[i]['y'] = bounds.y;
						assets[i]['width'] = assets[i]['size'];
						assets[i]['height'] = bounds.height;
						assets[i]['visible'] = true;
						bounds.width -= assets[i]['size'];
						break;
					case "bottom":
						assets[i]['x'] = bounds.x;
						assets[i]['y'] = bounds.y+bounds.height-assets[i]['size'];
						assets[i]['width'] = bounds.width;
						assets[i]['height'] = assets[i]['size'];
						assets[i]['visible'] = true;
						bounds.height -= assets[i]['size'];
						break;
					case "none":
						assets[i]['visible'] = false;
						break;
					default:
						overs.push(i);
						break;
				}
			}
			for(var j:Number=0; j<overs.length; j++) {
				assets[overs[j]]['x'] = bounds.x;
				assets[overs[j]]['y'] = bounds.y;
				assets[overs[j]]['width'] = bounds.width;
				assets[overs[j]]['height'] = bounds.height;
				assets[overs[j]]['visible'] = true;
			}
			config['width'] = bounds.width;
			config['height'] = bounds.height;
		}
	}
}