package net.artstorm.utils {


/**
* This class groups a couple of commonly used string operations.
**/
public class Strings {


	/** 
	* Unescape a string and filter "asfunction" occurences ( can be used for XSS exploits).
	* 
	* @param str	The string to decode.
	* @return 		The decoded string.
	**/
	public static function decode(str:String):String {
		if(str.indexOf('asfunction') == -1) {
			return unescape(str);
		} else {
			return '';
		}
	};


	/**
	* Basic serialization: string representations of booleans and numbers are returned typed;
	* strings are returned urldecoded.
	*
	* @param val	String value to serialize.
	* @return		The original value in the correct primitive type.
	**/
	public static function serialize(val:String):Object {
		if(val == null) {
			return null;
		} else if (val == 'true') {
			return true;
		} else if (val == 'false') {
			return false;
		} else if (isNaN(Number(val)) || val.length > 5) {
			return Strings.decode(val);
		} else {
			return Number(val);
		}
	};


	/**
	* Strip HTML tags and linebreaks off a string.
	*
	* @param str	The string to clean up.
	* @return		The clean string.
	**/
	public static function strip(str:String):String {
		var tmp:Array = str.split("\n");
		str = tmp.join("");
		tmp = str.split("\r");
		str = tmp.join("");
		var idx:Number = str.indexOf("<");
		while(idx != -1) {
			var end:Number = str.indexOf(">",idx+1);
			end == -1 ? end = str.length-1: null;
			str = str.substr(0,idx)+" "+str.substr(end+1,str.length);
			idx = str.indexOf("<",idx);
		}
		return str;
	};


	/** 
	* Add a leading zero to a number.
	* 
	* @param nbr	The number to convert. Can be 0 to 99.
	* @ return		A string representation with possible leading 0.
	**/
	public static function zero(nbr:Number):String {
		if(nbr < 10) {
			return '0'+nbr;
		} else {
			return ''+nbr;
		}
	};


}


}