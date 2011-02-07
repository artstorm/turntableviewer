/**
* Definitions for all event types fired by the LoaderManager.
**/
package net.artstorm.events {

	import flash.events.Event;


	public class LoaderManagerEvent extends Event {
	
		/** Definitions for all event types. **/
		public static var BUFFER:String = "BUFFER";
		public static var ERROR:String = "ERROR";
		public static var LOADED:String = "LOADED";
		public static var META:String = "META";
		public static var STATE:String = "STATE";
		/** The data associated with the event. **/
		private var _data:Object;
	
	
		/**
		* Constructor; sets the event type and inserts the new value.
		*
		* @param typ	The type of event.
		* @param dat	An object with all associated data.
		**/
		public function LoaderManagerEvent(typ:String,dat:Object=undefined,bbl:Boolean=false,ccb:Boolean=false):void {
			super(typ,bbl,ccb);
			_data = dat;
		}
	
		/** Returns the data associated with the event. **/
		public function get data():Object {
			return _data;
		}
	}
}