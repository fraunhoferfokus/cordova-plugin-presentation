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

 //This JavaScript file implements the receiver part of the Presentation API as specified in the final report of the Second Screen Presentation Community Group http://www.w3.org/2014/secondscreen/presentation-api/20140721/. The code in this file will be minified and set as a constant in NavigatorPresentationJS.RECEIVER of the Cordova Presentation Android Plugin. After any changes in this file NavigatorPresentationJS.RECEIVER needs to be updated with the new minified version.
(function(delegate){
	/*
	 * NavigatorPresentation: for details please refer to http://www.w3.org/2014/secondscreen/presentation-api/20140721/#navigatorpresentation
	 */
	var NavigatorPresentation = function(){
		var onpresent = null;
		Object.defineProperty(this, 'onpresent', {
			get: function () {
				return onpresent;
			},
			set: function(value){
				if (typeof value == 'function' || typeof value == 'undefined' || value == null) {
					onpresent = value;
					if (onpresent) {
						delegate.onpresent = function(delSession){
							var session = new PresentationSession(delSession);
							var evt = new PresentEvent('PresentEvent',{session: session})
							onpresent.call(null,evt);
						};
					}
					else {
						delegate.onpresent = null;
					}
				};
			}
		});
	};
	
	/*
	 * PresentationSession states: for details please refer to http://www.w3.org/2014/secondscreen/presentation-api/20140721/#presentationsession
	 */
	var CONNECTED = 'connected';
	var DISCONNECTED = 'disconnected';
	var RESUMED = 'resumed';
	var PresentationSessionState = [CONNECTED,DISCONNECTED,RESUMED];
	/*
	 * PresentationSession: for details please refer to http://www.w3.org/2014/secondscreen/presentation-api/20140721/#presentationsession
	 */
	var PresentationSession = function(delSession){
		var onmessage = null;
		var onstatechange = null;
		var self = this;
		delSession.onstatechange = function(){
			if (typeof onstatechange == 'function') {
				onstatechange.call(null);
			};
		};
		delSession.onmessage = function(msg){
			if (typeof onmessage == 'function') {
				onmessage.call(null,msg);
			};
		};
		Object.defineProperty(this, 'state', {
			get: function () {
				return (delSession && delSession.state) || null;
			}
		});
		Object.defineProperty(this, 'onmessage', {
			get: function () {
				return onmessage;
			},
			set: function(value){
				if (typeof value == 'function' || value == null) {
					onmessage = value;
				};
			}
		});
		Object.defineProperty(this, 'onstatechange', {
			get: function () {
				return onstatechange;
			},
			set: function(value){
				if (typeof value == 'function' || value == null) {
					onstatechange = value;
				};
			}
		});

		Object.defineProperty(this, 'postMessage', {
			get: function () {
				return function(msg){
					return delSession.postMessage(msg);
				};
			}
		});

		Object.defineProperty(this, 'close', {
			get: function () {
				return function(){
					return delSession.close();
				};
			}
		});
	};
	
	/*
	 * PresentEvent: for details please refer to http://www.w3.org/2014/secondscreen/presentation-api/20140721/#presentevent
	 */
	var PresentEvent = function(type,eventInitDict){
		this.type = type;
		var session = eventInitDict && (eventInitDict.session || null);
		Object.defineProperty(this, 'session', {
			get: function () {
				return session;
			}
		});
	};
	
	/*
	 * navigator.presentation: for details please refer to http://www.w3.org/2014/secondscreen/presentation-api/20140721/#navigatorpresentation
	 */
	var presentation = new NavigatorPresentation();
	Object.defineProperty(window.navigator, 'presentation', {
		get: function () {
			return presentation;
		}
	});
})((function(jsInterface){
	var sessions = {};
	/*
	 * This function acts as delegate of all Presentation API calls to Android using the NavigatorPresentationJavascriptInterface Object
	 */ 
	var NavigatorPresentationDelegate = function(){
		var onpresent = null;
		Object.defineProperty(this, 'onpresent', {
			get: function () {
				return onpresent;
			},
			set: function(value){
				if (typeof value == 'function' || typeof value == 'undefined' || value == null) {
					onpresent = value;
					if (onpresent) {
						jsInterface.setOnPresent();
					}
				};
			}
		});
	};
	
	jsInterface.onsession = function(delSession){
		console.log('onsession '+delSession.id);
		sessions[delSession.id] = sessions[delSession.id] || delSession;
		var onmessage = null;
		var onstatechange = null;
		Object.defineProperty(delSession, 'onmessage', {
			get: function () {
				return onmessage;
			},
			set: function(value){
				if (typeof value == 'function' || typeof value == 'undefined' || value == null) {
					onmessage = value;
				};
			}
		});
		Object.defineProperty(delSession, 'onstatechange', {
			get: function () {
				return onstatechange;
			},
			set: function(value){
				if (typeof value == 'function' || typeof value == 'undefined' || value == null) {
					onstatechange = value;
				};
			}
		});

		Object.defineProperty(delSession, 'postMessage', {
			get: function () {
				return function(msg){
					return jsInterface.postMessage(delSession.id, msg);
				};
			}
		});

		Object.defineProperty(delSession, 'close', {
			get: function () {
				return function(){
					return jsInterface.close(delSession.id);
				};
			}
		});
		delegate.onpresent && delegate.onpresent(delSession);
	};
	
	jsInterface.onmessage = function(sessId,msg){
		console.log('onmessage '+msg);
		var delSession = sessions[sessId];
		if(delSession && delSession.onmessage){
			delSession.onmessage.call(null,msg);
		}
	};
	jsInterface.onstatechange = function(sessId,newState){
		console.log('onstatechange '+newState);
		var delSession = sessions[sessId];
		if(delSession){
			delSession.state = newState;
			if(delSession.onstatechange){
				delSession.onstatechange.call(null);
			}
		}
	};
	var delegate = new NavigatorPresentationDelegate();
	return delegate;
})(NavigatorPresentationJavascriptInterface));