/**
* Functions for drawing commonly used elements.
**/
package net.artstorm.utils {

	import flash.display.*;


	public class Draw {
	
	
		/**
		* Completely clear the contents of a displayobject.
		*
		* @param tgt	Displayobject to clear.
		**/
		public static function clear(tgt:DisplayObjectContainer):void {
			var len:Number = tgt.numChildren;
			for(var i:Number=0; i<len; i++) {
				tgt.removeChildAt(0);
			}
			tgt.scaleX = tgt.scaleY = 1;
		};
	
	
		/** 
		* Try positioning a certain displayobject.
		*
		* @param obj	The displayobject to position.
		* @param xps	New x position of the object.
		* @param yps	New y position of the object.
		**/
		public static function pos(obj:DisplayObject,xps:Number,yps:Number):void {
			try {
				obj.x = Math.round(xps);
				obj.y = Math.round(yps);
			} catch (err:Error) {}
		};
	
	
		/** 
		* Try setting a certain property of a displayobject. 
		*
		* @param obj	The displayobject to update.
		* @param prp	The property to update.
		* @param val	The new value of the property.
		**/
		public static function set(obj:DisplayObject,prp:String,val:Object) {
			try {
				obj[prp] = val;
			} catch (err:Error) {}
		};
	
	
		/**
		* Try resizing a certain displayobject.
		*
		* @param obj	The displayobject to resize.
		* @param wid	New width of the object.
		* @param hei	New height of the object.
		**/
		public static function size(obj:DisplayObject,wid:Number,hei:Number):void {
			try {
				obj.width = Math.round(wid);
				obj.height = Math.round(hei);
			} catch (err:Error) {}
		}
	}
}