//
//  TTAdUtil.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter

public class PangleAdManager: NSObject {
    public static let shared = PangleAdManager()
    
    private var feedAdCollection: [String: BUNativeAd] = [:]
    // Splash Ad
    private var splashAdDelegate: BUSplashAdDelegate?
    // Rewarded Video Ad
    private var rewardVideoAdDelegate: BURewardedVideoAdDelegate?
    private var rewardedVideoAd: BURewardedVideoAd?
    // Feed Ad
    private var feedAdDelegate: BUNativeAdsManagerDelegate?
    private var feedAdManager: BUNativeAdsManager?
    
    public func setFeedAd(_ nativeAds: [BUNativeAd]) -> [String] {
        var feedAds: [String: BUNativeAd] = [:]
        for nativeAd in nativeAds {
            feedAds[String(nativeAd.hash)] = nativeAd
        }
        self.feedAdCollection.merge(feedAds, uniquingKeysWith: { _, last in last })
        let array: [String] = Array(feedAds.keys)
        return array
    }
    
    public func getFeedAd(_ key: String) -> BUNativeAd? {
        return self.feedAdCollection[key]
    }
    
    public func removeFeedAd(_ key: String) {
        self.feedAdCollection.removeValue(forKey: key)
    }
    
    public func initialize(_ appId: String, logLevel: Int?, coppa: UInt?, isPaidApp: Bool?) {
        BUAdSDKManager.setAppID(appId)
        
        if isPaidApp != nil {
            BUAdSDKManager.setIsPaidApp(isPaidApp!)
        }
        
        if logLevel != nil {
            BUAdSDKManager.setLoglevel(BUAdSDKLogLevel(rawValue: logLevel!)!)
        }
        
        if coppa != nil {
            BUAdSDKManager.setCoppa(coppa!)
        }
    }
    
    public func loadSplashAd(_ slotId: String, result: @escaping FlutterResult, tolerateTimeout: Double?, hideSkipButton: Bool?) {
        let frame = UIScreen.main.bounds
        let splashView = BUSplashAdView(slotID: slotId, frame: frame)
        self.splashAdDelegate = FLTSplashAd(result)
        splashView.delegate = self.splashAdDelegate
        if tolerateTimeout != nil {
            splashView.tolerateTimeout = tolerateTimeout!
        }
        
        if hideSkipButton != nil {
            splashView.hideSkipButton = hideSkipButton!
        }
        
        splashView.loadAdData()
        
        let keyWindow = UIApplication.shared.windows.first
        keyWindow?.rootViewController?.view.addSubview(splashView)
        splashView.rootViewController = keyWindow?.rootViewController
    }
    
    public func loadSplashAdComplete() {
        self.splashAdDelegate = nil
    }
    
    public func loadRewardVideoAd(_ slotId: String, result: @escaping FlutterResult, model: BURewardedVideoModel) {
//        if self.rewardedVideoAd?.isAdValid ?? false {
//            let keyWindow = UIApplication.shared.windows.first
//            self.rewardedVideoAd!.show(fromRootViewController: keyWindow!.rootViewController!)
//        } else {
//        }
        self.rewardedVideoAd = BURewardedVideoAd(slotID: slotId, rewardedVideoModel: model)
        self.rewardVideoAdDelegate = FLTRewardedVideoAd(result)
        self.rewardedVideoAd!.delegate = self.rewardVideoAdDelegate
        self.rewardedVideoAd!.loadData()
    }
    
    public func loadRewardedVideoAdComplete() {
        self.rewardVideoAdDelegate = nil
        self.rewardedVideoAd = nil
    }
    
    public func loadFeedAd(_ slotId: String, result: @escaping FlutterResult, tag: String, count: Int, imgSize: Int, isSupportDeepLink: Bool) {
        let nad = BUNativeAdsManager()
        let slot = BUAdSlot()
        slot.id = slotId
        slot.adType = .feed
        slot.position = .feed
        slot.isSupportDeepLink = isSupportDeepLink
        slot.imgSize = BUSize(by: BUProposalSize(rawValue: imgSize)!)
        nad.adslot = slot
        self.feedAdDelegate = FLTFeedAd(result, tag: tag)
        nad.delegate = self.feedAdDelegate
        self.feedAdManager = nad
        nad.loadAdData(withCount: 3)
    }
    
    public func loadFeedAdComplete() {
        self.feedAdManager = nil
        self.feedAdDelegate = nil
    }
}