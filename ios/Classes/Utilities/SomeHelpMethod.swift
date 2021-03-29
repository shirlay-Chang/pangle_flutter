//
//  SomeHelpMethod.swift
//  ADManager
//
//  Created by my on 2021/3/24.
//

import UIKit

var currentViewController: UIViewController? {
    guard let _window = UIApplication.shared.delegate?.window else { return nil }
    var retViewController: UIViewController? = _window?.rootViewController
    
    if let _tabbarController = retViewController as? UITabBarController {
        retViewController = _tabbarController.selectedViewController
    }
    
    while let  _viewController = retViewController?.presentedViewController {
        retViewController = _viewController
    }
    
    if let _navigationController = retViewController as? UINavigationController {
        retViewController = _navigationController.viewControllers.last
    }
    
    return retViewController
}
