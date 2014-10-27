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
 * AUTHORS: Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */

#ifndef CDVPresentationPlugin_h
#define CDVPresentationPlugin_h

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

#import "DevicePickerViewController.h"
#import "WebscreenViewController.h"
#import "PresentationSession.h"

@interface CDVPresentationPlugin : CDVPlugin <DevicePickerDelegate, WebscreenDelegate, PresentationSessionDelegate>

- (void)setDefaultDisplay:(CDVInvokedUrlCommand*)command;
- (void)requestSession:(CDVInvokedUrlCommand*)command;
- (void)addWatchAvailableChange:(CDVInvokedUrlCommand*)command;
- (void)clearWatchAvailableChange:(CDVInvokedUrlCommand*)command;
- (void)presentationSessionPostMessage:(CDVInvokedUrlCommand*)command;
- (void)presentationSessionClose:(CDVInvokedUrlCommand*)command;

@end

#endif
