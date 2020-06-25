//
//  ViewController.swift
//  CheckAppStoreUpdate_Sample
//
//  Created by Prabhat on 24/06/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UpdateVersion.init().checkVersion(vc: self)
    }
    
}
