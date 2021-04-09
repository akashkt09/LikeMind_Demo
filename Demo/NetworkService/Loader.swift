//
//  Loader.swift
//  Appstudio
//
//  Created by Appstudio on 15/11/17.
//  Copyright © 2017 Appstudio. All rights reserved.
//

import Foundation
import Reachability
import SVProgressHUD

class Loader {
    
    // MARK: - Loading Indicator
    
    static let thickness = CGFloat(6.0)
    static let radius = CGFloat(22.0)
    
    class func showLoader(title: String = "Loading...") {
        
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.setRingThickness(thickness)
            SVProgressHUD.setRingRadius(radius)
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show(withStatus: "")
            }
        }
    }
    
    class func showLoaderWith(title: String) {
        
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.setRingThickness(thickness)
            SVProgressHUD.setRingRadius(radius)
            
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show()
            }
        }
    }
    
    class func showLoaderInView(title: String = "Loading...", view: UIView) {
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.setRingThickness(thickness)
            SVProgressHUD.setRingRadius(radius)
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show()
            }
        }
    }
    
    class func hideLoader() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    class func hideLoaderInView(view: UIView) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}
