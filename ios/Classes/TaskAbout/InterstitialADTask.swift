//
//  InterstitialADTask.swift
//  pangle_flutter
//
//  Created by my on 2021/3/12.
//

import Foundation
public final class IntersitialADTask: NSObject, TaskCompatible {
    public var identifier: String
    
    public var isCanceled: Bool = false 
    
    public var ad: ADCompatble
    
    let _ad: BUNativeExpressInterstitialAd
    
    private weak var delegate: TaskReumeResultDelegate?
    
    private var isSkipped: Bool = false
    
    init(_ args: [String: Any?], ad: ADCompatble) {
        let slotId: String = args["slotId"] as! String
        let expressArgs = args["expressSize"] as! [String: Double]
        let width = expressArgs["width"]!
        let height = expressArgs["height"]!
//        let width = Double(UIScreen.main.bounds.width) * 0.9
//        let height = width / Double(size.width) * Double(size.height)
        let adSize = CGSize(width: width, height: height)
        let _ad = BUNativeExpressInterstitialAd(slotID: slotId, adSize: adSize)
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

extension IntersitialADTask: BUNativeExpresInterstitialAdDelegate {
    public func nativeExpresInterstitialAdRenderSuccess(_ interstitialAd: BUNativeExpressInterstitialAd) {
//        let vc = AppUtil.getVC()
//        interstitialAd.show(fromRootViewController: vc)
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func nativeExpresInterstitialAd(_ interstitialAd: BUNativeExpressInterstitialAd, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpresInterstitialAdRenderFail(_ interstitialAd: BUNativeExpressInterstitialAd, error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpresInterstitialAdDidClose(_ interstitialAd: BUNativeExpressInterstitialAd) {
        self.delegate?.task(self, didCompleteWithData: nil)
    }
}
