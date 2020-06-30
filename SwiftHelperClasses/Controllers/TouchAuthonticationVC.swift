//
//  ViewController.swift
//  SwiftHelperClasses
//
//  Created by Prabhat on 30/06/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import UIKit

class TouchAuthonticationVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var touchIDButton: UIButton!
    
    // MARK: - Properties
    let touchMe = BiometricIDAuth()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()
        
        switch touchMe.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "Touch_icon"),  for: .normal)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            self.touchIDLoginAction()
        } else {
            print("No Biomatric lock avaliable!")
            self.navigaetToHome()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func fingerPrintBtnAction(_ sender: UIButton) {
        touchIDLoginAction()
    }
    
    func touchIDLoginAction() {
        touchMe.authenticateUser() { [weak self] message in
            if let message = message {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                
                DispatchQueue.main.async {
                    self?.present(alertView, animated: true)
                }
                
            } else {
                self?.navigaetToHome()
                // self?.performSegue(withIdentifier: "dismissLogin", sender: self)
            }
        }
    }
    
    // MARK: Method to move into the application
    func navigaetToHome() {
        
    }

    


}

