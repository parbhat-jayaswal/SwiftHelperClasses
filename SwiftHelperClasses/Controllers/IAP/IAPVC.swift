//
//  IAPVC.swift
//  SwiftHelperClasses
//
//  Created by Prabhat on 16/07/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import UIKit

import StoreKit


class IAPVC: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var PRODUCT_ID = "PRODUCT_ID" //Get it from iTunes connect
    var SHARED_SECRET = "ff5a4xxxxxxxxxxxxx054e82c" //Get it from iTunes connect
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    
    //    @IBOutlet weak var lblPurchaseDone: UILabel!
    
    var loaderView: LoaderView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isPurchased = UserDefaults.standard.value(forKey: "Font_Purchased") as? Int
        if isPurchased == 1 {
        } else {
            self.fetchAvailableProducts()
        }
        
    }
    
    
    @IBAction func btnPurchaseOnClick(_ sender: UIButton) {
        if iapProducts.count != 0 {
            purchaseProduct(product: iapProducts[0])
        }
    }
    
    // MARK: - Restore purchases
    @IBAction func btnRestoreOnClick(_ sender: UIButton) {
        showLoaderView(with: "Restoring...")
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension IAPVC {
    
    // MARK: - Fetch all available IAP products which is created in iTunes connect.
    func fetchAvailableProducts() {
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            PRODUCT_ID
        )
        
        guard let identifier = productIdentifiers as? Set<String> else { return }
        productsRequest = SKProductsRequest(productIdentifiers: identifier)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        hideLoader()
        // TODO: Product is restored and make sure the functionality/availability of purchased product
        UserDefaults.standard.set(true, forKey: "isPurchased")
        self.present(Utilities().showAlertContrller(title: "Restore Success", message: "You've successfully restored your purchase!"), animated: true, completion: nil)
    }
    
    // MARK: - Make purchase of a product
    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments() }
    
    func purchaseProduct(product: SKProduct) {
        if self.canMakePurchases() {
            showLoaderView(with: "Purchasing...")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            print("Product to Purchase: \(product.productIdentifier)")
            productID = product.productIdentifier
        }
            // IAP Purchases disabled on the Device
        else{
            self.present(Utilities().showAlertContrller(title: "Oops!", message: "Purchases are disabled in your device!"), animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            let purchasingProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = purchasingProduct.priceLocale
            let price = numberFormatter.string(from: purchasingProduct.price)
            
            // Show description
            // btnPurchase.setTitle("Get " + purchasingProduct.localizedDescription + " for \(price!)", for: .normal)
        }
    }
    
    // MARK: - IAP payment queue
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    hideLoader()
                    
                    UserDefaults.standard.set(1, forKey: "Font_Purchased")
                    
                    if let userDefaults = UserDefaults(suiteName: "group.com.unwrapsolutions.presets") {
                        userDefaults.set(1, forKey: "Font_Purchased1")
                    }
                    
                    
                    if let paymentTransaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(paymentTransaction)
                    }
                    
                    if productID == PRODUCT_ID {
                        UserDefaults.standard.set(true, forKey: "isPurchased")
                        self.present(Utilities().showAlertContrller(title: "Purchase Success", message: "You've successfully purchased"), animated: true, completion: nil)
                    }
                    
                    
                case .failed:
                    hideLoader()
                    
                    
                    
                    UserDefaults.standard.setValue(0, forKey: "Font_Purchased")
                    
                    if let userDefaults = UserDefaults(suiteName: "group.com.unwrapsolutions.presets") {
                        userDefaults.set(0, forKey: "Font_Purchased1")
                    }
                    
                    
                    
                    if trans.error != nil {
                        self.present(Utilities().showAlertContrller(title: "Purchase failed!", message: trans.error!.localizedDescription), animated: true, completion: nil)
                        print(trans.error!)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    print("restored")
                    
                    
                    UserDefaults.standard.set(1, forKey: "Font_Purchased")
                    
                    if let userDefaults = UserDefaults(suiteName: "group.com.unwrapsolutions.presets") {
                        userDefaults.set(1, forKey: "Font_Purchased1")
                    }
                    
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default: break
                }
            }
        }
    }
    
    // MARK: - Show / Hide loader for purchase and restore
    func showLoaderView(with title:String) {
        loaderView = LoaderView.instanceFromNib()
        loaderView?.lblLoaderTitle.text = title
        loaderView?.frame = self.view.frame
        self.view.addSubview(loaderView!)
    }
    
    func hideLoader() {
        if loaderView != nil {
            loaderView?.removeFromSuperview()
        }
    }
}

class Utilities: NSObject {
    
    func showAlertContrller(title:String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        return alertController
    }
}
