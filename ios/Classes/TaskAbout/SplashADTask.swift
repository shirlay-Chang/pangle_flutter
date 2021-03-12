//
//  SplashADTask.swift
//  pangle_flutter
//
//  Created by my on 2021/3/12.
//

import Foundation

public final class SplashADTask: NSObject, TaskCompatible {
    public var identifier: String
    
    public var isCanceled: Bool = false 
    
    public var ad: ADCompatble
    
    let _ad: BUSplashAdView
    
    private weak var delegate: TaskReumeResultDelegate?
    
    init(_ args: [String: Any?], ad: ADCompatble) {
        let slotId: String = args["slotId"] as! String
        let tolerateTimeout: Double? = args["tolerateTimeout"] as? Double
        let hideSkipButton: Bool? = args["hideSkipButton"] as? Bool
        let frame = UIScreen.main.bounds
        let splashView = BUSplashAdView(slotID: slotId, frame: frame)
        if tolerateTimeout != nil {
            splashView.tolerateTimeout = tolerateTimeout!
        }
        if hideSkipButton != nil {
            splashView.hideSkipButton = hideSkipButton!
        }
        self.identifier = String(format: "%d", Unmanaged.passUnretained(splashView).toOpaque().hashValue)
        self._ad = splashView
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
        self._ad.loadAdData()
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func retry() -> Bool {
        return false
    }
}

extension SplashADTask: BUSplashAdDelegate {
    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
        self.delegate?.task(self, didCompleteWithData: "click")
    }
    
    public func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
        self.delegate?.task(self, didCompleteWithData: "skip")
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        self.delegate?.task(self, didCompleteWithData: "close")
    }
    
    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
}

public final class ExpressSplashADTask: NSObject, TaskCompatible {
    public var identifier: String
    
    public var isCanceled: Bool = false
    
    public var ad: ADCompatble
    
    let _ad: BUNativeExpressSplashView
    
    private weak var delegate: TaskReumeResultDelegate?
    
    init(_ args: [String: Any?], ad: ADCompatble) {
        let slotId: String = args["slotId"] as! String
        let tolerateTimeout: Double? = args["tolerateTimeout"] as? Double
        let hideSkipButton: Bool? = args["hideSkipButton"] as? Bool

        let expressArgs = args["expressSize"] as! [String: Double]
        let width = expressArgs["width"]!
        let height = expressArgs["height"]!
        let adSize = CGSize(width: width, height: height)
        let splashView = BUNativeExpressSplashView(slotID: slotId, adSize: adSize, rootViewController: UIViewController())
        if tolerateTimeout != nil {
            splashView.tolerateTimeout = tolerateTimeout!
        }
        if hideSkipButton != nil {
            splashView.hideSkipButton = hideSkipButton!
        }
        self.identifier = String(format: "%d", Unmanaged.passUnretained(splashView).toOpaque().hashValue)
        self._ad = splashView
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
        self._ad.loadAdData()
        self.delegate?.task(self, adDidLoad: _ad)
    }
    
    public func retry() -> Bool {
        return false
    }
}

extension ExpressSplashADTask: BUNativeExpressSplashViewDelegate {
    public func nativeExpressSplashViewDidClick(_ splashAdView: BUNativeExpressSplashView) {
        self.delegate?.task(self, didCompleteWithData: "click")
    }
    
    public func nativeExpressSplashViewDidClickSkip(_ splashAdView: BUNativeExpressSplashView) {
        self.delegate?.task(self, didCompleteWithData: "skip")
    }
    
    public func nativeExpressSplashViewDidClose(_ splashAdView: BUNativeExpressSplashView) {
        self.delegate?.task(self, didCompleteWithData: "timeover")
    }
    
    public func nativeExpressSplashView(_ splashAdView: BUNativeExpressSplashView, didFailWithError error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpressSplashViewRenderFail(_ splashAdView: BUNativeExpressSplashView, error: Error?) {
        self.delegate?.task(self, didCompleteWithError: (error as NSError?) ?? NSError(domain: "com.pangle.task.intersitial.ad.fail", code: -1, userInfo: nil))
    }
    
    public func nativeExpressSplashViewDidLoad(_ splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashViewRenderSuccess(_ splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashViewWillVisible(_ splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashViewCountdown(toZero splashAdView: BUNativeExpressSplashView) {}
    
    public func nativeExpressSplashViewFinishPlayDidPlayFinish(_ splashView: BUNativeExpressSplashView, didFailWithError error: Error) {}
    
    public func nativeExpressSplashViewDidCloseOtherController(_ splashView: BUNativeExpressSplashView, interactionType: BUInteractionType) {}
}
