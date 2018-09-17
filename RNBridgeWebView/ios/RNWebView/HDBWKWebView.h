//
//  HDBWKWebView.h
//  HDB
//
//  Created by 张作华 on 2017/11/22.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <React/RCTViewManager.h>
@interface HDBWKWebView : WKWebView<WKNavigationDelegate,WKUIDelegate>
- (void)cleanCache;
- (void)postMessage:(NSString *)params;
@end
