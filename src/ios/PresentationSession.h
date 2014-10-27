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

#ifndef PresentationSession_h
#define PresentationSession_h

#import <JavaScriptCore/JavaScriptCore.h>

@protocol PresentationSessionDelegate;

@protocol JS_PresentationSession <JSExport>
    @property (readonly) NSString *state;
    - (void)postMessage :(NSString *) message;
    - (void)close;
    @property (nonatomic, strong) JSValue *onmessage;
    @property (nonatomic, strong) JSValue *onstatechange;
@end

@interface PresentationSession : NSObject <JS_PresentationSession>

    @property (nonatomic, strong) NSString * sid;
    @property (nonatomic, strong) NSString * cid;
    @property (nonatomic, strong) NSString * url;
    @property (nonatomic, weak) id<PresentationSessionDelegate> delegate;

    - (id)initWithSid;
    - (id)initWithSid:(NSString*)sid;
    - (void)setState:(NSString*)state;

    @property (readonly) NSString *state;
    - (void)postMessage :(NSString *) message;
    - (void)close;
    @property (nonatomic, strong) JSValue *onmessage;
    @property (nonatomic, strong) JSValue *onstatechange;

@end

@protocol PresentationSessionDelegate <NSObject>

- (void)closeRequested: (NSString *)sid;
- (void)msgPosted: (NSString *)sid withMsg:(NSString *)msg;
- (void)stateChanged: (NSString *)sid;

@end

#endif
