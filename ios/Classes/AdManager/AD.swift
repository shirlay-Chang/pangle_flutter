//
//  AD.swift
//  pangle_flutter
//
//  Created by my on 2021/3/11.
//

import Foundation

public typealias TaskFactoryCategory = String

extension TaskFactoryCategory {
    static let `default` = "com.pangle.default.ad.task.factory.identifier"
    static let express = "com.pangle.express.ad.task.factory.identifier"
    static let none = ""
}

public enum LoadMethod {
    /// 预加载
    case preload
    /// 执行
    case immediately
}

public enum ADCategory: String {
    case spash = "loadSplashAd"
    case rewardVideo = "loadRewardedVideoAd"
    case feed = "loadFeedAd"
    case interstitial = "loadInterstitialAd"
    case fullScreen = "loadFullscreenVideoAd"
    case unknown
}

public protocol ADCompatble {
    var taskFactoryCategory: TaskFactoryCategory { get }
    
    var method: LoadMethod { get }
    
    var category: ADCategory { get }
}

public struct DefaultAD: ADCompatble {
    public var method: LoadMethod
    
    public var category: ADCategory
    
    public var taskFactoryCategory: TaskFactoryCategory {
        return .default
    }
    
    public init(method: LoadMethod, category: ADCategory) {
        self.method = method
        self.category = category
    }
}

public struct ExpressAd: ADCompatble {
    public var method: LoadMethod
    
    public var category: ADCategory
    
    public var taskFactoryCategory: TaskFactoryCategory {
        return .express
    }
    
    public init(method: LoadMethod, category: ADCategory) {
        self.method = method
        self.category = category
    }
}

public struct ADs {
    static func preloadAD(_ name: String, isExpress: Bool) -> ADCompatble {
        if isExpress {
            return ExpressAd(method: .preload, category: ADCategory(rawValue: name) ?? .unknown)
        } else {
            return DefaultAD(method: .preload, category: ADCategory(rawValue: name) ?? .unknown)
        }
    }
    
    static func ad(_ name: String, isExpress: Bool) -> ADCompatble {
        if isExpress {
            return ExpressAd(method: .immediately, category: ADCategory(rawValue: name) ?? .unknown)
        } else {
            return DefaultAD(method: .immediately, category: ADCategory(rawValue: name) ?? .unknown)
        }
    }
}

struct NoneAd: ADCompatble {
    static func preloadAD(_ name: String) -> NoneAd {
        return NoneAd()
    }
    
    static func ad(_ name: String) -> NoneAd {
        return NoneAd()
    }
    
    var taskFactoryCategory: TaskFactoryCategory {
        return .none
    }
    
    var method: LoadMethod {
        return .preload
    }
    
    var category: ADCategory {
        return .unknown
    }
}
