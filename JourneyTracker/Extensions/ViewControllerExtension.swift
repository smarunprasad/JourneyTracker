//
//  ViewControllerExtension.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 17/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    //MARK: UIAlert Controller
    func showAlert(title: String, message: String, OkButtonBlock: @escaping () -> Void, cancelTitle: String? = nil, cancelBlock: (() -> Void)? = nil ) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: Constants.Keys.ok, style: .default) { (_) in
            OkButtonBlock()
        }
        alert.addAction(okAction)
        
        if let cancel = cancelTitle {
            let cancelAction = UIAlertAction.init(title: cancel, style: .cancel) { (_) in
                cancelBlock?()
            }
            alert.addAction(cancelAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}
