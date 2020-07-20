//
//  ImageLoader.swift
//
//  Created by Prabhat on 25/05/16.
//  Copyright Prabhat. All rights reserved.
//




// MARK: INPORTANT!
/****************************************
 
Step -1
fileprivate let imageLoader = ImageLoader.sharedInstance
fileprivate var imageIndex : Int?

Step -2
fileprivate func loadImage(defaultImage : UIImage?, url : String?, imageView : UIImageView?){
    imageView?.image = defaultImage
    imageLoader.loadImage(url , token: { () -> (Int) in
        return (self.imageIndex ?? 0)
    }) { (success, image) in
        if(!success){
            return
        }
        imageView?.image = image
    }
}

Step -3
loadImage(defaultImage : #imageLiteral(resourceName: "Banner"), url : self.imageAds[index], imageView: cell.imageView)

*******************************************/

import UIKit

class ImageLoader: NSObject {
    var cache : [String : UIImage] = [:]

    override init(){
        super.init()
    }
    
    static let sharedInstance = ImageLoader()
    
    func loadImage(_ urlString : String?, token : @escaping ()->(Int) , completionBlock : @escaping (_ success : Bool, _ image : UIImage?)->()){
        
        let imageToken = token()
        loadImage(urlString) { (success, image) in
            if(!success){
                completionBlock(false, nil)
                return
            }
            if(imageToken != token()){
                completionBlock(false, nil)
                return
            }
            completionBlock(true, image)
            return
        }
    }
    
    fileprivate func loadImage(_ urlString : String?, completionBlock : @escaping (_ success : Bool, _ image : UIImage?)->()){
        
        guard let urlStringUW = urlString
            else{
                completionBlock(false, nil)
                return
        }
        
        if(urlStringUW == ""){
            completionBlock(false, nil)
            return
        }
        
        if(cache[urlStringUW] != nil){
            completionBlock(true, cache[urlStringUW])
            return
        }
        
        downloadImage(urlStringUW) { (success, image) in
            if(success){
                self.cache[urlStringUW] = image
                completionBlock(true, image)
                return
            }
            completionBlock(false, nil)
            return
        }
    }
    
    fileprivate func downloadImage(_ urlString : String?, completionBlock : @escaping (_ success : Bool, _ image : UIImage?)->()){
        
        guard let urlStringUW = urlString
        else{
            completionBlock(false, nil)
            return
        }
        
        
        guard let url = URL(string: urlStringUW)
            else{
            completionBlock(false, nil)
            return
        }
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 600.0)
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { (response, data, error) in
                DispatchQueue.main.async(execute: { 
                    if((error) != nil){
                       completionBlock(false, nil)
                        return
                    }
                    
                    guard let dataUW = data
                        else{
                            completionBlock(false, nil)
                            return
                    }
                    
                    let image = UIImage(data: dataUW)
                    
                    guard let imageUW = image
                        else{
                            completionBlock(false, nil)
                            return
                    }
                    
                    completionBlock(true, imageUW)
                })
        }
    }
    
}

