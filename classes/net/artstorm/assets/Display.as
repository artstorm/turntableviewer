/**
* Handles the actual display area, media files and overlay icons
**/
package net.artstorm.assets {

	import net.artstorm.events.*;
	import net.artstorm.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;


	public class Display implements AssetInterface {

		/** Configuration vars for this asset. **/
		public var config:Object = {};
		/** Reference to the theme clip. **/
		public var clip:MovieClip;
		/** Reference to the controller. **/
		private var controller:AbstractController;
		/** Map with color transformation objects. **/
		private var colors:Object;
		/** A list of all the icons. **/
		private var ICONS:Array = new Array(
			'startIcon',
			'errorIcon',
			'bufferIcon'
		);
		/** Is there an error sent. **/
		private var errored:Boolean;


		/** Constructor; add all needed listeners. **/
		public function Display():void {};


		/** Initialize the plugin. **/
		public function initAsset(ctrl:AbstractController):void {
			controller = ctrl;
			controller.addControllerListener(ControllerEvent.ERROR, errorHandler);
			controller.addControllerListener(ControllerEvent.GALLERY, stateHandler);
			controller.addControllerListener(ControllerEvent.RESIZE, resizeHandler);
			controller.addLoaderManagerListener(LoaderManagerEvent.ERROR, errorHandler);
			controller.addLoaderManagerListener(LoaderManagerEvent.BUFFER, bufferHandler);
			controller.addLoaderManagerListener(LoaderManagerEvent.STATE, stateHandler);
			if(controller.config['backcolor'] && controller.config['frontcolor'] && controller.config['displaycolor']) {
				setColors();
			}
			clip.addEventListener(MouseEvent.CLICK,clickHandler);
			clip.buttonMode = true;
			clip.mouseChildren = false;
			stateHandler();
		}

		/** Process a click on the clip. **/
		private function clickHandler(evt:MouseEvent):void {
			if(controller.config['state'] == LoaderStates.IDLE) {
				controller.sendEvent('ITEM');
			}
		}


		/** Receive buffer updates. **/
		private function bufferHandler(e:LoaderManagerEvent):void {
			if(e.data.percentage > 0) {
				Draw.set(clip.bufferIcon.txt,'text',Strings.zero(e.data.percentage));
			} else {
				Draw.set(clip.bufferIcon.txt,'text','');
			}
		}


		/** Receive and print errors. **/
		private function errorHandler(e:Object):void {
			errored = true;
			setIcon('errorIcon');
			Draw.set(clip.errorIcon.txt,'text',e.data.message);
		}



		/** Receive resizing requests **/
		private function resizeHandler(evt:ControllerEvent):void {
			if(config['height'] > 11) {
				clip.visible = true;
			} else {
				clip.visible = false;
			}
			Draw.pos(clip,config['x'],config['y']);
			Draw.size(clip.back,config['width'],config['height']);
			for(var i:String in ICONS) {
				Draw.pos(clip[ICONS[i]],config['width']/2,config['height']/2);
			}
		}


		/** Set color tranformation objects so the buttons can be colorized. **/
		private function setColors():void {
			var scr:ColorTransform = new ColorTransform();
			scr.color = uint('0x'+controller.config['displaycolor']);
			var frt:ColorTransform = new ColorTransform();
			frt.color = uint('0x'+controller.config['frontcolor']);
			var bck:ColorTransform = new ColorTransform();
			bck.color = uint('0x'+controller.config['backcolor']);
			colors = {screen:scr,front:frt,back:bck};
			clip.back.transform.colorTransform = colors['screen'];
			for(var i:String in ICONS) {
				try {
					clip[ICONS[i]].back.transform.colorTransform = colors['front'];
					clip[ICONS[i]].icon.transform.colorTransform = colors['back'];
					clip[ICONS[i]].txt.textColor = colors['back'].color;
				} catch (err:Error) {}
			}
		}


		/** Set a specific icon in the clip. **/
		private function setIcon(icn:String=undefined):void {
			for(var i:String in ICONS) {
				if(clip[ICONS[i]]) {
					if(icn == ICONS[i]) {
						clip[ICONS[i]].visible = true;
					} else {
						clip[ICONS[i]].visible = false;
					}
				}
			}
		}


		/** Handle a change in playback state. **/
		private function stateHandler(evt:Event=null):void {
			switch (controller.config['state']) {
				case LoaderStates.BUFFERING:
					clip.removeEventListener(MouseEvent.CLICK,clickHandler);
					clip.buttonMode = false;
					setIcon('bufferIcon');
					break;
				case LoaderStates.IDLE:
					if(controller.config.displayclick == 'none' || !controller.gallery) {
						setIcon();
					} else if (errored) {
						errored = false;
					} else {
						setIcon('startIcon');
					}
					break;
				default:
					setIcon(controller.config.displayclick+'Icon');
					break;
			}
		}
	}
}
