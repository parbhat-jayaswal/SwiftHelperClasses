//
//  VerifyOTPVC.swift
//  Cigar
//
//  Created by Prabhat on 05/11/20.
//

import UIKit
import SwiftyJSON
import Alamofire

class VerifyOTPVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var otp1: UITextField!
    @IBOutlet weak var otp2: UITextField!
    @IBOutlet weak var otp3: UITextField!
    @IBOutlet weak var otp4: UITextField!
    
    var info: JSON?
    var userId: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func verifyAction(_ sender: DesignableButton) {
        
        
        if (otp1.text == "" || otp2.text == "" || otp3.text == "" || otp4.text == "") {
         print("Empty")
        } else {
            registerByApi(otp: otp1.text! + otp2.text! + otp3.text! + otp4.text!)
        }
    }


    @IBAction func termsAndConditionAction(_ sender: UIButton) {
        let story =  UIStoryboard.init(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        vc.URL =  TERM_CONDITION
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string.count > 0) {
            textField.text = string.substring(to: 1)
            
            if (textField == otp1) {
                if (otp1.text?.count == 1) {
                    otp2.becomeFirstResponder()
                }
            } else if (textField == otp2) {
                if (otp2.text?.count == 1) {
                    otp3.becomeFirstResponder()
                }
            } else if (textField == otp3) {
                if (otp3.text?.count == 1) {
                    otp4.becomeFirstResponder()
                }
            }
            else if (textField == otp4) {
                if (otp4.text?.count == 1) {
                    otp4.resignFirstResponder()
                }
            }
            
            /*
             else if (textField == _OTPField4) {
                 if ([_OTPField4.text length] == 1) {
                     [_OTPField5 becomeFirstResponder];
                 }
             } else if (textField == _OTPField5) {
                 if ([_OTPField5.text length] == 1) {
                     [_OTPField6 becomeFirstResponder];
                 }
             }
             */
            
            else {
                textField.resignFirstResponder()
            }
            
            return false;
        }
        
        return true;
    }
    
}



public extension String {

    //right is the first encountered string after left
    func between(_ left: String, _ right: String) -> String? {
        guard let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
        , leftRange.upperBound <= rightRange.lowerBound
            else { return nil }

        let sub = self.substring(from: leftRange.upperBound)
        let closestToLeftRange = sub.range(of: right)!
        return sub.substring(to: closestToLeftRange.lowerBound)
    }

//    var length: Int {
//        get {
//            return self.characters.count
//        }
//    }

    func substring(to : Int) -> String {
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return self.substring(to: toIndex)
    }

    func substring(from : Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return self.substring(from: fromIndex)
    }

    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }

    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }

    func lastIndexOfCharacter(_ c: Character) -> Int? {
        guard let index = range(of: String(c), options: .backwards)?.lowerBound else
        { return nil }
        return distance(from: startIndex, to: index)
    }
}



extension VerifyOTPVC {
    
    func registerByApi(otp: String) -> Void {
        
        Loader.shared.show(vc: self)
        
        guard let i = info, let id = userId else { return }

        let parameters = [
            "user_id":id,
            "otp":otp,
            "phone":i["phone"].stringValue,
            "email": i["email"].stringValue,
            "password": i["password"].stringValue,
            "device_type":"ios",
            "device_token": UserDefaults.standard.value(forKey: "FCM_TOKEN") ?? "12345",
        ]
        
        print(parameters)
        
        AF.request(VERIFY_OTP, method:.post, parameters:parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success (let res):
                Loader.shared.hide()
                self.exterateData(rss: JSON(res))
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    GlobalMethod.init().showAlert(title: APP_NAME, message: error.localizedDescription, vc: self)
                })
            }
        }
    }
    
    func exterateData(rss: JSON) -> Void {
        
        print("Server Responce => ", rss)
        
        if rss["status"].intValue == 200 {
            
            guard let userInfo = rss["profile"].dictionary
                else {
                Loader.init().hide()
                    return
            }

            UserDefaults.standard.setValue(rss["session_id"].stringValue, forKey: "session_id")
            UserDefaults.standard.setValue(userInfo["user_id"]?.stringValue, forKey: "User_Id")
            UserDefaults.standard.setValue(userInfo["user_name"]?.stringValue, forKey: "user_name")
            UserDefaults.standard.setValue(userInfo["email"]?.stringValue, forKey: "email")
            UserDefaults.standard.setValue(userInfo["profile_image"]?.stringValue, forKey: "profile_image")
            UserDefaults.standard.setValue(userInfo["phone"]?.stringValue, forKey: "phone")
            UserDefaults.standard.setValue(userInfo["dob"]?.stringValue, forKey: "dob")
            
            DispatchQueue.main.async(execute: {
                let story =  UIStoryboard.init(name: "Main", bundle: nil)
                let vc = story.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
        } else {
            DispatchQueue.main.async(execute: {
                
                self.otp1.text = ""
                self.otp2.text = ""
                self.otp3.text = ""
                self.otp4.text = ""
                
                GlobalMethod.init().showAlert(title: APP_NAME, message: rss["message"].string ?? "Please try after sometime!", vc: self)
            })
        }
    }
    
}
