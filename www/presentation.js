/*
 * Copyright 2014 Fraunhofer FOKUS
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * AUTHORS: Louay Bassbouss <louay.bassbouss@fokus.fraunhofer.de>
 *          Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */

var execRaw = require('cordova/exec'),
    cordova = require('cordova');

var makeAbs = function(url){
	var absUrl = null;
	try{absUrl = new URL(url,location.href).href; }catch(e){}
	if(!absUrl){
		var a = document.createElement('a');
		a.href = url;
		absUrl = a.href;
	}
	if (!absUrl) {
		absUrl = url;
	};
	return absUrl;
}

var exec = function(){
  var args = arguments;
  setTimeout(function() {
    execRaw.apply(undefined, args);
  }, 0);
}

/** WebIDL: NavigatorPresentation

  interface NavigatorPresentation : EventTarget {
    PresentationSession requestSession(DOMString url);
    attribute EventHandler onavailablechange;
    attribute EventHandler onpresent;
  };

  http://www.w3.org/2014/secondscreen/presentation-api/20140721/#NavigatorPresentation_interface

  TODO(mla): EventTarget implementation.

 */
function NavigatorPresentation() {
    // In case of mirroring, display the following placeholder page
    var defaultDisplay = makeAbs("presentation/display.html");
    var c=document.getElementsByTagName("script");
      for(var i=0; i<c.length; i++){
      if (c[i] && c[i].src && c[i].src.indexOf("/cordova.js") != -1){
        defaultDisplay= c[i].src.replace("/cordova.js","/presentation/display.html");
      }
    }
    exec(/*successCallback*/Function, /*errorCallback*/Function, "Presentation", "setDefaultDisplay", [ defaultDisplay ]);}

Object.defineProperty(NavigatorPresentation.prototype,"requestSession",{
get: function () {
  return navigatorPresentationRequestSession;
}
});

Object.defineProperty(NavigatorPresentation.prototype, "onavailablechange", {
  get: function () {
    return onavailablechange;
  },
  set: function(eventCallback) {
    if (typeof eventCallback == "function" || eventCallback == null || eventCallback == undefined) {
      onavailablechange = eventCallback;
      if (onavailablechange) {
        //trigger the service to serve screen states
        var scb = function(res){
            if (typeof onavailablechange == "function") {
                var evt = new AvailableChangeEvent("availablechange",res);
                onavailablechange(evt);
            }
        }
        exec(scb, function(){}, "Presentation", "addWatchAvailableChange", []);
      }
      else {
        //stop the service serving screen states
        exec(function(){}, function(){}, "Presentation", "clearWatchAvailableChange", []);
      }
    };
  }
});
//hold the reference to the user defined callback
var onavailablechange = undefined;

  // TODO(mla): check if on sender side this event can ever be expected
Object.defineProperty(NavigatorPresentation.prototype, "onpresent", {
get: function () {

}
});

var navigatorPresentationRequestSession = function(url) {
    var delSession = {
        _id:"",
        state: DISCONNECTED,
        onstatechange: function(){},
        onmessage: function(){}
    };
    delSession.postMessage = presentationSessionPostMessage(delSession);
    delSession.close = presentationSessionClose(delSession);

    var successCallback = function(result){
      // result == { id: String, eventType: String, value: String }
      delSession._id = result.id;
      switch(result.eventType) {
        case "onstatechange":
          delSession.state=result.value;
               if (typeof delSession.onstatechange == "function") {
               delSession.onstatechange(result.value);
               }
          break;
        case "onmessage":
               if (typeof delSession.onmessage == "function") {
          delSession.onmessage(result.value);
               }
          break;
        default:
          break;
      }
    };
    var errorCallback = function(){

    };
    exec(successCallback, errorCallback, "Presentation", "requestSession", [ makeAbs(url) ]);
    return new PresentationSession(delSession);
};


/** WebIDL: AvailableChangeEvent

  [Constructor(DOMString type, optional AvailableChangeEventInit eventInitDict)]
  interface AvailableChangeEvent : Event {
    readonly attribute boolean available;
  };

  dictionary AvailableChangeEventInit : EventInit {
    boolean available;
  };

  http://www.w3.org/2014/secondscreen/presentation-api/20140721/#AvailableChangeEvent_interface

 */
var AvailableChangeEvent = function(type, eventInitDict){
    this.type = type;
    var available = eventInitDict && eventInitDict.available == true;
    Object.defineProperty(this, "available", {
      get: function () {
        return available;
      }
    });
};

AvailableChangeEvent.prototype = Event.prototype;

/** WebIDL: PresentationSession

  enum PresentationSessionState { "connected", "disconnected" , "resumed"  };

  interface PresentationSession : EventTarget {
    readonly attribute PresentationSessionState state;
    void postMessage(DOMString message);
    void close();
    attribute EventHandler onmessage;
    attribute EventHandler onstatechange;
  };

  http://www.w3.org/2014/secondscreen/presentation-api/20140721/#PresentationSession_interface

 */
var CONNECTED = "connected";
var DISCONNECTED = "disconnected";
var RESUMED = "resumed";
var PresentationSessionState = [CONNECTED,DISCONNECTED,RESUMED];
var PresentationSession = function(delSession){
  var onmessage = null;
  var onstatechange = null;
  var self = this;
  delSession.onstatechange = function(){
    if (typeof onstatechange == "function") {
      onstatechange.call(null);
    };
  };
  delSession.onmessage = function(msg){
    if (typeof onmessage == "function") {
      onmessage.call(null,msg);
    };
  };
  Object.defineProperty(this, "state", {
    get: function () {
      return (delSession && delSession.state) || null;
    }
  });
  Object.defineProperty(this, "onmessage", {
    get: function () {
      return onmessage;
    },
    set: function(value){
      if (typeof value == "function" || value == null) {
        onmessage = value;
      };
    }
  });
  Object.defineProperty(this, "onstatechange", {
    get: function () {
      return onstatechange;
    },
    set: function(value){
      if (typeof value == "function" || value == null) {
        onstatechange = value;
      };
    }
  });

  Object.defineProperty(this, "postMessage", {
    get: function () {
      return function(msg){
        return delSession.postMessage(msg);
      };
    }
  });

  Object.defineProperty(this, "close", {
    get: function () {
      return function(){
        return delSession.close();
      };
    }
  });
};

var presentationSessionPostMessage = function(ds){
  return function(message){
               exec(/*successCallback*/Function, /*errorCallback*/Function, "Presentation", "presentationSessionPostMessage", [ ds._id, message ]);
  };
};

var presentationSessionClose = function(ds){
  return function(){
               exec(/*successCallback*/Function, /*errorCallback*/Function, "Presentation", "presentationSessionClose", [ ds._id ]);
  };
};

/** WebIDL: PresentEvent

  [Constructor(DOMString type, optional PresentEventInit eventInitDict)]
  interface PresentEvent : Event {
    readonly attribute PresentationSession session;
  };

  dictionary PresentEventInit : EventInit {
    PresentationSession session;
  };

  http://www.w3.org/2014/secondscreen/presentation-api/20140721/#PresentEvent_interface

 */

module.exports = new NavigatorPresentation();

