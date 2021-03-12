//
//  ExpressTaskFactory.swift
//  pangle_flutter
//
//  Created by my on 2021/3/12.
//

import Foundation

public final class ExpressTaskFactory: TaskFactory {
    public override func prepareTaskWithArguments(_ ad: ADCompatble, _ arguments: [String : Any?]) -> TaskCompatible {
        switch ad.category {
        case .spash:
            return ExpressSplashADTask(arguments, ad: ad)
        case .rewardVideo:
            return ExpressRewardVideoADTask(arguments, ad: ad)
        case .feed:
            return ExpressNativeADTask(arguments, ad: ad)
        case .interstitial:
            return IntersitialADTask(arguments, ad: ad)
        case .fullScreen:
            return ExpressFullScreenAdTask(arguments, ad: ad)
        case .unknown:
            return NoneTask()
        }
    }
}
