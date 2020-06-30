//
//  UpdateVersion.swift
//  CheckAppStoreUpdate_Sample
//
//  Created by Prabhat on 24/06/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

// MARK: INPORTANT!
/****************************************
 
 In your calss simple call this method
 
 class ViewController: UIViewController {

     override func viewDidLoad() {
         super.viewDidLoad()
 
         UpdateVersion.init().checkVersion(vc: self)
     }
 }
*******************************************/


import Foundation
import UIKit

class UpdateVersion: NSObject {
    
    func checkVersion(vc: UIViewController) {
        DispatchQueue.global().async {
            do {
                let update = try self.isUpdateAvailable()
                
                print("update",update)
                DispatchQueue.main.async {
                    if update{
                        self.popupUpdateDialogue(controller: vc);
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            print("version in app store", version,currentVersion);
            
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }
    
    func popupUpdateDialogue(controller: UIViewController){
        var versionInfo = ""
        do {
            versionInfo = try self.getAppStoreVersion()
        }catch {
            print(error)
        }
        
        
        let messageTitle =
        """
        Upgrade to latest version

        There is a newer version of the app with critical updates. Please upgrade the app before proceeding

        """
        
        
        
        let alertMessage =
        """

- Important update: if you still see issues after upgrading, Please uninstall and reinstall the app
- Fix for crash, when upgraded
- Stability and usability enhancements

"""
        
        let alert = UIAlertController(title: messageTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://apps.apple.com/us/app/shuni-bangla-audiobook/id1499605688"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let _ = UIAlertAction(title:"Skip this Version" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        // alert.addAction(noBtn)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func getAppStoreVersion() throws -> String {
        let url = URL(string: "https://apps.apple.com/us/app/shuni-bangla-audiobook/id1499605688")!
        let data = try Data(contentsOf: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            
            print(result)
            print("version in app store”, version, currentVersion");
            
            return version
        }
        
        // After debugging, it is directly coming out here but why I donot Know why ? I think this is not working (let data = try Data(contentsOf: url) ) .Kindly Help me
        
        throw VersionError.invalidResponse
    }
    
}

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}








