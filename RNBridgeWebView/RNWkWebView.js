/**
 * Created by zhangzuohua on 2018/6/20.
 */

import React, { Component } from 'react';
import {
    Platform,
    StyleSheet,
    Text,
    View,
    FlatList,
    NativeModules,
    NativeEventEmitter,
    ViewPropTypes,
    requireNativeComponent,
    UIManager,
    findNodeHandle
} from 'react-native';
var PropTypes = require('prop-types');
const HDBWKWebViewManager = NativeModules.HDBWKWebViewManager;
const HDBWebView = requireNativeComponent('HDBWKWebView',RNWkWebView, {
    propTypes: {
        ...ViewPropTypes,
        source:PropTypes.object, // 格式为{uri:'',headers:{}}
        onNavigationStateChange:PropTypes.func,
        onLoadingError:PropTypes.func,
        onMessage:PropTypes.func,
        onLoadFinish:PropTypes.func,
        onLoadStart:PropTypes.func,
    },
});
export default class RNWkWebView extends Component{
    static navigationOptions = {
        header:null
    };
    static propTypes = {
        source: PropTypes.oneOfType(
            PropTypes.shape({
                /*
                 * The URI to load in the `WebView`. Can be a local or remote file.
                 */
                uri: PropTypes.string,
                /*
                 * The HTTP Method to use. Defaults to GET if not specified.
                 * NOTE: On Android, only GET and POST are supported.
                 */
                method: PropTypes.string,
                /*
                 * Additional HTTP headers to send with the request.
                 * NOTE: On Android, this can only be used with GET requests.
                 */
                headers: PropTypes.object,
            })),
        /**
         * Function that returns a view to show if there's an error.
         */
        onLoadingError: PropTypes.func, // view to show if there's an error
        onRenderLoading: PropTypes.func,
        onNavigationStateChange: PropTypes.func,//
        onMessage: PropTypes.func,
        style: ViewPropTypes.style,
        /**
         * Function that is invoked when the `WebView` starts loading.
         */
        onLoadStart: PropTypes.func,
        onLoadFinish:PropTypes.func,

    }
    constructor(props){
        super(props);
        this.state = {
            loading:true
        }

    }
    componentDidMount() {
    }
    /**
     * postMessage  params必须为字符串类型
     */
    postMessage = (params) => {
        HDBWKWebViewManager.postMessage(findNodeHandle(this.WKWebView),params);
    };
    /**
     * Reloads the current page. headers为object
     */
    reload = (headers) => {
        HDBWKWebViewManager.reload(findNodeHandle(this.WKWebView),headers);
    };
    /**
     * Go back one page in the web view's history.
     */
    goBack = () => {
        HDBWKWebViewManager.goBack(findNodeHandle(this.WKWebView));
    };
    /**
     * cleanCache
     */
    cleanCache = () => {
        HDBWKWebViewManager.cleanCache(findNodeHandle(this.WKWebView));
    };
    onLoadFinish = (event) =>{
        this.props.onLoadFinish && this.props.onLoadFinish(event);
        this.setState({loading:false});
    }
    render() {
        let loadingView = null;
        if (this.state.loading && this.props.renderLoading){
            loadingView = this.props.renderLoading &&  this.props.renderLoading();
        }
        const webView =  <HDBWebView
            style={{...this.props.style}}
            source={this.props.source}
            onLoadingError={this.props.onLoadingError}
            onMessage={this.props.onMessage}
            onLoadFinish={this.onLoadFinish}
            onLoadStart={this.props.onLoadStart}
            ref={(ref)=>{this.WKWebView = ref}}
        />
        return (
            <View style={{flex:1}}>
                {webView}
                {loadingView}
            </View>
        );
    }
}

module.exports = RNWkWebView;

