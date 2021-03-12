//
//  FullScreenAdTask.swift
//  pangle_flutter
//
//  Created by my on 2021/3/11.
//

import Foundation


public final class FullScreenAdTask: NSObject, TaskCompatible {

    let _ad: BUFullscreenVideoAd
    
    public var ad: ADCompatble

    public var identifier: String
    
    public var isCanceled: Bool = false
    
    private weak var delegate: TaskReumeResultDelegate?
    
    init(slotId: String, ad: ADCompatble) {
        let _ad = BUFullscreenVideoAd(slotID: slotId)
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

extension FullScreenAdTask: BUFullscreenVideoAdDelegate {
    public func fullscreenVideoAdVideoDataDidLoad(_ fullscreenVideoAd: BUFullscreenVideoAd) {
//        let vc = AppUtil.getVC()
//        fullscreenVideoAd.show(fromRootViewController: vc)
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func fullscreenVideoAdDidClose(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        self.delegate?.task(self, didCompleteWithData: nil)
    }
    
    public func fullscreenVideoAdDidClickSkip(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        let error = NSError(domain: "com.pange.full.screen.ad.task.skip.error", code: -1, userInfo: nil)
        self.delegate?.task(self, didCompleteWithError: error)
    }
    
    public func fullscreenVideoAd(_ fullscreenVideoAd: BUFullscreenVideoAd, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: error ?? NSError(domain: "com.pange.full.screen.ad.task.load.error", code: -1, userInfo: nil))
    }
    
    public func fullscreenVideoAdDidPlayFinish(_ fullscreenVideoAd: BUFullscreenVideoAd, didFailWithError error: Error?) {}
}

public final class ExpressFullScreenAdTask: NSObject, TaskCompatible {
    public var identifier: String
    
    public var isCanceled: Bool = false 
    
    public var ad: ADCompatble
    
    let _ad: BUNativeExpressFullscreenVideoAd
    
    private weak var delegate: TaskReumeResultDelegate?
    
    private var isSkipped: Bool = false
    
    init(_ args: [String: Any?], ad: ADCompatble) {
        let slotId: String = args["slotId"] as! String
        let _ad = BUNativeExpressFullscreenVideoAd(slotID: slotId)
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

extension ExpressFullScreenAdTask: BUNativeExpressFullscreenVideoAdDelegate {
    public func nativeExpressFullscreenVideoAdDidLoad(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
//            let vc = AppUtil.getVC()
//            fullscreenVideoAd.show(fromRootViewController: vc)
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func nativeExpressFullscreenVideoAdDidClose(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        if !isSkipped {
            self.delegate?.task(self, didCompleteWithData: nil)
        }
    }
    
    public func nativeExpressFullscreenVideoAdDidClickSkip(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        isSkipped = true
    }
    
    public func nativeExpressFullscreenVideoAdViewRenderSuccess(_ rewardedVideoAd: BUNativeExpressFullscreenVideoAd) {}
    
    public func nativeExpressFullscreenVideoAdDidDownLoadVideo(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {}
    
    public func nativeExpressFullscreenVideoAdViewRenderFail(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.ad.task.full.screen.express.ad.render.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpressFullscreenVideoAd(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.ad.task.full.screen.express.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpressFullscreenVideoAdDidPlayFinish(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, didFailWithError error: Error?) {}
}
