<!---
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
-->

# de.fhg.fokus.famium.presentation

This plugin provides an API that allows to access external presentation-type
displays and use them for presenting web content. This implementation is
compliant with the specification released by the
[Second Screen Presentation Community Group](http://www.w3.org/community/webscreens/)
in their
[Presentation API Final Report](http://www.w3.org/2014/secondscreen/presentation-api/20140721/).
This specification aims to make secondary displays such as a projector
or a connected TV available to the web and takes into account displays that
are attached using wired (HDMI, DVI or similar) and
wireless technologies (MiraCast, Chromecast, DLNA, AirPlay or similar).

For simplicity reasons the following terminology is assumed:

* controller page: the originating side where the presentation starts from
* presenting page: the terminating side/display where the presentation is shown

## Installation

    cordova plugin add de.fhg.fokus.famium.presentation

Note: After installation the plugin is available to the Cordova application
when the ```deviceready```has been fired. Before this event has not been fired there is not guarantee on the availability of this plugin and the Presentation API.

## Properties available on controller page

- navigator.presentation.onavailablechange
- navigator.presentation.requestSession

## Properties available on presenting page

- navigator.presentation.onpresent

## navigator.presentation.onavailablechange

The availability monitoring for secondary screens begins when the page adds an event listener for the availablechange event on the navigator.presentation object. If there are already available screens when the controller page adds the first event listener for the event, the plugin synthesizes a single availablechange event to signal the availability.

    navigator.presentation.onavailablechange = onAvailableChangeCallback

The ```onavailablechange``` handler will be invoked at the controller page only.

If a screen becomes available or unavailable the ```onAvailableChangeCallback``` callback function will be invoked with the following parameter:

* **availableChangeEvent**: Object. Derived from ```Event``` with additional boolean property ```available```
* **availableChangeEvent.available**: Boolean. ```true``` indicates that at least one external screen is available

Note: Setting the ```onavailablechange``` handler to ```null``` will request the plugin to stop watching for external display changes.

### Supported Platforms

- Android (Miracast, AV cable)
- iOS (Apple TV, AV cable)

### Android Quirks

Currently no known.

### iOS Quirks

Currently no known.

### Example

Get notified if an external display gets available:

    var presentation = navigator.presentation;

    presentation.onavailablechange = function(availableChangeEvent) {
      if (availableChangeEvent.available) {
        console.log("External display is available.");
      } else {
        console.log("External display not available.");
      }
    };


## navigator.presentation.requestSession

By calling navigator.presentation.requestSession(url), the script on the page tries to launch a presentation on a secondary screen. Based on the url argument, the UA looks for available screens, and presents a screen picker user interface to the user. Out of the list of available screens the user selects one item. If a new screen was selected, the UA connects to the selected screen, brings up a new window on the selected screen, starts to show the content denoted by the url argument, and the UA establishes a communication channel with this window.

    var session = navigator.presentation.requestSession(url)

The ```requestSession``` function is available on the controller page only. 

The ```url``` parameter may be full qualified url or relative path.  A call to the ```requestSession``` function immediately returns a ```PresentationSession``` object. This object has the following properties:

* **PresentationSession.state**: String. Read-only. With one of values { "connected", "disconnected" }
* **PresentationSession.postMessage**: Function. Can be called with single ```String``` message argument, to send the message to the presenting page (or to send the message to the controller page if the ```session``` was obtained at the presenting page)
* **PresentationSession.close**: Function. Can be called to close the session.
* **PresentationSession.onmessage**: Handler. If callback function is assigned then it will be invoked with ```String``` message as argument in case the sender side calls the ```postMessage``` function.
* **PresentationSession.onstatechange**: Handler. If callback function is assigned then it will be invoked without arguments in case the session state has changed.

### Supported Platforms

- Android (Miracast, AV cable)
- iOS (Apple TV, AV cable)

### Android Quirks

Currently no known.

### iOS Quirks

Currently no known.

### Example

Request a presentation session:

    var presentation = navigator.presentation;
    var session = presentation.requestSession("display.html");
    
    session.onstatechange = function() {
      switch (session.state) {
        case 'connected':
          session.postMessage(/*...*/);
          session.onmessage = function() { /*...*/ };
          break;
        case 'disconnected':
          console.log('Disconnected.');
          break;
      }
    };

## navigator.presentation.onpresent

When the content denoted by the url argument in the requestSession() example above is loaded, the page on the presentation screen receives a PresentEvent, with a session property representing the session. This session is a similar object as in the first example. Here, its initial state is "connected", which means we can use it to communicate with the opener page using postMessage() and onmessage.

    navigator.presentation.onpresent = onPresentCallback

The ```onpresent``` handler will be invoked at the presenting page only.

If the session is set up the ```onPresentCallback``` callback function will be invoked with the following parameter:

* **presentEvent**: Object. Derived from ```Event``` with additional boolean property ```session``` 
* **presentEvent.session**: Object. With the type ```PresentationSession``` with the same interface as described in ```navigator.presentation.requestSession```

### Supported Platforms

- Android (Miracast, AV cable)
- iOS (Apple TV, AV cable)

### Android Quirks

Currently no known.

### iOS Quirks

Currently no known.

### Example

Register for the PresentEvent on the presenting page:

    navigator.presentation.onpresent = function(e) {
      // Communicate with controller page.
      e.session.postMessage("a message.");
      e.session.onmessage = function(msg) {/*...*/};

      e.session.onstatechange = function() {
        switch (this.state) {
          case "disconnected":
            // Handle disconnection from controller page.
        }
      };
    };


