/**
* Class: FlashVars
* Handles reading and parsing of any submitted FlashVars.
*
* @author: Johan Steen
* @copyright: artstorm.net
* @package: net.artstorm
* @date: 13 January 2009
* @modified: 13 January 2009
* @version: 1.0.0
*
* @revisions
*/
package net.artstorm {
	import flash.display.LoaderInfo;

	public class FlashVars {
		
		// Constants:
		// Public Properties:
		// Private Properties:
		private var flashvars:Object;
		private var host_Obj:Object;

		private var preview:String;
		private var file:String;
		private var xml:String;
		private var config:String;
		
		// Initialization:
		public function FlashVars(host:Object) {
			host_Obj = host;
			flashvars = LoaderInfo(host_Obj.root.loaderInfo).parameters;
			initVars();
		}

		// Public Methods:
		public function getPreview():String {
			return preview;
		}
		public function getFile():String {
			return file;
		}
		public function getXML():String {
			// For local testing
            if(host_Obj.root.loaderInfo.url.indexOf("file:") != -1){
//                xml = "turntable.xml";
            }
			return xml;
		}
		
		public function getConfig():String {
			return config;
		}
		
		// Protected Methods:
		private function initVars():void {
			// Get the preview image
			if (flashvars["preview"]) 
				{ preview = flashvars["preview"]; } else { preview = "preview2.png"; }
			// Get the movie clip
			if (flashvars["file"]) 
				{ file = flashvars["file"]; } else { file = "converter.swf"; }
			// Get the XML file
			if (flashvars["xml"]) 
				{ xml = flashvars["xml"]; } else { }
			// Get the Config file
			if (flashvars["config"]) 
				{ config = flashvars["config"]; } else { }
		}
	}
	
}