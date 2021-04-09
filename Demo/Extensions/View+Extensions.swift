//
//  View+Extensions.swift
//  Demo
//
//  Created by Akash on 09/04/21.
//

import Foundation
import UIKit


extension UIView {
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        }
        
        set(newOrigin) {
            self.frame.origin = newOrigin
        }
    }
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        
        set(newSize) {
            self.frame.size = newSize
        }
    }
    
    public var width: CGFloat {
         get {
             return self.size.width
         }
         
         set(newWidth) {
             var frame = self.frame
             frame.size.width = newWidth
             self.frame = frame
         }
     }
     
     public var height: CGFloat {
         get {
             return self.size.height
         }
         
         set(newHeight) {
             var frame = self.frame
             frame.size.height = newHeight
             self.frame = frame
         }
     }
    
    
    func roundCorners() {
        self.layer.cornerRadius = self.height/2
        self.layer.masksToBounds = true
    }
    
    func roundCornersWithRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    
}

enum Storyboards: String {
    case Main
}


extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: Storyboards) -> Self {
        
        return appStoryboard.viewController(self)
    }
}

extension Storyboards{
    var instance : UIStoryboard {
           
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    func viewController<T : UIViewController>(_ viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        
        return instance.instantiateInitialViewController()
    }
    
}
