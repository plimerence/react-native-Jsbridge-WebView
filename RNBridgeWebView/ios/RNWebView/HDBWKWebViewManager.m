//
//  RCTWebViewManager.m
//  HDB
//
//  Created by 张作华 on 2017/11/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "HDBWKWebViewManager.h"
#import "HDBWKWebView.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
@interface HDBWKWebViewManager()
@end
@implementation HDBWKWebViewManager
RCT_EXPORT_MODULE();
//  事件的导出，url对应webView加载所需要的url
RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary);

//RCT_EXPORT_VIEW_PROPERTY(postMessage, NSDictionary);
//  事件的导出，对应view中扩展的属性
RCT_EXPORT_VIEW_PROPERTY(onNavigationStateChange, RCTDirectEventBlock)
//
RCT_EXPORT_VIEW_PROPERTY(onLoadStart, RCTDirectEventBlock)
//
RCT_EXPORT_VIEW_PROPERTY(onLoadFinish, RCTDirectEventBlock)
//加载失败
RCT_EXPORT_VIEW_PROPERTY(onLoadingError, RCTDirectEventBlock)
//来自web的消息
RCT_EXPORT_VIEW_PROPERTY(onMessage, RCTDirectEventBlock)

RCT_EXPORT_METHOD(goBack:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, HDBWKWebView *> *viewRegistry) {
    HDBWKWebView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[HDBWKWebView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting RCTWKWebView, got: %@", view);
    } else {
      if ([view canGoBack])
      {
        [view goBack];
      }
    }
  }];
}
RCT_EXPORT_METHOD(reload:(nonnull NSNumber *)reactTag andHeaders:(NSDictionary *)headers)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, HDBWKWebView *> *viewRegistry) {
    HDBWKWebView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[HDBWKWebView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting RCTWKWebView, got: %@", view);
    } else {
      NSURL *requestUrl = view.URL;
      NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestUrl];
      if ([headers isKindOfClass:[NSDictionary class]]){
        request.allHTTPHeaderFields = headers;
      }
      [view loadRequest:request];
    }
  }];
}
RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)reactTag andParams:(NSString *)params)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, HDBWKWebView *> *viewRegistry) {
    HDBWKWebView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[HDBWKWebView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting RCTWKWebView, got: %@", view);
    } else {
      [view postMessage:params];
    }
  }];
}
RCT_EXPORT_METHOD(cleanCache:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, HDBWKWebView *> *viewRegistry) {
    HDBWKWebView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[HDBWKWebView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting RCTWKWebView, got: %@", view);
    } else {
      [view cleanCache];
    }
  }];
}
- (UIView *)view {
  HDBWKWebView *rnWebView = [HDBWKWebView new];
  return rnWebView;
}
@end
