//
//  NativeExpressRewardAdTask.swift
//  pangle_flutter
//
//  Created by my on 2021/3/10.
//

import Foundation
import BUAdSDK

internal final class NativeExpressRewardAdTask: NSObject, BUNativeExpressRewardedVideoAdDelegate {
    
    let ad: BUNativeExpressRewardedVideoAd
    let loadingType: LoadingType
    var callback: (Result<Bool, Error>) -> Void
    var verify: Bool = false
    init(args: [String: Any?], loadingType: LoadingType, callback: @escaping (Result<Bool, Error>) -> Void) {
        let slotId: String = args["slotId"] as! String
        let userId: String = args["userId"] as? String ?? ""
        let rewardName: String? = args["rewardName"] as? String
        let rewardAmount: Int? = args["rewardAmount"] as? Int
        let extra: String? = args["extra"] as? String

        let model = BURewardedVideoModel()
        model.rewardName = rewardName
        model.rewardAmount = rewardAmount ?? 0
        model.extra = extra
        model.userId = userId
        
        self.ad = BUNativeExpressRewardedVideoAd(slotID: slotId, rewardedVideoModel: model)
        self.loadingType = loadingType
        self.callback = callback
        super.init()
        self.ad.delegate = self
    }
    
    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let preload = self.loadingType == .preload || self.loadingType == .preload_only
        if preload {
            self.callback(.success(false))
        } else {
            let vc = AppUtil.getVC()
            rewardedVideoAd.show(fromRootViewController: vc)
        }
    }
    
    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.callback(.success(self.verify))
    }
    
    func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        guard let error = error else { return }
        self.callback(.failure(error))
    }
    
    func nativeExpressRewardedVideoAdDidClickSkip(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
//        self.isSkipped = true
//        let error = NSError(domain: "skip", code: -1, userInfo: nil)
//        if rewardedVideoAd.didReceiveFail != nil {
//            rewardedVideoAd.didReceiveFail?(error)
//        } else {
//            self.fail?(error)
//        }
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let error = NSError(domain: "verify_fail", code: -1, userInfo: nil)
        self.callback(.failure(error))
//        if rewardedVideoAd.didReceiveFail != nil {
//            rewardedVideoAd.didReceiveFail?(error)
//        } else {
//            self.fail?(error)
//        }
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }
    
    func nativeExpressRewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {}
    
    func loadAdData() {
        self.ad.loadData()
    }
    
    func showAd(_ callback: @escaping (Result<Bool, Error>) -> Void) {
        self.callback = callback
        let vc = AppUtil.getVC()
        self.ad.show(fromRootViewController: vc)
    }
    
    deinit {
        print("--------------deinit-----------")
    }
}
