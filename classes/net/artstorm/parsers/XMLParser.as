/**
* Parse an turntable feed and translate it to a feedarray.
**/
package net.artstorm.parsers {


//import net.artstorm.parsers.JWParser;
import net.artstorm.utils.Strings;


public class XMLParser {


	/** Parse an ASX playlist for feeditems. **/
	public static function parse(dat:XML):Array {
		var arr:Array = new Array();
		for each (var i:XML in dat.children()) {
			if (i.localName() == 'clip') {
				arr.push(XMLParser.parseItem(i));
			}
		}
		return arr;
	};


	/** Translate ASX item to playlist item. **/
	public static function parseItem(obj:XML):Object {
		var itm:Object =  new Object();
		for each (var i:XML in obj.children()) {
			if(!i.localName()) { break; }
			switch(i.localName().toLowerCase()) {
//				case 'ref':
//					itm['file'] = i.@href.toString();
//					break;
				case 'thumb':
					itm['thumb'] = i.text().toString();
					break;
				case 'file':
					itm['file'] = i.text().toString();
					break;
//				case 'title':
//					itm['title'] = i.text().toString();
//					break;
//				case 'moreinfo':
//					itm['link'] = i.@href.toString();
//					break;
//				case 'abstract':
//					itm['description'] = i.text().toString();
//					break;
//				case 'author':
//					itm['author'] = i.text().toString();
//					break;
//				case 'duration':
//					itm['duration'] = Strings.seconds(i.@value.toString());
//					break;
//				case 'starttime':
//					itm['start'] = Strings.seconds(i.@value.toString());
//					break;
//				case 'param':
//					itm[i.@name] = i.@value.toString();
//					break;
			}
		}
		itm = TTParser.parseEntry(obj,itm);
		return itm;
	};


}


}