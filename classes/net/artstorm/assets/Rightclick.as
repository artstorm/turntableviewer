/**
* Implement a rightclick menu with the default items hidden and an about link.
**/
package net.artstorm.assets {

	import net.artstorm.events.*;

	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;


	public class Rightclick implements AssetInterface {
	
		/** Plugin configuration object. **/
		public var config:Object = {};
		/** Reference to the contextmenu. **/
		private var context:ContextMenu;
		/** Reference to the 'about' menuitem. **/
		private var about:ContextMenuItem;
		/** Reference to the 'copyright' menuitem. **/
		private var copyright:ContextMenuItem;
		/** Reference to the controller. **/
		private var controller:AbstractController;
	
	
		/** Constructor. **/
		public function Rightclick():void {
			context = new ContextMenu();
			context.hideBuiltInItems();
		}
	
	
		/** Add an item to the contextmenu. **/
		private function addItem(itm:ContextMenuItem,fcn:Function):void {
			itm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,fcn);
//			itm.separatorBefore = true;
			context.customItems.push(itm);
		}
	
	
		/** Initialize the asset. **/
		public function initAsset(ctrl:AbstractController):void {
			controller = ctrl;
			controller.theme.contextMenu = context;
			// Add the 'about' menuitem.
			if(controller.config['abouttext'] == 'JS Turntable Viewer' || controller.config['abouttext'] == undefined) {
				about = new ContextMenuItem('About JS Turntable Viewer '+controller.config['version']+'...');
			} else {
				about = new ContextMenuItem('About '+controller.config['abouttext']+'...');
			}
			copyright = new ContextMenuItem('Copyright ©2009, Johan Steen');
			addItem(about,aboutHandler);
			addItem(copyright,copyrightHandler);
		}
	
	
		/** navigate to the about page. **/
		private function aboutHandler(evt:ContextMenuEvent):void {
			navigateToURL(new URLRequest(controller.config['aboutlink']),'_blank');
		}

		/** navigate to artstorm. **/
		private function copyrightHandler(evt:ContextMenuEvent):void {
			navigateToURL(new URLRequest("http://www.artstorm.net/"),'_blank');
		}

	}
}