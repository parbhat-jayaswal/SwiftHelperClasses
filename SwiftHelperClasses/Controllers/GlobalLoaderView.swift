//
//  GlobalLoaderView.swift
//  SwiftHelperClasses
//
//  Created by Prabhat on 21/11/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import Foundation
import UIKit

class GlobalLoaderView {
    static let shared = GlobalLoaderView()
    
    var load = UIAlertController()
    
    
    func loader(VC: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        VC.present(alert, animated: true, completion: nil)
        return alert
    }
    
    func stopLoader(loader : UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func show(vc: UIViewController) {
        load = loader(VC: vc)
    }
    
    func hide() {
        stopLoader(loader: load)
    }
    
}
