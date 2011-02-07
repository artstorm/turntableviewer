/**
* Class: Thumbnail
* Handles the thumbnail overlays when having several turntables in on flash instance.
*
* @author: Johan Steen
* @copyright: artstorm.net
* @package: net.artstorm
* @date: 13 January 2009
* @modified: 13 January 2009
* @version: 1.0.0
*
* @revisions
*/
package net.artstorm.assets {
	import flash.net.URLRequest; 
	import flash.display.Loader;  
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	

	public class Thumbnail extends Sprite {
		private var url:String;
		private var loader:Loader;
		private var thumbSize:Number;

		function Thumbnail(source:String, size:Number):void {
			url = source;
			thumbSize = size;
			drawLoader();
			addEventListener(MouseEvent.MOUSE_OVER,onOver);
			addEventListener(MouseEvent.MOUSE_OUT,onOut);
			scaleThumb();
		}
		private function drawLoader():void {
			// Build a background clip (also border)
			var bg_mc:Sprite = new Sprite();
			bg_mc.graphics.beginFill(0xffffff,1);
			bg_mc.graphics.drawRect(-(thumbSize/2)-2, -(thumbSize/2)-2, thumbSize+4,thumbSize+4);
			bg_mc.graphics.endFill();
			bg_mc.x = 0;
			bg_mc.y = 0;
			addChild(bg_mc);
			
			// Load the thumbnail image
			loader = new Loader();
			var request:URLRequest = new URLRequest(url);  
			loader.load(request);  
			
			loader.mouseEnabled = false;
			loader.x = -(thumbSize/2);
			loader.y = -(thumbSize/2);
			bg_mc.addChild(loader);
		}

	private function onOver(event:MouseEvent):void {
			var current:Number = this.scaleX;
			var curAlpha:Number = this.alpha;
			var target:Number = 1;
			var myTweenX:Tween = new Tween(this, "scaleX", Elastic.easeOut, current, target, 1, true);
			var myTweenY:Tween = new Tween(this, "scaleY", Elastic.easeOut, current, target, 1, true);
			var myTweenA:Tween = new Tween(this, "alpha", Elastic.easeOut, curAlpha, target, 1, true);
		}
		private function onOut(event:MouseEvent):void {
			var current:Number = this.scaleX;
			var curAlpha:Number = this.alpha;
			var target:Number = .9;
			var myTweenX:Tween = new Tween(this, "scaleX", Elastic.easeOut, current, target, 1, true);
			var myTweenY:Tween = new Tween(this, "scaleY", Elastic.easeOut, current, target, 1, true);
			var myTweenA:Tween = new Tween(this, "alpha", Elastic.easeOut, curAlpha, target, 1, true);
		}
		private function scaleThumb():void {
			this.scaleX = .9;
			this.scaleY = .9;
			this.alpha = .9;
		}
	}
}
