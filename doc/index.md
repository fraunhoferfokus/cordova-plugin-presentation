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
displays and use them for presenting web content. This implementtion is
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

After installation the plugin is available to the Cordova application
when the ```deviceready```has been fired.

## Properties available on controller page

- navigator.presentation.onavailablechange
- navigator.presentation.requestSession

## Properties available on presenting page

- navigator.presentation.onpresent

## navigator.presentation.onavailablechange

The availability monitoring for secondary screens begins when the page adds an event listener for the availablechange event on the navigator.presentation object. If there are already available screens when the controller page adds the first event listener for the event, the plugin synthesizes a single availablechange event to signal the availability.

    navigator.presentation.onavailablechange = onAvailableChangeCallback

The ```onavailablechange``` is available on the controller page only.

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

    presentation.onavailablechange = function(e) {
      if (e.available) {
        console.log("External display is available.");
      } else {
        console.log("External display not available.");
      }
    };


(more to come...)

