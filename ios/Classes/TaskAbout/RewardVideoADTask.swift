//
//  RewardVideoADTask.swift
//  pangle_flutter
//
//  Created by my on 2021/3/12.
//

import Foundation

public final class RewardVideoADTask: NSObject, TaskCompatible {
    public var identifier: String
    
    public var isCanceled: Bool = false 
    
    public var ad: ADCompatble
    
    let _ad: BURewardedVideoAd
    
    private weak var delegate: TaskReumeResultDelegate?
    
    private var verify: Bool = false
    
    init(_ args: [String: Any?], ad: ADCompatble) {
        let slotId: String = args["slotId"] as! String
        let userId: String = args["userId"] as? String ?? ""
        let rewardName: String? = args["rewardName"] as? String
        let rewardAmount: Int? = args["rewardAmount"] as? Int
        let extra: String? = args["extra"] as? String
        let model = BURewardedVideoModel()
        model.userId = userId
        if rewardName != nil {
            model.rewardName = rewardName
        }
        if rewardAmount != nil {
            model.rewardAmount = rewardAmount!
        }
        if extra != nil {
            model.extra = extra
        }
        let _ad = BURewardedVideoAd(slotID: slotId, rewardedVideoModel: model)
        self.identifier = String(format: "%d", Unmanaged.passUnretained(_ad).toOpaque().hashValue)
        self._ad = _ad
        self.ad = ad
        super.init()
        self._ad.delegate = self
    }
    
    public func cancel() {
        guard !isCanceled else { return }
        isCanceled = true
    }

    public func resume(_ delegate: TaskReumeResultDelegate) {
        self.delegate = delegate
        self._ad.loadData()
    }
    
    public func retry() -> Bool {
        return false
    }
}

extension RewardVideoADTask: BURewardedVideoAdDelegate {
    public func rewardedVideoAdVideoDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
//            let vc = AppUtil.getVC()
//            rewardedVideoAd.show(fromRootViewController: vc)
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func rewardedVideoAdDidClose(_ rewardedVideoAd: BURewardedVideoAd) {
        self.delegate?.task(self, didCompleteWithData: self.verify)
    }
    
    public func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func rewardedVideoAdDidClickSkip(_ rewardedVideoAd: BURewardedVideoAd) {}
    
    public func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BURewardedVideoAd) {
        self.delegate?.task(self, didCompleteWithError: NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }
    
    public func rewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {}
}

public final class ExpressRewardVideoADTask: NSObject, TaskCompatible {
    public var identifier: String
    
    public var isCanceled: Bool = false
    
    public var ad: ADCompatble
    
    let _ad: BUNativeExpressRewardedVideoAd
    
    private weak var delegate: TaskReumeResultDelegate?
    
    private var verify: Bool = false
    
    init(_ args: [String: Any?], ad: ADCompatble) {
        let slotId: String = args["slotId"] as! String
        let userId: String = args["userId"] as? String ?? ""
        let rewardName: String? = args["rewardName"] as? String
        let rewardAmount: Int? = args["rewardAmount"] as? Int
        let extra: String? = args["extra"] as? String
        let model = BURewardedVideoModel()
        
        model.userId = userId
        if rewardName != nil {
            model.rewardName = rewardName
        }
        if rewardAmount != nil {
            model.rewardAmount = rewardAmount!
        }
        if extra != nil {
            model.extra = extra
        }
        let _ad = BUNativeExpressRewardedVideoAd(slotID: slotId, rewardedVideoModel: model)
        self.identifier = String(format: "%d", Unmanaged.passUnretained(_ad).toOpaque().hashValue)
        self._ad = _ad
        self.ad = ad
        super.init()
        self._ad.delegate = self
    }
    
    public func cancel() {
        guard !isCanceled else { return }
        isCanceled = true
    }

    public func resume(_ delegate: TaskReumeResultDelegate) {
        self.delegate = delegate
        self._ad.loadData()
    }
    
    public func retry() -> Bool {
        return false
    }
}

extension ExpressRewardVideoADTask: BUNativeExpressRewardedVideoAdDelegate {
    public func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
//            let vc = AppUtil.getVC()
//            rewardedVideoAd.show(fromRootViewController: vc)
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.delegate?.task(self, didCompleteWithData: self.verify)
    }
    
    public func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpressRewardedVideoAdDidClickSkip(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {}
    
    public func nativeExpressRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.delegate?.task(self, didCompleteWithError: NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }
    
    public func nativeExpressRewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {}
}
