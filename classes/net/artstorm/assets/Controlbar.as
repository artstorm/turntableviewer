/**
* Display a controlbar with the turntable scrubber.
**/
package net.artstorm.assets {

	import net.artstorm.events.*;
	import net.artstorm.utils.*;
	
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;


	public class Controlbar implements AssetInterface {

		/** List with configuration settings. **/
		public var config:Object = {};
		/** Reference to the controlbar clip. **/
		public var clip:Sprite;
		/** Reference to the controller. **/
		private var controller:AbstractController;
		/** A list with all controls. **/
		private var stacker:Stacker;
		/** Color object for frontcolor. **/
		private var front:ColorTransform;
		/** Color object for lightcolor. **/
		private var light:ColorTransform;
		/** Tween to fade up and down the scrub handle **/
		private var scrubAlphaTween:Tween;
	
		/** Constructor. **/
		public function Controlbar():void {};


		/** Initialize the asset. **/
		public function initAsset(ctrl:AbstractController):void {
			controller = ctrl;
			controller.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
			controller.addLoaderManagerListener(LoaderManagerEvent.STATE,stateHandler);
			
			stacker = new Stacker(clip);
			setColors();
			initScrubber();
			stateHandler();
		}


		/** Init all listeners for the Scrubber. **/
		private function initScrubber():void {
			clip["scrubber"].scrub.alpha = .6;
			clip["scrubber"].scrub.mouseChildren = false;
			clip["scrubber"].scrub.buttonMode = true;
			clip["scrubber"].scrub.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			clip["scrubber"].scrub.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			clip["scrubber"].scrub.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			clip["scrubber"].track.buttonMode = true;
			clip["scrubber"].track.mouseChildren = false;
			clip["scrubber"].track.addEventListener(MouseEvent.CLICK, clickHandler);
		}


		/** Handle mouse presses on scrub **/
		private function downHandler(e:MouseEvent):void {
			var scrubber = clip["scrubber"];
			var rct:Rectangle = new Rectangle(scrubber.track.x, scrubber.track.y, scrubber.track.width - scrubber.scrub.width, 0);
			scrubber.scrub.startDrag(false, rct);
			clip.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			clip.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}

		/** Handle mouse releases on scrub. **/
		private function upHandler(e:MouseEvent):void {
			var scrubber = clip["scrubber"];
			clip.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			clip.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			scrubber.scrub.stopDrag();
		}
	
		/** Handle mouse movements on scrub. **/
		private function moveHandler(e:MouseEvent):void {
			scrub();
		}

		/** Handle mouseouts from scrub **/
		private function outHandler(e:MouseEvent):void {
			var scrubber = clip["scrubber"];
			scrubAlphaTween = new Tween(scrubber.scrub, "alpha", Strong.easeOut, scrubber.scrub.alpha, .6, .5, true);
		}

		/** Handle mouseover on scrub **/
		private function overHandler(e:MouseEvent):void {
			var scrubber = clip["scrubber"];
			scrubAlphaTween = new Tween(scrubber.scrub, "alpha", Strong.easeOut, scrubber.scrub.alpha, 1, .5, true);
		}
		
		/** Handles mouse clicks on the track **/
		private function clickHandler(e:MouseEvent):void {
			switch(controller.config['state']) {
				case LoaderStates.LOADED:
					var scrubber = clip["scrubber"];
					var localX:Number = e.stageX-20;
					// Check which side of the dragger that was clicked
					if (localX > scrubber.scrub.x) {
						scrubber.scrub.x = localX-scrubber.scrub.width;
					} else {
						scrubber.scrub.x = localX;
					}
					scrub();
					break;
				case LoaderStates.IDLE:
					controller.sendEvent('ITEM');
					break;
				default:
			}
		}
		
		
		/** Sends a scrubbed event to the controller with the current position. **/
		private function scrub():void {
			var scrubber = clip["scrubber"];
			var mpl:Number = controller.gallery[controller.config['item']]['duration'];
			var pct:Number = (scrubber.scrub.x-scrubber.track.x) / (scrubber.track.width-scrubber.scrub.width) * mpl;
			controller.sendEvent('SCRUB',Math.round(pct));
		}


		/** Fix the scrubber size. **/
		private function setScrubber():void {
			try {
				clip["scrubber"].x = 20;
				clip["scrubber"].y = Math.round((clip.height - clip["scrubber"].height)/2);
				clip["scrubber"].scaleX = 1;
				clip["scrubber"].track.width = Math.round(clip.width-40);
			} catch (err:Error) {}
		}
		

		/** Handle resizing requests **/
		private function resizeHandler(evt:ControllerEvent=null):void {
			var wid:Number = config['width'];
			clip.x = config['x'];
			clip.y = config['y'];
			clip.visible = config['visible'];
			stacker.rearrange(wid);
			stateHandler();
			setScrubber();
		}


		/** Handle state changes **/
		private function stateHandler(evt:LoaderManagerEvent=undefined):void {
			switch(controller.config['state']) {
				case LoaderStates.LOADED:
					clip["scrubber"].scrub.visible = true;
					break;
				case LoaderStates.BUFFERING:
					try {
						clip["scrubber"].scrub.visible = false;
						clip["scrubber"].scrub.x = 0;
					} catch (err:Error) {}
					break;
				default:
					try {
						clip["scrubber"].scrub.visible = false;
					} catch (err:Error) {}
			}
		}


		/** Init the colors. **/
		private function setColors():void {
			if(controller.config['backcolor']) {
				var clr:ColorTransform = new ColorTransform();
				clr.color = uint('0x'+controller.config['backcolor'].substr(-6));
				clip["back"].transform.colorTransform = clr;
			}
			if(controller.config['frontcolor']) {
				try {
					front = new ColorTransform();
					front.color = uint('0x'+controller.config['frontcolor'].substr(-6));
					clip["scrubber"].track.transform.colorTransform = front;
					clip["scrubber"].scrub.icon.transform.colorTransform = front;
				} catch (err:Error) {}
			}
			if(controller.config['scrubcolor']) {
				try {
					light = new ColorTransform();
					light.color = uint('0x'+controller.config['scrubcolor'].substr(-6));
					clip["scrubber"].scrub.back.transform.colorTransform = light;
				} catch (err:Error) {}
			}
		}
	}
}