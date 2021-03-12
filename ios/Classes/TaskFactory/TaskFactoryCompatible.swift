//
//  ADTaskFactory.swift
//  pangle_flutter
//
//  Created by my on 2021/3/11.
//

import Foundation

public protocol TaskFactoryCompatible {
    func taskWithArguments(_ ad: ADCompatble, _ arguments: [String: Any?], _ adDidLoad: ((Any?) -> Void)?, complete: ((Result<Any?, Error>) -> Void)?) -> TaskCompatible
}

class NoneTask: TaskCompatible {
    var ad: ADCompatble = NoneAd()
    
    var identifier: String = "None"
    
    var isCanceled: Bool = false
    
    func cancel() {}
    
    func resume(_ delegate: TaskReumeResultDelegate) {
        delegate.task(self, didCompleteWithData: nil)
    }
    
    func retry() -> Bool {
        return false
    }
}

struct NoneTaskFactory: TaskFactoryCompatible {
    func taskWithArguments(_ ad: ADCompatble, _ arguments: [String : Any?], _ adDidLoad: ((Any?) -> Void)?, complete: ((Result<Any?, Error>) -> Void)?) -> TaskCompatible {
        return NoneTask()
    }
}

