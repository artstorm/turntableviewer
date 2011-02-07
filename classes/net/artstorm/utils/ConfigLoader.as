package net.artstorm.utils {

import net.artstorm.utils.Strings;


import flash.display.Sprite;
	
	import flash.net.URLRequest;
import flash.net.URLLoader;

import flash.events.Event;
import flash.events.EventDispatcher;


	
	public class ConfigLoader extends EventDispatcher {
	/** Reference to a display object to get flashvars from. **/
	private var reference:Sprite;
	/** Reference to the config object. **/
	private var config:Object;
	/** XML loading object reference **/
	private var loader:URLLoader;
	
		public function ConfigLoader(ref:Sprite) {
			reference = ref;
		}
		
			/**
	* Start the variables loading process.
	* 
	* @param cfg	An object with key:value defaults; existing values are overwritten and new ones are added.
	**/
	public function load(cfg:Object):void {
		config = cfg;
	
		var xml:String = reference.root.loaderInfo.parameters['config'];
		if(xml) {
			loadXML(Strings.decode(xml));
		} else {
			loadFlashvars();
		}
	}


	/** Load configuration data from external XML file. **/
	private function loadXML(url:String):void {
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE,xmlHandler);
		try {
			loader.load(new URLRequest(url));
		} catch (err:Error) {
			loadFlashvars();
		}
	}


	/** Parse the XML from external configuration file. **/
	private function xmlHandler(evt:Event):void {
		var dat:XML = XML(evt.currentTarget.data);
		var obj:Object = new Object();
		for each (var prp:XML in dat.children()) {
			obj[prp.name()] = prp.text();
		}
		compareWrite(obj);
			loadFlashvars();
	}


	/** Set config variables or load them from flashvars. **/
	private function loadFlashvars():void {
		compareWrite(reference.root.loaderInfo.parameters);
		dispatchEvent(new Event(Event.COMPLETE));
	}


	/** Compare and save new items in config. **/
	private function compareWrite(obj:Object):void {
		for (var cfv:String in obj) {
			config[cfv.toLowerCase()] = Strings.serialize(obj[cfv.toLowerCase()]);
//			config[cfv] = obj[cfv];
		}
	}

	
	
	
	
	
	
	
		
	}
}