//
//  FlutterBridge.swift
//  pangle_flutter
//
//  Created by my on 2021/3/23.
//

import Flutter
import Foundation

fileprivate let channelName = "nullptrx.github.io/pangle"

public final class FlutterBridge: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let bridge = FlutterBridge(channel, register: registrar)
        registrar.addMethodCallDelegate(bridge, channel: channel)
        
        let bannerViewFactory = BannerViewFactory(messenger: registrar.messenger())
        registrar.register(bannerViewFactory, withId: "nullptrx.github.io/pangle_bannerview")

        let feedViewFactory = FeedViewFactory(messenger: registrar.messenger())
        registrar.register(feedViewFactory, withId: "nullptrx.github.io/pangle_feedview")

        let splashViewFactory = SplashViewFactory(messenger: registrar.messenger())
        registrar.register(splashViewFactory, withId: "nullptrx.github.io/pangle_splashview")
        
        let method: [FlutterMethod] = [
            .`init`, .requestTrackingAuthorizationStatus, .sdkVersion, .trackingAuthorizationStatus,
            .loadFeedAd, .loadSplashAd, .loadFullscreenVideoAd, .loadInterstitialAd,
        ]
        
        method.forEach({ bridge.registerMethod($0.name, implementation: $0.implementation) })
    }

    public typealias FlutterMethodCallName = String
    public typealias FlutterMethodCallImplementation = ([String: Any?]) -> (@escaping FlutterResult) -> Void
    
    @Protected
    public private(set) var methodCallQueue: [FlutterMethodCallName: FlutterMethodCallImplementation] = [:]
    
    @Protected
    private var register: FlutterPluginRegistrar
    private let methodChannel: FlutterMethodChannel
    init(_ methodChannel: FlutterMethodChannel, register: FlutterPluginRegistrar) {
        self.methodChannel = methodChannel
        self.register = register
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        $methodCallQueue.read {
            let methodName = call.method
            if let implementation = $0[methodName], let arguments = call.arguments as? [String: Any?] {
                implementation(arguments)(result)
            }
        }
    }
    
    public func registerMethod(_ name: FlutterMethodCallName, implementation: @escaping FlutterMethodCallImplementation) {
        $methodCallQueue.write {
            $0[name] = implementation
        }
    }
    
    public func registerViewFactory(_ factory: FlutterPlatformViewFactory, with id: String) {
        $register.write {
            $0.register(factory, withId: id)
        }
    }
}

// public class SwiftPangleFlutterPlugin: NSObject, FlutterPlugin {
//    public static let kDefaultFeedAdCount = 3
//    public static let kDefaultRewardAmount = 1
//    public static let kDefaultSplashTimeout = 3000
//
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(name: "nullptrx.github.io/pangle", binaryMessenger: registrar.messenger())
//        let instance = SwiftPangleFlutterPlugin(channel)
//        registrar.addMethodCallDelegate(instance, channel: channel)
//
//        let bannerViewFactory = BannerViewFactory(messenger: registrar.messenger())
//        registrar.register(bannerViewFactory, withId: "nullptrx.github.io/pangle_bannerview")
//
//        let feedViewFactory = FeedViewFactory(messenger: registrar.messenger())
//        registrar.register(feedViewFactory, withId: "nullptrx.github.io/pangle_feedview")
//
//        let splashViewFactory = SplashViewFactory(messenger: registrar.messenger())
//        registrar.register(splashViewFactory, withId: "nullptrx.github.io/pangle_splashview")
//    }
//
//    private let methodChannel: FlutterMethodChannel
//
//    init(_ methodChannel: FlutterMethodChannel) {
//        self.methodChannel = methodChannel
//    }
//
//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        let instance = PangleAdManager.shared
//
//        switch call.method {
//        case "getSdkVersion":
//            result(BUAdSDKManager.sdkVersion)
//        case "init":
//            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
//            instance.initialize(args)
//            result(nil)
//        case "getTrackingAuthorizationStatus":
//            if #available(iOS 14.0, *) {
//                result(ATTrackingManager.trackingAuthorizationStatus.rawValue)
//            } else {
//                result(nil)
//            }
//        case "requestTrackingAuthorization":
//            /// 适配App Tracking Transparency（ATT）
//            if #available(iOS 14.0, *) {
//                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                    result(status.rawValue)
//                })
//            } else {
//                result(nil)
//            }
//        case "loadSplashAd":
//            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
//            instance.loadSplashAd(args, result: result)
//        case "loadRewardedVideoAd":
//            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
//            instance.loadRewardVideoAd(args, result: result)
//        case "loadFeedAd":
//            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
//            instance.loadFeedAd(args, result: result)
//        case "removeFeedAd":
//            let args: [String] = call.arguments as? [String] ?? []
//            var count = 0
//            for arg in args {
//                let success = instance.removeExpressAd(arg)
//                if success {
//                    count += 1
//                }
//            }
//            result(count)
//        case "loadInterstitialAd":
//            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
//            instance.loadInterstitialAd(args, result: result)
//        case "loadFullscreenVideoAd":
//            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
//            instance.loadFullscreenVideoAd(args, result: result)
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
// }
