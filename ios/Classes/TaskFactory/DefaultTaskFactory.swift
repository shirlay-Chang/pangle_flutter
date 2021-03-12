//
//  DefaultTaskFactory.swift
//  pangle_flutter
//
//  Created by my on 2021/3/11.
//

import Foundation

public final class DefaultTaskFactory: TaskFactory {
    public override func prepareTaskWithArguments(_ ad: ADCompatble, _ arguments: [String : Any?]) -> TaskCompatible {
        switch ad.category {
        case .spash:
            return SplashADTask(arguments, ad: ad)
        case .rewardVideo:
            return RewardVideoADTask(arguments, ad: ad)
        case .feed:
            return NativeADTask(arguments, ad: ad)
        case .interstitial:
            return NoneTask()
        case .fullScreen:
            let slotId: String = arguments["slotId"] as! String
            return FullScreenAdTask(slotId: slotId, ad: ad)
        case .unknown:
            return NoneTask()
        }
    }
}
