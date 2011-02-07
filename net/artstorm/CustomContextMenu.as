/**
* Class: CustomContextMenu
* Controls and defines a custom context menu for my flash applications.
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
package net.artstorm {
	import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class CustomContextMenu {
		
		// Constants:
		// Public Properties:
		// Private Properties:
		var host_Obj:Object;
		var cx_menu:ContextMenu;
	
		// Initialization:
		public function CustomContextMenu(host:Object) {
			host_Obj = host;
			initMenu();
		}
	
		// Public Methods:
		// Protected Methods:
		private function initMenu() {
			cx_menu = new ContextMenu();
			cx_menu.hideBuiltInItems();				// Hide the default Items

			var cx_title:ContextMenuItem = new ContextMenuItem( "Turntable Display v1.0" );
			var cx_copyright:ContextMenuItem = new ContextMenuItem( "Copyright ©2009, Johan Steen" );
			cx_title.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, visit_artstorm );
			cx_copyright.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, visit_artstorm );

			cx_menu.customItems.push(cx_title, cx_copyright);
			host_Obj.contextMenu = cx_menu;
		}

		private function visit_artstorm(e:ContextMenuEvent):void {
			var artstorm_link:URLRequest = new URLRequest( "http://www.artstorm.net/" );
			navigateToURL(artstorm_link, "_parent");
		}

	}
	
}