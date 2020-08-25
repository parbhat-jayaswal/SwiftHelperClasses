//
//  NotificationCenterObserver.swift
//  SwiftHelperClasses
//
//  Created by Prabhat on 25/08/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {

    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowForResizing), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideForResizing), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }

    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }


}


extension UIViewController {
     func initize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.funName), name: .name, object: nil)
    }
    
    
    @objc func funName(notification: NSNotification) -> Void {
        
    }

    
    func postMethod() {
        NotificationCenter.default.post(name: .name, object: nil)
    }

}

extension Notification.Name {
    
    static let name = Notification.Name("name")

}
