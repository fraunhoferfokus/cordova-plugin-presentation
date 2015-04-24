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

#import "WebscreenViewController.h"
#import "JointContext.h"
#import "NavigatorPresentation.h"
#import "PresentationSession.h"

@interface WebscreenViewController () <JCWebViewDelegate>

 @property (strong) UIWebView *webView;
 @property (strong) JSContext *ctx;

@end

@implementation WebscreenViewController

- (id)initWithSid:(NSString *)sid
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.sid = sid;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Webscreen viewDidLoad");
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Webscreen viewDidAppear %@", NSStringFromCGSize(self.view.bounds.size));

    if(self.webView){
        return;
    }

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate=self;
    self.webView.hidden=NO;
    self.webView.autoresizesSubviews = YES;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView setScalesPageToFit:YES];
    [self.view addSubview:self.webView];

    [self.delegate webscreenReady: self.sid];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Display some error message in case the page to be presented cannot be accessed
    NSString *html = [NSString stringWithFormat:@"<html><body style=\"margin-top: 50%%; background-color: #ffffff; color: #dddddd; font-family: Helvetica; font-size: 48pt; text-align:center; word-wrap: break-word;\">%@<br><span style=\"font-size: 24pt;\">code: %ld</span></body></html>", error.localizedDescription, (long)error.code];

    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Called WebscreenViewController didReceiveMemoryWarning");
}

- (void)loadUrl:(NSString *)urlAddress
{
    NSLog(@"Called loadUrl: %@", urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    // TODO(mla): Second-Screen User_Agent?
    [requestObj setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36" forHTTPHeaderField:@"User_Agent"];
    [self.webView loadRequest:requestObj];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Called webViewDidFinishLoad");

    // Now we are good to go to send the deviceready event
    [self.ctx evaluateScript:@"document.dispatchEvent(new Event('deviceready'));"];

    [self.delegate webscreenDidLoadUrl:self.sid];
}

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    NSLog(@"Got context in Webscreen!");
    self.ctx = ctx;

    // Adds javascript bindings
    NavigatorPresentation * pres = [[NavigatorPresentation alloc] initWithSession:self.session];
    ctx[@"navigator"][@"presentation"] = pres;

    // Handles programmatic close request from JavaScript, e.g. window.close()
    ctx[@"close"] = ^ {
        NSLog(@"window close request!");
        [self.delegate webscreenDidClose: self.sid];
    };

}

- (void)closeRequested:(NSString *)sid
{
    [self.delegate webscreenDidClose: sid];
}

- (void)close
{
    [self.webView stopLoading];
    self.view = nil;
    self.webView = nil;
    self.sid = nil;
    self.delegate = nil;
    self.screenId = nil;
}

@end
