//
//  FlutterMethod.swift
//  ADManager
//
//  Created by my on 2021/3/24.
//

import AppTrackingTransparency
import BUAdSDK
import Flutter
import Foundation
import PangleAd
import GeADManager

enum FlutterMethod {
    case sdkVersion
    case `init`
    case trackingAuthorizationStatus
    case requestTrackingAuthorizationStatus
    case loadSplashAd
    case loadFeedAd
    case loadInterstitialAd
    case loadFullscreenVideoAd
    case loadRewardedVideoAd

    var name: FlutterBridge.FlutterMethodCallName {
        switch self {
        case .sdkVersion:
            return "getSdkVersion"
        case .`init`:
            return "init"
        case .trackingAuthorizationStatus:
            return "getTrackingAuthorizationStatus"
        case .requestTrackingAuthorizationStatus:
            return "requestTrackingAuthorization"
        case .loadSplashAd:
            return "loadSplashAd"
        case .loadFeedAd:
            return "loadFeedAd"
        case .loadInterstitialAd:
            return "loadInterstitialAd"
        case .loadFullscreenVideoAd:
            return "loadFullscreenVideoAd"
        case .loadRewardedVideoAd:
            return "loadRewardedVideoAd"
        }
    }

    var implementation: FlutterBridge.FlutterMethodCallImplementation {
        switch self {
        case .sdkVersion:
            return { _ in sdkVersion }
        case .`init`:
            return { params in
                guard let appId = params["appId"] as? String else { fatalError("appId is nil") }
                return {
                    ADManager.shared.register(.default, factory: DefaultTaskFactory())
                    ADManager.shared.register(.express, factory: ExpressTaskFactory())
                    
                    initSdk(appId, logLevel: params["logLevel"] as? Int, coppa: params["coopa"] as? UInt, isPaidApp: params["isPaidApp"] as? Bool, result: $0)
                }
            }
        case .trackingAuthorizationStatus:
            return { _ in trackingAuthorizationStatus }
        case .requestTrackingAuthorizationStatus:
            return { _ in requestTrackingAuthorizationStatus }
        case .loadSplashAd:
            return { params in
                return { result in
                    
                    let slotId = params["slotId"] as! String
                    let frame = UIScreen.main.bounds
                    let tolerateTimeout = params["tolerateTimeout"] as? Double
                    let hideSkipButton = params["hideSkipButton"] as? Bool
                    
                    let defaultSplashAd = DefaultADs.splash(slotId: slotId,
                                                            frame: frame,
                                                            tolerateTimeout: tolerateTimeout,
                                                            hideSkipButton: hideSkipButton)
                    loadAd(defaultSplashAd, result: result)
                }
            }
        case .loadFeedAd:
            return { _ in { _ in }}
        case .loadInterstitialAd:
            return { params in
                return { result in
                    let slotId = params["slotId"] as! String
                    let width = params["width"] as! Double
                    let height = params["height"] as! Double
                    
                    let ad = ExpressADs.interstitial(slotId: slotId, width: width, height: height)
                    loadAd(ad, result: result)
                }
            }
        case .loadFullscreenVideoAd:
            return { params in
                return { result in
                    let ad = ExpressADs.fullScreen(slotId: params["slotId"] as! String)
                    loadAd(ad, result: result)
                }
            }
        case .loadRewardedVideoAd:
            return { params in
                return { result in
                    let ad: ADCompatble
                    let slotId = params["slotId"] as! String
                    let userId = params["userId"] as! String
                    let rewardName = params["rewardName"] as? String
                    let rewardAmount = params["rewardAmount"] as? Int
                    let extra = params["extra"] as? String

                    if let isExpress = params["isExpress"] as? Bool, isExpress {
                        ad = DefaultADs.rewardVideo(slotId: slotId, userId: userId, rewardName: rewardName, rewardAmount: rewardAmount, extra: extra)
                    } else {
                        ad = ExpressADs.rewardVideo(slotId: slotId, userId: userId, rewardName: rewardName, rewardAmount: rewardAmount, extra: extra)
                    }
                    loadAd(ad, result: result)
                }
            }
        }
    }

    func sdkVersion(_ result: @escaping FlutterResult) {
        result(BUAdSDKManager.sdkVersion)
    }

    func initSdk(_ appId: String, logLevel: Int? = nil, coppa: UInt? = nil, isPaidApp: Bool? = false, result: @escaping FlutterResult) {
        BUAdSDKManager.setAppID(appId)

        if let _isPaidApp = isPaidApp {
            BUAdSDKManager.setIsPaidApp(_isPaidApp)
        }

        if let _logLevel = logLevel, let _level = BUAdSDKLogLevel(rawValue: _logLevel) {
            BUAdSDKManager.setLoglevel(_level)
        }

        if let _coppa = coppa {
            BUAdSDKManager.setCoppa(_coppa)
        }

        result(nil)
    }

    func trackingAuthorizationStatus(_ result: @escaping FlutterResult) {
        if #available(iOS 14.0, *) {
            result(ATTrackingManager.trackingAuthorizationStatus.rawValue)
        } else {
            result(nil)
        }
    }

    func requestTrackingAuthorizationStatus(_ result: @escaping FlutterResult) {
        /// 适配App Tracking Transparency（ATT）
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                result(status.rawValue)
            })
        } else {
            result(nil)
        }
    }
    
//    /// 闪屏广告
//    func loadDefaultSplashAd(slotId: String, frame: CGRect = UIScreen.main.bounds, tolerateTimeout: Double?, hideSkipButton: Bool?, result: @escaping FlutterResult) {
//        let defaultSplashAd = DefaultADs.splash(slotId: slotId, frame: frame, tolerateTimeout: tolerateTimeout, hideSkipButton: hideSkipButton)
//        _ = ADManager.shared.request(defaultSplashAd, adDidLoad: { ad in
//            if let _ad = ad as? BUSplashAdView {
//                UIApplication.shared.delegate?.window??.addSubview(_ad)
//            }
//        }, complete: { result in
//            if case let .success(data) = result,
//               let userInfo = data as? [String: Any],
//               let ad = userInfo["ad"] as? BUSplashAdView {
//                ad.removeFromSuperview()
//            }
//        })
//    }
    
    /// 广告
    func loadAd(_ ad: ADCompatble, result: @escaping FlutterResult) {
        _ = ADManager.shared.request(ad, adDidLoad: {
            if let _ad = ad as? DefaultADs {
                handleDefaultAD(_ad, didLoadWith: $0, result: result)
            } else if let _ad = ad as? ExpressADs {
                handleExpressAd(_ad, didLoadWith: $0, result: result)
            } else {
                fatalError("not support ad \(ad)")
            }
        }, complete: {
            if let _ad = ad as? DefaultADs {
                handleDefaultAd(_ad, didCompleteWith: $0, callback: result)
            } else if let _ad = ad as? ExpressADs {
                handleExpressAd(_ad, didCompleteWith: $0, callback: result)
            } else {
                fatalError("not support ad \(ad)")
            }
        })
    }
    
    private func handleDefaultAD(_ ad: DefaultADs, didLoadWith data: Any?, result: @escaping FlutterResult) {
        switch ad {
        case .feed where data is [BUNativeExpressAdView]: break
//            let _data = data as! [BUNativeExpressAdView]
//            navigationController?.pushViewController(LoadFeedAdController(_data), animated: true)
        case .splash where data is BUSplashAdView:
            let _splashView = data as! BUSplashAdView
            UIApplication.shared.delegate?.window??.addSubview(_splashView)
            _splashView.rootViewController = currentViewController
        case .rewardVideo where data is BURewardedVideoAd:
            let _ad = data as! BURewardedVideoAd
            if let _viewController = currentViewController {
                _ad.show(fromRootViewController: _viewController)
            }
        default:
            fatalError("something wrong")
        }
    }
    
    private func handleExpressAd(_ ad: ExpressADs, didLoadWith data: Any?, result: @escaping FlutterResult) {
        switch ad {
        case .rewardVideo where data is BUNativeExpressRewardedVideoAd:
            let _ad = data as! BUNativeExpressRewardedVideoAd
            if let _viewController = currentViewController {
                _ad.show(fromRootViewController: _viewController)
            }
        case .feed:
            break
        case .interstitial where data is BUNativeExpressInterstitialAd:
            let _ad = data as! BUNativeExpressInterstitialAd
            if let _viewController = currentViewController {
                _ad.show(fromRootViewController: _viewController)
            }
        case .fullScreen where data is BUNativeExpressFullscreenVideoAd:
            let _ad = data as! BUNativeExpressFullscreenVideoAd
            if let _viewController = currentViewController {
                _ad.show(fromRootViewController: _viewController)
            }
        case .banner where data is BUNativeExpressBannerView: break
//            let _ad = data as! BUNativeExpressBannerView
//
//            view.addSubview(_ad)
        default:
            fatalError("not support ad \(ad)")
        }
    }
    
    private func handleDefaultAd(_ ad: DefaultADs, didCompleteWith result: Result<Any?, NSError>, callback: @escaping FlutterResult) {
        switch (ad, result) {
        case (.splash, let .success(data)) where data is [String: Any]:
            let userInfo = data as! [String: Any]
            callback(["code": 0, "message": userInfo["info"]])
        case (.rewardVideo, let .success(data)) where data is [String: Any]:
            let userInfo = data as! [String: Any]
            callback(["code": 0, "message": userInfo])
        case (_, let .failure(error)):
            callback(["code": -1, "message": error.localizedDescription])
        default:
            callback(["code": -1, "message": "not suppport ad \(ad)"])
        }
    }
    
    private func handleExpressAd(_ ad: ExpressADs, didCompleteWith result: Result<Any?, NSError>, callback: @escaping FlutterResult) {
        switch (ad, result) {
        case (.rewardVideo, let .success(data)) where data is [String: Any]:
            let userInfo = data as! [String: Any]
            callback(["code": 0, "verify": userInfo["verify"]])
        case (.fullScreen, let .success(data)) where data is [String: Any]:
            let userInfo = data as! [String: Any]
            if let isSkipped = userInfo["info"] as? Bool, isSkipped {
                return
            }
            callback(["code": 0])
        case (.interstitial, .success):
            callback(["code": 0])
        case (_, let .failure(error)):
            callback(["code": -1, "message": error.localizedDescription])
        default:
            callback(["code": -1, "message": "not suppport ad \(ad)"])
        }
    }
}
