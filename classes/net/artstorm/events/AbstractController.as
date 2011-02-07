/**
* Abstract superclass for the Controller. Defines all methods accessible to assets.
**/
package net.artstorm.events {

import flash.display.Sprite;
import flash.events.EventDispatcher;


	public class AbstractController extends EventDispatcher {
	
	
		/** Constructor. **/
		public function AbstractController() {};
	
	
		/**  Getter for config, the hashmap with configuration settings. **/
		public function get config():Object { return new Object(); };
		/** Getter for the gallery, an array of hashmaps (file,thumb,etc) for each gallery entry. **/
		public function get gallery():Array { return new Array(); };
		/** Getter for skin, the on-stage player graphics. **/ 
		public function get theme():Sprite { return new Sprite(); };
	
	
		/**
		* *(Un)subscribe to events fired by the Controller (seek,load,resize,etc).
		* 
		* @param typ	The specific event to listen to.
		* @param fcn	The function that will handle the event.
		* @see 			ControllerEvent
		**/
		public function addControllerListener(typ:String,fcn:Function):void {};
		public function removeControllerListener(typ:String,fcn:Function):void {};
	
	
		/**
		* (Un)subscribe to events fired by the Model (time,state,meta,etc).
		* 
		* @param typ	The specific event to listen to.
		* @param fcn	The function that will handle the event.
		* @see 			ModelEvent
		**/
		public function addLoaderManagerListener(typ:String,fcn:Function):void {};
//		public function removeModelListener(typ:String,fcn:Function):void {};
	
	
	
		/**
		* Get a reference to a specific plugin.
		*
		* @param nam	The name of the plugin to return.
		* @return		A reference to the plugin itself. Public methods can be directly called on this.
		* @see 			SPLoader
		**/
		public function getPlugin(nam:String):Object { return {}; };
	

	
		/**
		* Dispatch an event. The event will be serialized and fired by the View.
		*
		* @param typ	The specific event to fire to.
		* @param prm	The accompanying parameter. Some events require one, others not.
		* @see 			ViewEvent
		**/
		public function sendEvent(typ:String,prm:Object=undefined):void {};
	
	
	}


}