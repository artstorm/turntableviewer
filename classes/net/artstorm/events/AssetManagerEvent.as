/**
* Definition of the events fired by the DisplayManager, which loads the theme and setup the assets.
**/
package net.artstorm.events {
	import flash.events.Event;

	public class AssetManagerEvent extends Event {
		
		/** Definition for the event that indicates the theme is loaded. **/
		public static const THEME:String = "THEME";


		/** Constructor **/
		public function AssetManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}


		/** Every custom event class must override clone **/
		public override function clone():Event {
			return new AssetManagerEvent(type, bubbles, cancelable);
		}


		/** Every custom event must override toString **/
		public override function toString():String {
			return formatToString("AssetManagerEvent", "type", "bubbles",
								  "cancelable", "eventPhase");
		}
	}
}