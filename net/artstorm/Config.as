/**
* Class: Config
* Reads in and parses the turntable configuration file.
*
* @author: Johan Steen
* @copyright: artstorm.net
* @package: net.artstorm
* @date: 18 August 2009
* @modified: 18 August 2009
* @version: 1.0.0
*
* @revisions
*/
package net.artstorm {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Config {
		
		// Constants:
		// Public Properties:
		public var controlbarTopColor:uint = 0x333333;
		public var controlbarBottomColor:uint = 0x222222;
		public var controlbarTopBorderColor:uint = 0xf0f0f0;
		public var controlbarBottomBorderColor:uint = 0xf0f0f0;
		public var controlbarTopBorderAlpha:Number = 0.1;
		public var controlbarBottomBorderAlpha:Number = 0.06;

		public var scrollBarBackgroundColor:uint = 0xf0f0f0;
		public var scrollBarBackgroundAlpha:Number = 0.1;

		public var scrollBarColor:uint = 0xf0f0f0;
		public var scrollBarIconColor:uint = 0x4d4d4d;

		// Private Properties:
		private var host_Obj:Object;
		private var myXML:XML;
		private var xmlLoader:URLLoader;
		private var config:String;
		// Initialization:
		public function Config(host:Object, configURL:String) {
			host_Obj = host;
			config = configURL;
			initConfig();
			loadConfig();
		}
	
		// Public Methods:
		// Protected Methods:
		private function initConfig() {
			myXML = new XML();
			xmlLoader = new URLLoader(); 

			myXML.ignoreWhitespace	= true;
		}
		
		private function loadConfig() {
			if (config) {
				xmlLoader.addEventListener(Event.COMPLETE, parseConfig); 
				xmlLoader.load(new URLRequest(config)); 
	//			xmlLoader.load(new URLRequest("http://share.artstorm.net/temp/js-turntable.xml?cache=123")); 
			}
		}
		
		private function parseConfig(e:Event) {
			myXML = new XML(e.target.data);

			// Init config parameters if the exists in the XML
			if (myXML.hasOwnProperty("controlbarTopColor")) { controlbarTopColor = uint(myXML.controlbarTopColor); }
			if (myXML.hasOwnProperty("controlbarBottomColor")) { controlbarBottomColor = uint(myXML.controlbarBottomColor); }
			if (myXML.hasOwnProperty("controlbarTopBorderColor")) { controlbarTopBorderColor = uint(myXML.controlbarTopBorderColor); }
			if (myXML.hasOwnProperty("controlbarBottomBorderColor")) { controlbarBottomBorderColor = uint(myXML.controlbarBottomBorderColor); }
			if (myXML.hasOwnProperty("controlbarTopBorderAlpha")) { controlbarTopBorderAlpha = Number(myXML.controlbarTopBorderAlpha); }
			if (myXML.hasOwnProperty("controlbarBottomBorderAlpha")) { controlbarBottomBorderAlpha = Number(myXML.controlbarBottomBorderAlpha); }

			if (myXML.hasOwnProperty("scrollBarBackgroundColor")) { scrollBarBackgroundColor = uint(myXML.scrollBarBackgroundColor); }
			if (myXML.hasOwnProperty("scrollBarBackgroundAlpha")) { scrollBarBackgroundAlpha = Number(myXML.scrollBarBackgroundAlpha); }

			if (myXML.hasOwnProperty("scrollBarColor")) { scrollBarColor = uint(myXML.scrollBarColor); }
			if (myXML.hasOwnProperty("scrollBarIconColor")) { scrollBarIconColor = uint(myXML.scrollBarIconColor); }

			host_Obj.setup();
		}
	}
}