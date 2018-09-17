/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View} from 'react-native';
import RNWkWebView from './RNWkWebView'

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
// /**
//  * postMessage  params必须为字符串类型
//  */
// postMessage = (params) => {
//     HDBWKWebViewManager.postMessage(findNodeHandle(this.WKWebView),params);
// };
// /**
//  * Reloads the current page. headers为object
//  */
// reload = (headers) => {
//     HDBWKWebViewManager.reload(findNodeHandle(this.WKWebView),headers);
// };
// /**
//  * Go back one page in the web view's history.
//  */
// goBack = () => {
//     HDBWKWebViewManager.goBack(findNodeHandle(this.WKWebView));
// };
// /**
//  * cleanCache
//  */
// cleanCache = () => {
//     HDBWKWebViewManager.cleanCache(findNodeHandle(this.WKWebView));
// };
export default class App extends Component<Props> {
  render() {
    return (
        <RNWkWebView source={{uri:'https://github.com/plimerence/react-native-Jsbridge-WebView',headers:{}}}
                     style={{flex:1}}
                     renderLoading={()=>{}}
                     onLoadStart={()=>{}}
                     onLoadFinish={()=>{}}
                     onMessage={()=>{}}
                     onLoadingError={()=>{}}
                     ref={(ref)=>{this.webView = ref}}
        />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
