/**
* This is the base loader class all loaders must extend.
**/
package net.artstorm.loaders {

	import net.artstorm.events.*;
	import net.artstorm.turntable.LoaderManager;

	public class AbstractLoader {

		/** Reference to the LoaderManager. **/
		protected var loaderManager:LoaderManager;
		/** Reference to the currently active playlistitem. **/
		protected var item:Object;
		/** The current position inside the file. **/
		protected var position:Number;


		/**
		* Constructor; sets up reference to the MVC model.
		*
		* @param mod	The model of the player MVC triad.
		* @see Model
		**/
		public function AbstractLoader(lm:LoaderManager):void {
			loaderManager = lm;
		}


		/**
		* Load an item into the model.
		*
		* @param itm	The currently active playlistitem.
		**/
		public function load(itm:Object):void {
			item = itm;
			position = 0;
		}


		/**
		* Seek to a certain position in the item.
		*
		* @param pos	The position in seconds.
		**/
		public function goto(pos:Number):void {
			position = pos;
		}


		/** Stop playing and loading the item. **/
		public function stop():void {}


	}
}