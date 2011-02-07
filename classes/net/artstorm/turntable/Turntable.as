/**
* Application: Turntable Viewer for 3D rendered sequences
* Reads in one or several AS3 compiled swf's or jpg/png/gif imaage sequences and let's the user scrub or switch between them
*
* @author: Johan Steen
* @copyright: artstorm.net
* @date: 13 January 2009
* @modified: 21 September 2009
* @version: 2.0
*
* @revisions
* Version 2.0 - 21 September 2009
* - Rewrote the entire application architecture to be fully object oriented.
* - Added different stretching modes for the turntable clip when it differs from the viewer size.
* - Implemented error handling system, which should helpful when configuring the viewer.
* - Changed the config format for xml/flashvars settings.
* - Changed the gallery format to define a gallery of turntable clips.
* - Implemented a function to design a custom theme for the viewer.
* - Updated the default theme.
* - Removed gallery mouse listeners while loading new clip.
* - Implemented a loader for jpg/png/gif image sequences.
* - Changed the loading behaviour to progressively display the turntable while buffering.
* Version 1.1 - 18 August 2009
* - Added a config class to be able to set colors for the turntable controller
* - First Public Release
* Version 1.0 - 13 January 2009
* - Initial Release
*/
package net.artstorm.turntable {

	import net.artstorm.events.*;
	import net.artstorm.assets.*;
	import net.artstorm.loaders.*;
	import net.artstorm.utils.ConfigLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	

	public class Turntable extends Sprite {
		
		/** All configuration values. **/
		public var config:Object = {
//			file:"js-playlist.xml",
//			preview:"destra-preview.jpg",
			file:undefined,
			preview:undefined,

			displaycolor:undefined,
			backcolor:undefined,
			frontcolor:undefined,
			scrubcolor:undefined,

			width:500,
			height:400,
//			theme:"js-turntable-theme.swf",
			theme:undefined,

			item:0,
			smoothing:true,
			state:'IDLE',
			stretching:'uniform',
			
			thumbsize:80,
			thumbmargin:20,

			abouttext:"JS Turntable Viewer",
			aboutlink:"http://www.artstorm.net/plugins/turntable-flash-viewer/",
			version:'2.0'
		};


		/** Reference to all stage graphics. **/
		public var theme:Sprite;
		/** Reference to the controller of the viewer, handling all logic of the application. **/
		public var controller:Controller;
		/** Object that load the theme and managed display assets. **/
		private var assetManager:AssetManager;
		/** Object that loads the configuration **/
		private var configLoader:ConfigLoader;
		/** Reference to the loader manager that handles loading of the clips. **/
		private var loaderManager:LoaderManager;


		/** Constructor: Hides Viewer and waits until it's added to stage **/
		public function Turntable() {
			theme = this['turntable'];
			for(var i:int=0; i < theme.numChildren; i++) {
				theme.getChildAt(i).visible = false;
			}
			// ADDED_TO_STAGE was added in flash player 9.0.28.0
			try {
				addEventListener(Event.ADDED_TO_STAGE,loadConfig);
			} catch(err:Error) { loadConfig(); }
		}
		
		
		/** After added to stage, load the configuration. **/
		private function loadConfig(e:Event = null):void {
			try {
				removeEventListener(Event.ADDED_TO_STAGE,loadConfig);
			} catch(err:Error) { }
			
			configLoader = new ConfigLoader(this);
			configLoader.addEventListener(Event.COMPLETE,loadTheme);
			configLoader.load(config);
		}
		
		
		/** After the config has loaded, the player loads the theme if available. **/
		private function loadTheme(e:Event = null):void {
	  		assetManager = new AssetManager(this);
			assetManager.addEventListener(AssetManagerEvent.THEME,initApp);
			assetManager.loadTheme();
		}

	
		/** Init and setup all assets for the viewer. **/
		private function initApp(e:Event = null):void {
			controller = new Controller(config, theme, assetManager);
			loaderManager = new LoaderManager(config, theme, assetManager, controller);
			controller.endInit(loaderManager);
			
			loaderManager.addLoader(new ImageLoader(loaderManager), 'image');
			loaderManager.addLoader(new SWFLoader(loaderManager), 'swf');

			assetManager.addAsset(new Display(),'display');
			assetManager.addAsset(new Rightclick(),'rightclick');
			assetManager.addAsset(new Gallery(),'gallery');
			assetManager.addAsset(new Controlbar(),'controlbar');
			startViewer();
		}
		
		
		/**
		* Everything is now ready. The viewer gets redrawn, shown and the file is loaded.
		**/
		private function startViewer():void {
			controller.sendEvent(ControllerEvent.REDRAW);
			if(config['file']) {
				controller.sendEvent(ControllerEvent.LOAD,config);
			} else {
				controller.sendEvent(ControllerEvent.ERROR,{message:'No Turntable file or gallery specified.'});
			}
		}
	}
}