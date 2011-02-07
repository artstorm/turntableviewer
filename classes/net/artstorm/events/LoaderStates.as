/**
* Static typed list of all possible loading states, fired with the 'state' event.
**/
package net.artstorm.events {

	public class LoaderStates {

		/** Nothing happening. No file in memory. **/
		public static var IDLE:String = "IDLE";
		/** Buffering; will show the clip when the buffer is loaded. **/
		public static var BUFFERING:String = "BUFFERING";
		/** The clip is loaded and available for scrubbing. **/
		public static var LOADED:String = "LOADED";

	}
}