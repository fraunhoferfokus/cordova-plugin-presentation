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

#ifndef WebscreenViewController_h
#define WebscreenViewController_h

#import <UIKit/UIKit.h>
#import "PresentationSession.h"

@protocol WebscreenDelegate ;


@interface WebscreenViewController : UIViewController  <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, weak) id<WebscreenDelegate> delegate;
@property (nonatomic, strong)  NSString *sid;
@property (nonatomic, strong)  NSString *screenId;
@property (nonatomic, strong)  PresentationSession *session;

- (id)initWithSid:(NSString *)sid;
- (void)loadUrl:(NSString *)url;
- (void)close;

@end


@protocol WebscreenDelegate <NSObject>

- (void)webscreenReady: (NSString *)sid;
- (void)webscreenDidLoadUrl: (NSString *)sid;
- (void)webscreenDidClose: (NSString *)sid;

@end

#endif
