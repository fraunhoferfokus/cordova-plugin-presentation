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

#include <sys/types.h>
#include <sys/sysctl.h>

#import <Cordova/CDV.h>
#import "CDVPresentationPlugin.h"
#import "DevicePickerViewController.h"
#import "WebscreenViewController.h"
#import "PresentationSession.h"

@interface CDVPresentationPlugin () {}
    @property NSString* watchCallbackId;
    @property UIAlertView *alert;
    @property UINavigationController *navi;
    @property DevicePickerViewController *devicePickerViewController;
    @property NSMutableDictionary * sessions;
    @property NSMutableArray * screens;
    @property NSMutableDictionary * webscreens;
    @property NSString *defaultDisplayUrl;
    @property unsigned long screensAvailable;
    @property bool pickerShowing;
@end

@implementation CDVPresentationPlugin

- (void)pluginInitialize
{
    // You can listen to more app notifications, see:
    // http://developer.apple.com/library/ios/#DOCUMENTATION/UIKit/Reference/UIApplication_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40006728-CH3-DontLinkElementID_4

    // NOTE: if you want to use these, make sure you uncomment the corresponding notification handler

    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationWillChange) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    // Added in 2.3.0
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:CDVLocalNotification object:nil];

    // Added in 2.5.0
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];

    self.watchCallbackId = nil;
    self.screensAvailable = 0;
    self.alert = nil;
    self.navi = nil;
    self.pickerShowing = NO;

    self.sessions = [[NSMutableDictionary alloc ] init];
    self.webscreens = [[NSMutableDictionary alloc ] init];
    self.screens = [[NSMutableArray alloc ] init];
}

- (void) onOrientationWillChange
{
    NSLog(@"orient");
    //[self.webView sizeToFit ];
}

- (void)setDefaultDisplay:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Called setDefaultDisplay");

    // Add the requested URL to the session
    self.defaultDisplayUrl = [command.arguments objectAtIndex:0];

}

- (void)requestSession:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Called requestSession");
    // Create a new session immediately
    PresentationSession * newSession = [[PresentationSession alloc] initWithSid];
    newSession.delegate = self;

    // Add the requested URL to the session
    NSString* url = [command.arguments objectAtIndex:0];
    newSession.url = url;
    newSession.cid = command.callbackId;

    // Satore a ref to session
    [self.sessions setObject:newSession forKey:newSession.sid];

    // Return the session id immediately
    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [returnInfo setObject:newSession.sid forKey:@"id"];
    [self returnInfo:command.callbackId andReturn:returnInfo andKeepCallback:true];

    // Display an alert msg to user if no external screen is available now
    if (self.screensAvailable <= 0) {
        if( self.alert != nil) {
            [self.alert dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.alert = [[UIAlertView alloc] initWithTitle:@"Presentation"
                                                message:@"No screens available. Attach to one." delegate:self cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil, nil];
        [self.alert show];
    } else {
        // Show a picker view to the user for screen selection
        if(self.navi == nil) {
            if (!self.devicePickerViewController) {
                self.devicePickerViewController = [[DevicePickerViewController alloc] init];
                self.devicePickerViewController.pickerDelegate = self;
                self.navi = [[UINavigationController alloc] initWithRootViewController:self.devicePickerViewController];
            }
        }
        // The last caller of requestSession will get the picker result
        // TODO(mla): API spec needs clarification on this
        self.devicePickerViewController.sid = newSession.sid;

        if (!self.pickerShowing) {
            self.pickerShowing = YES;
            //[self.viewController.navigationController presentViewController:self.devicePickerViewController animated:YES completion:nil];

            [self.viewController presentViewController:self.navi animated:YES completion:nil];
        }
    }
}

- (void)returnInfo:(NSString*)callbackId andReturn:(NSMutableDictionary*)info andKeepCallback:(BOOL)keepCallback
{
    NSLog(@"Called returnInfo");
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
    [result setKeepCallbackAsBool:keepCallback];
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (void)addWatchAvailableChange:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Called addWatchAvailableChange");
    // Do we already listen?
    if(self.watchCallbackId == nil) {
        self.watchCallbackId = command.callbackId;
        [self addExternalScreenNotificationHandlers];
    } else {
        // Overwrite the old page wide handler
        self.watchCallbackId = command.callbackId;
    }

}

- (void)clearWatchAvailableChange:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Called clearWatchAvailableChange");
    self.watchCallbackId = nil;
    [self removeExternalScreenNotificationHandlers];
}

- (void)addExternalScreenNotificationHandlers
{
    NSLog(@"Called addExternalScreenNotificationHandlers");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // See
    // Multiple Display Programming Guide for iOS
    // https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/WindowAndScreenGuide/UsingExternalDisplay/UsingExternalDisplay.html
    [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];

    // Add all already connected displays
    for (UIScreen *newScreen in [UIScreen screens]) {
        if ([newScreen isEqual:[[UIScreen screens] objectAtIndex:0]] ) {
            continue;
        }
        [self addConnectedScreen:newScreen];
    }

    // TODO(mla): potentialy other discovery mechanisms here ...
}

- (void)removeExternalScreenNotificationHandlers
{
    NSLog(@"Called removeExternalScreenNotificationHandlers");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self
                      name:UIScreenDidConnectNotification object:nil];
    [center removeObserver:self
                      name:UIScreenDidDisconnectNotification object:nil];
}

- (void) addConnectedScreen:(UIScreen *)newScreen
{
    CGRect screenBounds = newScreen.bounds;
    NSLog(@"screen with, w: %f h: %f",screenBounds.size.width,screenBounds.size.height);
    self.screensAvailable++;

    NSString *screenId = [NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]];

    // Show the placeholder display
    UIWindow *secondWindow = [[UIWindow alloc] initWithFrame:newScreen.bounds];
    secondWindow.screen = newScreen;
    secondWindow.hidden = NO;

    WebscreenViewController * wvc = [[WebscreenViewController alloc] initWithSid:screenId];
    wvc.delegate = self;
    wvc.window = secondWindow;
    wvc.screenId = screenId;
    [self.screens addObject:wvc];

    // Update the picker
    [self.devicePickerViewController addScreen:wvc];

    //UINavigationController *unc =[[UINavigationController alloc] init];
    //unc.navigationBar.hidden=YES;
    secondWindow.rootViewController = wvc;//unc;
   // [secondWindow.rootViewController presentViewController:wvc animated:YES completion:nil];

    if(self.watchCallbackId != nil && self.screensAvailable > 0) {
        NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        [returnInfo setObject:[NSNumber numberWithBool:true] forKey:@"available"];
        [self returnInfo:self.watchCallbackId andReturn:returnInfo andKeepCallback:true];
    }
}


- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    NSLog(@"Called handleScreenDidConnectNotification");
    UIScreen *newScreen = [aNotification object];

    [self addConnectedScreen:newScreen];
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    NSLog(@"Called handleScreenDidDisconnectNotification");
    self.screensAvailable = (self.screensAvailable==0)?0:self.screensAvailable-1;

    // Update the picker and purge screen ref
    UIScreen *closingScreen = [aNotification object];
    for (WebscreenViewController * wvc in self.screens) {
        if ([wvc.window.screen isEqual:closingScreen]){
            [self.devicePickerViewController removeScreen:wvc];
            UIWindow * secondWindow = wvc.window;
            [secondWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
            if(![wvc.sid isEqual:wvc.screenId]){
                [self closeSession:wvc.sid];
                [self.webscreens removeObjectForKey:wvc.sid];
            }
            [wvc close];
            [self.screens removeObject:wvc];
            break;
        }
    }

    if(self.watchCallbackId != nil) {
        NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        [returnInfo setObject:[NSNumber numberWithBool:false] forKey:@"available"];
        [self returnInfo:self.watchCallbackId andReturn:returnInfo andKeepCallback:true];
    }
}

-(void)picker:(DevicePickerViewController *)controller didSelectScreen:(WebscreenViewController *)defaultwvc forSession:(NSString *)sid
{
    NSLog(@"Called picker");
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    self.pickerShowing = NO;

    // Store refs to screen and webscreen
    PresentationSession * ps = [self.sessions objectForKey:sid];
    if (ps){
        UIWindow *secondWindow=defaultwvc.window;
        if (secondWindow) {
            // Attach session id to the selected screen
            defaultwvc.sid = sid;

            WebscreenViewController * newwvc = [[WebscreenViewController alloc] initWithSid:sid];
            newwvc.delegate = self;
            newwvc.session = ps;
            [self.webscreens setObject:newwvc forKey:sid];

            secondWindow.rootViewController = newwvc;

//            // Hide the default display
//            [secondWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
//
//                //Now, finally, set up Webscreen and start the fun...
//
//                [secondWindow.rootViewController presentViewController:newwvc animated:YES completion:nil];
//
//            }];
        }
    }
}

- (void) webscreenReady:(NSString *)sid
{
    NSLog(@"Called webscreenReady");
    WebscreenViewController * wvc = [self.webscreens objectForKey:sid];
    PresentationSession * ps = [self.sessions objectForKey:sid];
    if (wvc && ps){
        // Webscreen is ready to load the url to be presented
        [wvc loadUrl:ps.url];
    } else {
        // Default display handling
        for (WebscreenViewController * defaultwvc in self.screens) {
            if ([defaultwvc.screenId isEqual:sid] ){
                [defaultwvc loadUrl:[NSString stringWithFormat:@"%@#%@",self.defaultDisplayUrl,[defaultwvc.screenId substringFromIndex:31]]];
                break;
            }
        }
    }
}

- (void) webscreenDidLoadUrl:(NSString *)sid
{
    NSLog(@"Called webscreenDidLoadUrl");
    // Do noting here, until the reciver has attached the onpresent handler
}

- (void) webscreenDidClose: (NSString *)sid
{
    NSLog(@"Called webscreenDidClose");
    [self closeSession:sid];
}

-(void)dismissPickerRequested:(DevicePickerViewController *)controller withSession:(NSString *)sessionId
{
    NSLog(@"Called dismissPickerRequested");
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    self.pickerShowing = NO;
}

- (void)loadedPicker
{
    NSLog(@"Called loadedPicker");

    // Fill the picker initially with available screens

        for (WebscreenViewController * wvc in self.screens) {
            [self.devicePickerViewController addScreen:wvc];
        }
}

- (void)presentationSessionPostMessage:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Called presentationSessionPostMessage");
    NSString* sid = [command.arguments objectAtIndex:0];
    NSString* msg = [command.arguments objectAtIndex:1];

    PresentationSession * ps = [self.sessions objectForKey:sid];
    if (ps){
        // Forward the message to the receiver
        if([ps.onmessage isObject]){
            [ps.onmessage callWithArguments:@[msg]];
        }
    }

}

- (void)presentationSessionClose:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Called presentationSessionClose");
    NSString* sid = [command.arguments objectAtIndex:0];
    [self closeSession:sid];
}

- (void)closeRequested:(NSString *)sid
{
    NSLog(@"Called closeRequested");
    [self closeSession:sid];
}

- (void)msgPosted:(NSString *)sid withMsg:(NSString *)msg
{
    PresentationSession * ps = [self.sessions objectForKey:sid];
    if (ps){
        // Url loaded on presentation side, so now notify the sender
        NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [returnInfo setObject:ps.sid forKey:@"id"];
        [returnInfo setObject:@"onmessage" forKey:@"eventType"];
        [returnInfo setObject:msg forKey:@"value"];
        [self returnInfo:ps.cid andReturn:returnInfo andKeepCallback:true];
    }
}

- (void)stateChanged:(NSString *)sid
{
    PresentationSession * ps = [self.sessions objectForKey:sid];
    if (ps){
        // Notify the receiver side
        if([ps.onstatechange isObject]){
            [ps.onstatechange callWithArguments:@[]];
        }

        // Notify the sender side
        NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [returnInfo setObject:ps.sid forKey:@"id"];
        [returnInfo setObject:@"onstatechange" forKey:@"eventType"];
        [returnInfo setObject:ps.state forKey:@"value"];
        [self returnInfo:ps.cid andReturn:returnInfo andKeepCallback:true];
    }
}

- (void)closeSession:(NSString *)sid
{
    WebscreenViewController * wvc = [self.webscreens objectForKey:sid];
    PresentationSession * ps = [self.sessions objectForKey:sid];

    if(ps) {
        if(![ps.state isEqual:@"disconnected"]){
            [ps setState:@"disconnected"];
            [self stateChanged:sid];
        }

        UIWindow *secondWindow;
        for (WebscreenViewController * defaultwvc in self.screens) {
            if ([defaultwvc.sid isEqual:sid]){
                defaultwvc.sid = defaultwvc.screenId;
                secondWindow = defaultwvc.window;
                secondWindow.rootViewController = defaultwvc;
                //[secondWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
                //    [secondWindow.rootViewController presentViewController:defaultwvc animated:YES completion:nil];
                //}];

                break;
            }
        }

        [self.sessions removeObjectForKey:sid];

        [wvc close];
        [self.webscreens removeObjectForKey:sid];
        // TODO(mla): check for better cleanup of the webscreen
    }
}

@end
