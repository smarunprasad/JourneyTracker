//
//  ViewExtension.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 20/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import UIKit

var spinner : UIView?

extension UIView {
    
    //MARK - View
    func roundCorner(radius: CGFloat, borderColor color: UIColor = UIColor.white) {
        
        layer.cornerRadius = radius
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }
    
    func showLoadingIndicator() {
        
        let spinnerView = UIView.init(frame: self.bounds)
        spinnerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = CGPoint.init(x: spinnerView.bounds.midX , y: spinnerView.bounds.midY)
        activityIndicator.color = .white
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            self.addSubview(spinnerView)
        }
        
        spinner = spinnerView
    }
    
    func hideLoadingIndicator() {
        
        DispatchQueue.main.async {
            spinner?.removeFromSuperview()
            spinner = nil
        }
    }
}
