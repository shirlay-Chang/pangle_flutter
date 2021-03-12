//
//  ADManager.swift
//  pangle_flutter
//
//  Created by my on 2021/3/11.
//

import Foundation

public final class ADManager {
    
    public let `shared` = ADManager()
    
    private var factoryList: [TaskFactoryCategory: TaskFactoryCompatible] = [.default: DefaultTaskFactory(), .express: ExpressTaskFactory()]
    
    public func taskForName(_ name: String, arguments: [String: Any?], adDidLoad: ((Any?) -> Void)?, complete: ((Result<Any?, Error>) -> Void)?) -> TaskCompatible {
        return taskForAd(adForName(name, arguments: arguments), arguments: arguments, adDidLoad: adDidLoad, complete: complete)
    }
    
    enum LoadingType: Int {
        case unknown = -1
        case normal
        case preload
    }
    public func adForName(_ name: String, arguments: [String: Any?]) -> ADCompatble {
        let isExpress = arguments["isExpress"] as? Bool
        
        let _loadingType = arguments["loadingType"] as? Int
        let loadingType = LoadingType(rawValue: _loadingType.intValue) ?? .unknown
        switch loadingType {
        case .normal:
            return ADs.ad(name, isExpress: isExpress.boolValue)
        case .preload:
            return ADs.preloadAD(name, isExpress: isExpress.boolValue)
        default:
            return NoneAd()
        }
    }
    
    public func taskForAd(_ ad: ADCompatble, arguments: [String: Any?], adDidLoad: ((Any?) -> Void)?, complete: ((Result<Any?, Error>) -> Void)?) -> TaskCompatible {
        let taskFactory = taskFactoryForCategory(ad.taskFactoryCategory)
        return taskFactory.taskWithArguments(ad, arguments, adDidLoad, complete: complete)
    }
    
    private func taskFactoryForCategory(_ category: TaskFactoryCategory) -> TaskFactoryCompatible {
        return synchronizedOn(self, {
            guard let _factory = self.factoryList[category] else {
                fatalError("none register task factory for category \(category)")
            }
            return _factory
        })
    }
    
    public func register(_ category: TaskFactoryCategory, factory: TaskFactoryCompatible) {
        synchronizedOn(self) {
            self.factoryList[category] = factory
        }
    }
    
    public func unregister(_ category: TaskFactoryCategory) {
        synchronizedOn(self) {
            self.factoryList[category] = nil
        }
    }
}
