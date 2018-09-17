//
//  HDBWKWebView.m
//  HDB
//
//  Created by 张作华 on 2017/11/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "HDBWKWebView.h"
#import "WebViewJavascriptBridge.h"


@interface HDBWKWebView ()
@property WebViewJavascriptBridge* bridge;
//保存一下h5传给我的callBack
@property (nonatomic, copy) RCTDirectEventBlock onNavigationStateChange;
@property (nonatomic, copy) RCTDirectEventBlock onLoadStart;
@property (nonatomic, copy) RCTDirectEventBlock onLoadFinish;
@property (nonatomic, copy)WVJBResponseCallback h5CallBackBlock;
@property (strong, nonatomic) UIProgressView *progressView;
@property (nonatomic, copy)NSString *token;
@property (nonatomic, copy) RCTDirectEventBlock onLoadingError;
@property (nonatomic, copy) RCTDirectEventBlock onMessage;
@end
@implementation HDBWKWebView
- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];// 先调用父类的initWithFrame方法
  if (self) {
    self.navigationDelegate = self;
    self.UIDelegate = self;
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    self.scrollView.scrollEnabled = NO;
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame),2)];
    _progressView.progressTintColor = [UIColor redColor];
   // [self addSubview:_progressView];

    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self];
    [_bridge setWebViewDelegate:self];
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) { // iOS系统版本 >= 9.0
    // [self cleanCache];
    };
    __weak typeof (self) weakSelf = self;
    [_bridge registerHandler:@"rhczbank_share" handler:^(id data, WVJBResponseCallback responseCallback) {
      if (weakSelf.onMessage){
        weakSelf.onMessage(data);
      }
    //  [weakSelf.wkWebViewEvent sendEventToRn:data];
      weakSelf.h5CallBackBlock = responseCallback;
//      if (_token && ![_token isEqualToString:@""]) {
//        self.h5CallBackBlock(_token);
//      }
      }];
     // [_bridge callHandler:@"callNativePage" data:@{ @"foo":@"before ready" }];
    //  [self renderButtons];
     // [self loadExamplePage];
  }
  return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
  if ([keyPath isEqual: @"estimatedProgress"] && object == self) {
    [self.progressView setAlpha:1.0f];
    [_progressView setProgress:self.estimatedProgress animated:YES];
    if(self.estimatedProgress >= 1.0f)
    {
      [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.progressView setAlpha:0.0f];
      } completion:^(BOOL finished) {
        [self.progressView setProgress:0.0f animated:NO];
      }];
    }
  }
  else {
  //  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}
- (void)cleanCache{
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
    NSSet *websiteDataTypes = [NSSet setWithArray:@[
                            WKWebsiteDataTypeDiskCache,
                            WKWebsiteDataTypeMemoryCache,
                            ]];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
  } else {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
  }
//  NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
//  NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
//  [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
//  }];
}
- (void)setSource:(NSDictionary *)source{
  NSURL *requestUrl = [NSURL URLWithString:source[@"uri"]];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestUrl];
  if ([source[@"headers"] isKindOfClass:[NSDictionary class]]){
    request.allHTTPHeaderFields = source[@"headers"];
  }
   [self loadRequest:request];
}
- (void)postMessage:(NSString *)params{
  if (self.h5CallBackBlock){
    self.h5CallBackBlock(params);
  }
}
- (void)setToken:(NSString*)token{
  if (token && ![token isEqualToString:@""]) {
     _token = token;
  }
}
- (NSMutableDictionary<NSString *, id> *)baseEvent
{
  NSMutableDictionary<NSString *, id> *event = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                 @"url": self.URL.absoluteString ?: @"",
                                                                                                 @"loading" : @(self.loading),
                                                                                                 @"title": self.title,
                                                                                                 @"canGoBack": @(self.canGoBack),
                                                                                                 @"canGoForward" : @(self.canGoForward),
                                                                                                 }];
  
  return event;
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  NSLog(@"webViewDidStartLoad");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSMutableDictionary<NSString *, id> *event = [self baseEvent];
  _onLoadFinish(event);
}
//存cookie
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//  NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//  NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//  for (NSHTTPCookie *cookie in cookies) {
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//  }
  decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
  NSURLRequest *request = navigationAction.request;
  NSURL* url = request.URL;
  if (_onLoadStart) {
      NSMutableDictionary<NSString *, id> *event = [self baseEvent];
      [event addEntriesFromDictionary: @{
                                         @"url": url.absoluteString,
                                         @"navigationType": @(navigationAction.navigationType)
                                         }];
      _onLoadStart(event);
  }
  decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
  if (_onLoadingError) {
    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
      return;
    }
    NSMutableDictionary *event = [NSMutableDictionary new];
    [event addEntriesFromDictionary:@{
                                      @"domain": error.domain,
                                      @"code": @(error.code),
                                      @"description": error.localizedDescription,
                                      }];
    _onLoadingError(event);
  }

}
- (void)callHandler:(id)sender {
  id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
  [_bridge callHandler:@"callH5Page" data:data responseCallback:^(id response) {
    NSLog(@"callH5Page responded: %@", response);
  }];
}
- (void)dealloc{
  [self cleanCache];
}

@end
