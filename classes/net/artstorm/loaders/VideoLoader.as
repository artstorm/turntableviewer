/**
* Wrapper for playback of progressively downloaded video.
**/
package net.artstorm.loaders {


//import com.jeroenwijering.events.*;
//import com.jeroenwijering.models.AbstractModel;
//import com.jeroenwijering.player.Model;
import net.artstorm.utils.NetClient;

import flash.events.*;
import flash.media.*;
import flash.net.*;
import flash.utils.*;


public class VideoLoader extends AbstractLoader {


	/** Video object to be instantiated. **/
	protected var video:Video;
	/** NetConnection object for setup of the video stream. **/
	protected var connection:NetConnection;
	/** NetStream instance that handles the stream IO. **/
	protected var stream:NetStream;
	/** Sound control object. **/
	protected var transform:SoundTransform;
	/** ID for the position interval. **/
	protected var interval:Number;
	/** Interval ID for the loading. **/
	protected var loadinterval:Number;
	/** Load offset for bandwidth checking. **/
	protected var loadtimer:Number;


	/** Constructor; sets up the connection and display. **/
//	public function VideoLoader(mod:Model):void {
	public function VideoLoader(mod):void {
		super(mod);
		connection = new NetConnection();
		connection.connect(null);
		stream = new NetStream(connection);
		stream.addEventListener(NetStatusEvent.NET_STATUS,statusHandler);
		stream.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,errorHandler);
		stream.bufferTime = model.config['bufferlength'];
		stream.client = new NetClient(this);
		video = new Video(320,240);
		video.smoothing = model.config['smoothing'];
		video.attachNetStream(stream);
		transform = new SoundTransform();
	};


	/** Catch security errors. **/
	protected function errorHandler(evt:ErrorEvent):void {
		stop();
//		model.sendEvent(ModelEvent.ERROR,{message:evt.text});
	};


	/** Load content. **/
	override public function load(itm:Object):void {
		item = itm;
		position = 0;
		model.mediaHandler(video);
		stream.checkPolicyFile = true;
		stream.play(item['file']);
		interval = setInterval(positionInterval,100);
		loadinterval = setInterval(loadHandler,200);
		model.config['mute'] == true ? volume(0): volume(model.config['volume']);
//		model.sendEvent(ModelEvent.BUFFER,{percentage:0});
//		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.BUFFERING});
	};


	/** Interval for the loading progress **/
	protected function loadHandler():void {
		var ldd:Number = stream.bytesLoaded;
		var ttl:Number = stream.bytesTotal;
//		model.sendEvent(ModelEvent.LOADED,{loaded:ldd,total:ttl});
		if(ldd == ttl && ldd > 0) {
			clearInterval(loadinterval);
		}
		if(!loadtimer) {
			loadtimer = setTimeout(loadTimeout,3000);
		}
	};


	/** timeout for checking the bitrate. **/
	protected function loadTimeout():void {
		var obj:Object = new Object();
		obj['bandwidth'] = Math.round(stream.bytesLoaded/1024/3*8);
		if(item['duration']) {
			obj['bitrate'] = Math.round(stream.bytesTotal/1024*8/item['duration']);
		}
		model.sendEvent('META',obj);
	};


	/** Get metadata information from netstream class. **/
	public function onData(dat:Object):void {
		if(dat.width) {
			video.width = dat.width;
			video.height = dat.height;
		}
//		model.sendEvent(ModelEvent.META,dat);
	};


	/** Pause playback. **/
	override public function pause():void {
		stream.pause();
		clearInterval(interval);
//		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PAUSED});
	};


	/** Resume playing. **/
	override public function play():void {
		stream.resume();
		interval = setInterval(positionInterval,100);
//		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PLAYING});
	};


	/** Interval for the position progress **/
	protected function positionInterval():void {
		position = Math.round(stream.time*10)/10;
		var bfr:Number = Math.round(stream.bufferLength/stream.bufferTime*100);
		if(bfr < 95 && position < Math.abs(item['duration']-stream.bufferTime-1)) {
//			model.sendEvent(ModelEvent.BUFFER,{percentage:bfr});
			if(model.config['state'] != ModelStates.BUFFERING && bfr < 25) {
//				model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.BUFFERING});
			}
		} else if (bfr > 95 && model.config['state'] != ModelStates.PLAYING) {
//			model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PLAYING});
		}
		if(position < item['duration']) {
//			model.sendEvent(ModelEvent.TIME,{position:position,duration:item['duration']});
		} else if (item['duration'] > 0) {
			stream.pause();
			clearInterval(interval);
//			model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.COMPLETED});
		}
	};


	/** Seek to a new position. **/
	override public function seek(pos:Number):void {
		position = pos;
		clearInterval(interval);
		stream.seek(position);
		play();
	};


	/** Receive NetStream status updates. **/
	protected function statusHandler(evt:NetStatusEvent):void {
		switch (evt.info.code) {
			case "NetStream.Play.Stop":
				clearInterval(interval);
				model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.COMPLETED});
				break;
			case "NetStream.Play.StreamNotFound":
				stop();
				model.sendEvent(ModelEvent.ERROR,{message:'Video not found or access denied: '+item['file']});
				break;
			default:
				model.sendEvent(ModelEvent.META,{info:evt.info.code});
				break;
		}
	};


	/** Destroy the video. **/
	override public function stop():void {
		if(stream.bytesLoaded < stream.bytesTotal) {
			stream.close();
		} else { 
			stream.pause();
		}
		loadtimer = undefined;
		clearInterval(loadinterval);
		clearInterval(interval);
		position = 0;
		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.IDLE});
	};


	/** Set the volume level. **/
	override public function volume(vol:Number):void {
		transform.volume = vol/100;
		stream.soundTransform = transform;
	};


};


}