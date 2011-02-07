/**
* Handles the gallery to select between different turntable clips.
**/
package net.artstorm.assets {

	import net.artstorm.events.*;
	import net.artstorm.utils.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	
	public class Gallery implements AssetInterface {

		/** Configuration vars for this asset. **/
		public var config:Object = {};
		/** Reference to the asset clip. **/
		public var clip:Sprite;
		/** Reference to the controller. **/
		private var controller:AbstractController;
		/** The tween to fade in and out the gallery **/
		private var galleryTween:Tween;
		// Holds the thumbnail objects
		private var thumbArray:Array;
		// Gallery feature enabled or not
		private var enabled:Boolean;


		/** Constructor; add all needed listeners. **/
		public function Gallery():void {};


		/** Initialize the asset. **/
		public function initAsset(ctrl:AbstractController):void {
			controller = ctrl;
			controller.addControllerListener(ControllerEvent.GALLERY, galleryHandler);
			controller.addControllerListener(ControllerEvent.RESIZE, resizeHandler);
			controller.addLoaderManagerListener(LoaderManagerEvent.STATE, stateHandler);
			thumbArray = new Array();
			enabled = false;
		}
	
	
		/** Gallery loaded: build the gallery clip. **/
		private function galleryHandler(e:ControllerEvent):void {
			if (controller.gallery.length > 1) {
				enabled = true;
				buildGallery();
			}
			stateHandler();
			resizeHandler();
		}
	
	
		/** Builds the gallery clip and loads and assigns listeners to the thumbnails **/	
		private function buildGallery():void {
			if(!controller.gallery) { return; }
			Draw.clear(clip);
			/// Create the thumbnails Container
			var wid:Number = config['width'];
			drawBackground();
			clip.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			clip.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			clip.buttonMode = false;
			clip.mouseChildren = true;
		
			// Loop through the array of clips and thumbs
			for (var i:uint; i<controller.gallery.length; i++) {
				thumbArray[i] = new Thumbnail(controller.gallery[i]['thumb'],controller.config['thumbsize']);
				thumbArray[i].name = i.toString();
				thumbArray[i].y = (controller.config['thumbmargin']/2) + (controller.config['thumbsize']/2)-1;;
				clip.addChild(thumbArray[i]);
			}
			positionThumbs();
	
			clip.alpha = 0;
			clip.visible = true;
		}


		/** Add listeners to the thumbnails in the gallery. **/
		private function addThumbListeners():void {
			for (var i:uint; i<thumbArray.length; i++) {
				thumbArray[i].addEventListener(MouseEvent.CLICK, clickHandler);
				thumbArray[i].buttonMode = true;
			}
		}


		/** Remove listeners from the thumbnails in the gallery. **/
		private function removeThumbListeners():void {
			for (var i:uint; i<thumbArray.length; i++) {
				thumbArray[i].removeEventListener(MouseEvent.CLICK, clickHandler);
				thumbArray[i].buttonMode = false;
			}
		}

		
		/** Positions the thumbnails in the gallery **/
		private function positionThumbs():void {
			var wid:Number = config['width'];
			var thumbWidth = (thumbArray.length*controller.config['thumbsize']) + ((thumbArray.length-1)*controller.config['thumbmargin']);
			var xPos:Number = (wid/2) - (thumbWidth/2) + (controller.config['thumbsize']/2);
			for (var i:uint; i<thumbArray.length; i++) {
				thumbArray[i].x = xPos;
				xPos = xPos + controller.config['thumbsize'] + controller.config['thumbmargin'];
			}
		}


		/** Draws the gallery background **/
		private function drawBackground():void {
			var wid:Number = config['width'];
			clip.graphics.clear();
			clip.graphics.beginFill(0x000000,0.5);
			clip.graphics.drawRect(0, 0, wid,controller.config['thumbsize']+controller.config['thumbmargin']);
			clip.graphics.endFill();

		}


		/** Handle Mouse over of the gallery **/
		private function overHandler(e:MouseEvent):void {
			if (controller.config['state'] == LoaderStates.LOADED || controller.config['state'] == LoaderStates.IDLE) {
				galleryTween = new Tween(clip, "alpha", Strong.easeOut, clip.alpha, 1, 1, true);
			}
		}
		

		/** Handle Mouse out of the gallery **/
		private function outHandler(e:MouseEvent=null):void {
			galleryTween = new Tween(clip, "alpha", Strong.easeOut, clip.alpha, 0, 1, true);
		}


		/** Handle a click on a gallery item. **/
		private function clickHandler(evt:MouseEvent):void {
			outHandler();
			controller.sendEvent('item',Number(evt.currentTarget.name));
		}


		/** Handle state changes **/
		private function stateHandler(evt:LoaderManagerEvent=undefined):void {
			if (enabled == true) {
				switch(controller.config['state']) {
					case LoaderStates.LOADED:
						try {
							addThumbListeners();
						} catch (err:Error) {}
						break;
					case LoaderStates.BUFFERING:
						try {
							removeThumbListeners();
						} catch (err:Error) {}
						break;
					default:
						try {
							addThumbListeners();
						} catch (err:Error) {}
				}
			}
		}
		
		
		/** Handles resize events **/
		private function resizeHandler(e:ControllerEvent=null):void {
			if (enabled == true) {
				clip.x = config['x'];
				clip.y = config['y'] + config['height'] - controller.config["thumbsize"] - (controller.config["thumbmargin"]*2);
				drawBackground();
				positionThumbs();
			}
		}
	}
}