//
//  ExploreSearchVC.swift
//  Gift3r
//
//  Created by Rsoft on 20/08/19.
//  Copyright © 2019 Rsoft. All rights reserved.


import UIKit
import GoogleMaps
import FittedSheets
import GooglePlaces
import CoreLocation

import IQKeyboardManagerSwift

class ExploreSearchVC: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var categorySearch_field: DesignableTextField!
    @IBOutlet weak var locationSearch_field: DesignableTextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var swipeView: DesignableView!
    
    @IBOutlet weak var main_whiteView: UIView!
    @IBOutlet weak var base_view: DesignableView!
    @IBOutlet weak var business_image: DesignableImageView!
    
    private var markerList = [GMSMarker]()
    private var infoWindow:UIView?
    
    @IBOutlet weak var HomeView: DesignableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var giftcard_btn: DesignableButton!
    @IBOutlet weak var heart_btn: UIButton!
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var CatListView: UIView!
    @IBOutlet weak var CategoryTableView: UITableView!
    @IBOutlet weak var moveToBussinessProfile: UIButton!
    
    var markerDict: [String: GMSMarker] = [:]
    
    private var bottomSheet:BottomSheetVC?
    
    var storeModel: [ResturantsList] = []
    public var FilterStoreModel: [ResturantsList] = []
    
    private var CateGoryListData: [CategoryListElement] = []
    // private var FilterListData: [CategoryListElement] = []
    
    var storeId_Array = NSMutableArray()
     var ZipCode : String?
    var category: String?
    var catForSearch: String?
    
    private var alertPopUp =  UIViewController()
    private var isButtonPressed: String?
    
    private var storeId: String?
    private var storeInformation: ResturantsList?
    
    private var latitude: String?
    private var longitude: String?
    
    private var isPopUp: String?
    
    var isFiltring: Bool = false
    
    var locationManager = CLLocationManager()
    
    var marker: GMSMarker?
    var tappedInfo: ResturantsList?
    
    var markerCountIncrement:Int = 1
    
    //MARK:- ViewController Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        initilize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ExploreSearchApi(isloading: true)
    }
    
    private func initilize() {
        // Your map initiation code
        
        latitude = ""
        longitude = ""
        
        isPopUp = "false"

        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.locationManager.startUpdatingLocation()
                
        IQKeyboardManager.shared.disabledToolbarClasses = [ExploreSearchVC.self]
        
        main_whiteView.isHidden = true
        base_view.putShadowToBoundray(color: .black)
        
        mapView.delegate = self
        
        CategoryTableView.register(UINib(nibName: "RestorentAutoPopulateCell", bundle: nil), forCellReuseIdentifier: "RestorentAutoPopulateCell")
        
        CategoryTableView.estimatedRowHeight = 63
        CategoryTableView.rowHeight = UITableView.automaticDimension
        
        // let address = LocalStorage.shared.fetchData(key: userDefaultKeys.ADDRESS)
        locationSearch_field.text = "Current Location"
        
        searchApi(loadingStatus: true)
        
        // if let cat = category { categorySearch_field.text = cat.capitalizingFirstLetter() }
        
        CategoryList()
        
        let swipeTop = UISwipeGestureRecognizer(target: self, action:#selector(swipeUp(_:)))
        swipeTop.direction = .up
        self.swipeView.addGestureRecognizer(swipeTop)
        
        categorySearch_field.delegate = self
        categorySearch_field.addTarget(self, action: #selector(textFieldEditinChanged(_:)), for: .editingChanged)
        CategoryTableView.isHidden = true
        CatListView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == categorySearch_field {
            categorySearch_field.resignFirstResponder()
            
            if categorySearch_field.text == "" {
                searchApi(loadingStatus: true)
                print("SearchApi")
            } else {
                if CateGoryListData.contains(where: { $0.name == categorySearch_field.text }) {
                    searchApi(loadingStatus: true)
                    print("SearchApi")
                } else {
                    ExploreSearchApi(isloading: true)
                    print("ExploreSearchApi")
                }
            }
        }
        
        return true
        
    }
    
    // MARK:-  Search TextField
    @objc func textFieldEditinChanged(_ sender:UITextField) {

        FilterStoreModel = storeModel.filter {
            return $0.name.range(of: sender.text!, options: .caseInsensitive) != nil
        }
        
        if FilterStoreModel.count == 0 {
            isFiltring = false
        } else {
            isFiltring = true
        }
        
        CategoryTableView.reloadData()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        CategoryTableView.isHidden = false
        CatListView.isHidden = false
        CategoryTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isFiltring = false
        CategoryTableView.isHidden = true
        CatListView.isHidden = true
    }
    
    @IBAction func currentLocationBtn(_ sender: UIButton) {
        // let address = LocalStorage.shared.fetchData(key: userDefaultKeys.ADDRESS)
        categorySearch_field.resignFirstResponder()
        self.locationManager.startUpdatingLocation()
        locationSearch_field.text = "Current Location"
        
        // categorySearch_field.text = ""
        
        latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
        longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
        
        if categorySearch_field.text == "" {
            searchApi(loadingStatus: true)
            print("SearchApi")
        } else {
            if CateGoryListData.contains(where: { $0.name == categorySearch_field.text }) {
                searchApi(loadingStatus: true)
                print("SearchApi")
            } else {
                ExploreSearchApi(isloading: true)
                print("ExploreSearchApi")
            }
        }
    }
    
    //MARK:- Back Button Action.
    
    @IBAction func popToBack(_ sender: UIButton) {
        popToBack()
    }
    
    @IBAction func showPlacePicker(_ sender: UIButton) {
        slideDownSheet()
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        categorySearch_field.resignFirstResponder()
        
        if categorySearch_field.text == "" {
            searchApi(loadingStatus: true)
            print("SearchApi")
        } else {
            if CateGoryListData.contains(where: { $0.name == categorySearch_field.text }) {
                searchApi(loadingStatus: true)
                print("SearchApi")
            } else {
                ExploreSearchApi(isloading: true)
                print("ExploreSearchApi")
            }
        }
    
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 13.5)
        
        self.mapView?.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK:- Swipe to upward.
    
    @objc func swipeUp(_ sender: UISwipeGestureRecognizer) {
        bottomSheet = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BottomSheetVC") as? BottomSheetVC
        bottomSheet?.delegate = self
        bottomSheet?.bottomSheetDelegate = self
        bottomSheet?.resturantsList = storeModel
        
        for i in storeModel {
            bottomSheet?.storeId_Array.add(i.storeID)
        }
        
        bottomSheet?.view.frame = CGRect(x: 0, y:self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(bottomSheet!.view)
        
        UIView.animate(withDuration: 0.4, animations: {
            
            //height for bottom sheet should be 1/3rd of current screen height and 45 points (tab bar height 39) should be decrease from it so table view UI will never get under tab bar.
            
            self.bottomSheet!.view.frame = CGRect(x: 0, y:self.view.bounds.height/3, width: self.view.bounds.width, height: self.view.bounds.height-self.view.bounds.height/3-45 )
            
        }, completion: nil)
        
        self.bottomSheet!.didMove(toParent: self)
        
    }
    
    //MARK:- SlideDown Bottom Sheet.
    
    private func slideDownBottomSheet() {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            /* Getting Crash While Inviting the users by marker locaked pin on */
            
            // self.bottomSheet!.view.frame = CGRect(x: 0, y:self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height-self.view.bounds.height/3-45)
            
            self.bottomSheet?.view.frame = CGRect(x: 0, y:self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height-self.view.bounds.height/3-45)
            
        }, completion: nil)
        
        self.bottomSheet?.removeFromParent()
        
    }
    
    //MARK:- Slide Down BottomSheet immediately.
    
    private func slideDownSheet() {
        
        UIView.animate(withDuration: 0, animations: {
            
            self.bottomSheet?.view.frame = CGRect(x: 0, y:self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height-self.view.bounds.height/3-45)
            
        }, completion: nil)
        
        self.bottomSheet?.removeFromParent()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // categorySearch_field.resignFirstResponder()
    }
    
    
}//..

extension ExploreSearchVC: GMSMapViewDelegate {    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let store = marker.userData as? ResturantsList {
            
            main_whiteView.isHidden = false
            
            swipeView.isHidden = true
            
            isButtonPressed = "Yelp_Invite"
            
            isPopUp = "false"
            
            if let m = self.marker {
                
                switch self.tappedInfo?.type {
                    
                case .db:
                    
                    /*
                     if let str =  categorySearch_field.text?.capitalized {
                         if self.tappedInfo!.name.contains(str) {
                             
                             if let view = self.infoWindow?.subviews {
                                 if let img = view[0] as? UIImageView {
                                     img.image = UIImage.init(named: "unlocked_pin")
                                 }
                             }
                             
                         } else {
                             if let view = self.infoWindow?.subviews {
                                 if let img = view[0] as? UIImageView {
                                     img.image = UIImage.init(named: "unlocked_pin")
                                 }
                             }
                         }
                     } else {
                         if let view = self.infoWindow?.subviews {
                             if let img = view[0] as? UIImageView {
                                 img.image = UIImage.init(named: "unlocked_pin")
                             }
                         }
                     }
                     */
                    
                    /*
                     if let view = self.infoWindow?.subviews {
                         if let img = view[0] as? UIImageView {
                             img.image = UIImage.init(named: "unlocked_green_marker")
                         }
                     }
                     */
                    
                           
                    break
                    
                case .yelp:
                    
                    if let str =  categorySearch_field.text?.capitalized {
                        if self.tappedInfo!.name.contains(str) {
                            
                            m.icon = UIImage.init(named: "locked_pin")
                            
                            /*
                             if let view = self.infoWindow?.subviews {
                             if let img = view[0] as? UIImageView {
                             img.image = UIImage.init(named: "unlocked_pin")
                             }
                             }
                             */
                            
                        } else {
                            m.icon = UIImage.init(named: "green_marker")
                        }
                    } else {
                        m.icon = UIImage.init(named: "green_marker")
                    }
                    
                default:
                    break
                }
                
            }
            
            print(marker.iconView)
            
            self.marker = marker
            
            self.tappedInfo = store
            
            switch store.type {
                
            case .db:
                
                  // marker.icon = UIImage.init(named: "marker")

                /*
                 if let view = self.infoWindow?.subviews {
                     if let img = view[0] as? UIImageView {
                         img.image = UIImage.init(named: "marker")
                     }
                 }
                 */
                
                break
                
            case .yelp:
                
                marker.icon = UIImage.init(named: "lockedMapPin")
                
            default:
                break
            }
            
            self.setupPopUpView(info: store)
            
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        main_whiteView.isHidden = true
        swipeView.isHidden = false
        
        isButtonPressed = ""
        
        isPopUp = "false"
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoom = mapView.camera.zoom
        print("map zoom is ",String(zoom))
    }
    
    /*
     func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
     marker.tracksInfoWindowChanges = true
     return showInfoWindow(marker: marker)
     }
     */
    
    func setupPopUpView(info: ResturantsList) {
        if info.category != "" {
            type.text = info.category
        } else {
            type.text = "No Category"
        }
        
        // Mark:  Favourite data get from Api {To red boarder}
        if info.isFavourite == 1 {
            HomeView.layer.cornerRadius = 2
            HomeView.layer.borderWidth = 1
            HomeView.layer.borderColor = APP_RED_COLOR.cgColor
        } else {
            HomeView.layer.cornerRadius = 0
            HomeView.layer.borderWidth = 0
            HomeView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.25).cgColor
        }
        
        HomeView.clipsToBounds = true
        base_view.clipsToBounds = true
        
        storeId = info.storeID
        ZipCode = info.zipcode
        
        switch info.type {
            
        case .db:
            
            lockedView.isHidden = true
            HomeView.backgroundColor = #colorLiteral(red: 0.9999160171, green: 1, blue: 0.9998719096, alpha: 1)
            base_view.putShadowToBoundray(color: .red)
            heart_btn.isHidden = false
            
            // Mark:  Favourite data get from Api
            if info.favouriteStore == 1 {
                heart_btn.setImage(UIImage(named: "heart-filled"), for: .normal)
            } else {
                heart_btn.setImage(UIImage(named: "heart-empty"), for: .normal)
            }
            
            location.text = info.address
            name.text = info.name
            let imgLink = info.image
            
            
            business_image.sd_setImage(with: URL(string: imgLink), placeholderImage: UIImage(named: "LoadingImage"), options: [], context: nil)
            if info.availableCards.count != 0 {
                let PriceString = info.availableCards[0].price
                giftcard_btn.setTitle("$" + "\(PriceString)" + " " + "eGiftcard", for: .normal)
                self.storeInformation = info
                giftcard_btn.addTarget(self, action: #selector(buyGift(_:)), for: .touchUpInside)
            } else {
                giftcard_btn.setTitle("View Profile", for: .normal)
                self.storeInformation = info
                giftcard_btn.addTarget(self, action: #selector(buyGift(_:)), for: .touchUpInside)
            }
            
            
            
            heart_btn.addTarget(self, action: #selector(heartButtonPressed(_:)), for: .touchUpInside)
            moveToBussinessProfile.addTarget(self, action: #selector(moveToBussinessScreen(_:)), for: .touchUpInside)
            
        case .yelp:
            
            base_view.putShadowToBoundray(color: .black)
            
            HomeView.layer.cornerRadius = 5
            HomeView.layer.masksToBounds = true
            HomeView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.20)
            
            HomeView.isOpaque = true
            lockedView.isHidden = false
            location.text = info.address
            name.text = info.name
            heart_btn.isHidden = true
            business_image.sd_setImage(with: URL(string: info.image), placeholderImage: UIImage(named: "LoadingImage"), options: [], context: nil)
            
            giftcard_btn.addTarget(self, action: #selector(buyGift(_:)), for: .touchUpInside)
            moveToBussinessProfile.addTarget(self, action: #selector(moveToBussinessScreen(_:)), for: .touchUpInside)
            
            
            if info.inviteStore == 1 {
                giftcard_btn.setTitle("Nominated", for: .normal)
                giftcard_btn.isUserInteractionEnabled = false
            } else {
                giftcard_btn.setTitle("Nominate to join", for: .normal)
                giftcard_btn.isUserInteractionEnabled = true
            }
            
        default:
            break
        }
    }
    
    //MARK:- eGiftCard Button Action.
    
    @objc func buyGift(_ sender: UIButton) {
        if giftcard_btn.titleLabel?.text == "Nominate to join" {
            let refreshAlert = UIAlertController(title: APP_NAME, message: "Are you sure you want to Invite \(name.text ?? "this store") on Gift3R app?", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                let param = ["session_id":LocalStorage.shared.fetchData(key: userDefaultKeys.SESSION_ID),
                             "store_id": self.storeId ?? ""
                    ] as [String : Any]
                print(param)
                ApiManager.shared.postRequest(controller: self, url: UrlConstants.INVITE_API, parameters: param, isLoading: true) { (success, response) in
                    
                    if success {
                        DispatchQueue.main.async {
                            
                            if let msg = response["message"] as? String {
                                
                                if msg == "Store Invite successful." {
                                    self.dismiss()
                                } else {
                                    let alert = UIAlertController(title: APP_NAME, message: msg, preferredStyle: .alert)
                                    
                                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                        
                                    }
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    } else {
                        if let msg = response["message"] as? String {
                            GlobalMethod.init().showAlert(title: APP_NAME, message: msg, vc: self)
                        }
                    }
                }
            }))
            present(refreshAlert, animated: true, completion: nil)
            
        } else if giftcard_btn.titleLabel?.text == "View Profile" {
            let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
            VC.storeId = storeId
           VC.ZIpCode = ZipCode ?? ""
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            if let index = storeInformation {
                let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BuyGiftVC") as! BuyGiftVC
                let Index = index.phoneNo
                let dictInfo: [String : Any] = ["BussinessInfo": index, "CardsInfo": index.availableCards, "SelectedIndex": 0]
                VC.bussinessInfo = dictInfo
                VC.ZIpCode = ZipCode ?? ""
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
    
    // MARK:- Move To Bussiness Profile Button Action.
    @objc func moveToBussinessScreen(_ sender: UIButton) {
        let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
        VC.storeId = storeId
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    //MARK:- Heart Button Action.
    
    @objc func heartButtonPressed(_ sender: UIButton) {
        if let id = storeId {
            FavouriteApi(cardID: id)
        }
    }
    
}

// Mark: Favourite Api
extension ExploreSearchVC {
    //MARK:- Favourite API..
    public func FavouriteApi(cardID: String) {
        
        let param = ["session_id":LocalStorage.shared.fetchData(key: userDefaultKeys.SESSION_ID),
                     "store_id":cardID
            ] as [String : Any]
        
        print(param)
        
        ApiManager.shared.postRequest(controller: self, url: UrlConstants.FAVOURITE_API, parameters: param, isLoading: true) { (success, response) in
            
            print(response)
            if success {
                DispatchQueue.main.async {
                    if let type = response["type"] as? Int {
                        
                        self.ExploreSearchApi(isloading: true)
                        
                        if  type == 1 {
                            // Favourite
                            GlobalMethod.init().showAlert(title: APP_NAME, message: "Store favourite successfully!", vc: self)
                            self.heart_btn.setImage(UIImage(named: "heart-filled"), for: .normal)
                        } else {
                            // Unfavourite
                            GlobalMethod.init().showAlert(title: APP_NAME, message: "Store unfavourite successfully!", vc: self)
                            self.heart_btn.setImage(UIImage(named: "heart-empty"), for: .normal)
                        }
                        
                    }
                }
                
            } else {
                
                if let msg = response["message"] as? String {
                    GlobalMethod.init().showAlert(title: APP_NAME, message: msg, vc: self)
                }
            }
        }
    }
    
}


//MARK:- Extension for Custom Protocol Delegates to Dismiss Screens.

extension ExploreSearchVC: BottomSheetDelegate {
  
    // Controller Dismiss Delegate Method.
    
    /*
     func dismiss() {
     slideDownBottomSheet()
     }
     */
    
    
    func inviteToJoin(storeId: String, name: String,zipCode : String) {
        
        isButtonPressed = "Yelp_Invite"
        
        self.storeId = storeId
        
        let refreshAlert = UIAlertController(title: APP_NAME, message: "Are you sure you want to Invite \(name) on Gift3R app?", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            
            let param = ["session_id":LocalStorage.shared.fetchData(key: userDefaultKeys.SESSION_ID),
                         "store_id": self.storeId ?? ""
                ] as [String : Any]
            print(param)
            ApiManager.shared.postRequest(controller: self, url: UrlConstants.INVITE_API, parameters: param, isLoading: true) { (success, response) in
                
                if success {
                    DispatchQueue.main.async {
                        
                        if let msg = response["message"] as? String {
                            
                            if msg == "Store Invite successful." {
                                self.dismiss()
                            } else {
                                let alert = UIAlertController(title: APP_NAME, message: msg, preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                    
                                }
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    if let msg = response["message"] as? String {
                        GlobalMethod.init().showAlert(title: APP_NAME, message: msg, vc: self)
                    }
                }
                
            }
            
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    func dismissSheet(storeId: String) {
        
        slideDownSheet()
        
        self.storeId = storeId
        isButtonPressed = "inviteAllBusiness"
        
        dismiss()
        
        
        /*
         let vc = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "InviteSendVC") as! InviteSendVC
         vc.modalPresentationStyle = .overCurrentContext
         self.present(vc, animated: false, completion: nil)
         */
    }
    
    func moveToBusiness(businessProfile: Bool, storeId: String,zipCode : String) {
        if businessProfile {
            slideDownSheet()
            let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
            VC.storeId = storeId
             VC.ZIpCode = zipCode
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BuyGiftVC") as! BuyGiftVC
            VC.ZIpCode = zipCode
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func moveToBuyCard(storeInfo: ResturantsList) {
        slideDownSheet()
        let index = storeInfo
        let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BuyGiftVC") as! BuyGiftVC
        let PhoneNumber =  index.phoneNo
                   let Zipocode =  index.zipcode
               let PhoneNumber2 =  index.name
        let dictInfo: [String : Any] = ["BussinessInfo": index, "CardsInfo": index.availableCards, "SelectedIndex": 0]
        VC.bussinessInfo = dictInfo
        VC.ZIpCode = Zipocode ?? ""
        self.navigationController?.pushViewController(VC, animated: true)
    }
}//..

extension ExploreSearchVC {
    
    private func searchApi(loadingStatus: Bool) {
        
        //        let lat = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
        //        let long = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
        
        var cat: String = ""
        
        if latitude == "" {
            latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
        }
        
        if longitude == "" {
            longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
        }
        
        if let cate = category{ cat = cate.capitalizingFirstLetter() }
        
        if categorySearch_field.text != "" {
            cat = categorySearch_field.text ?? ""
        }
        
        let param = ["session_id": LocalStorage.shared.fetchData(key: userDefaultKeys.SESSION_ID),
                     "search": cat,
                     "latitude": latitude!,
                     "longitude": longitude!,
                     "limit": "10",
                     "page": "1"
            ] as [String : Any]
        
        print("Parameter", param)
        
        ApiManager.shared.postRequest(controller: self, url: UrlConstants.SEARCH_HOME, parameters: param, isLoading: loadingStatus) { (success, response) in
            
            if success {
                
                DispatchQueue.main.async {
                    
                    let getdata = GetArrayOfDict(fromobject: response)
                    
                    do {
                        
                        let storeListModel = try JSONDecoder().decode(HomeSearchModel.self, from: getdata)
                        
                        self.storeModel = storeListModel.resturantsList
                        
                        for i in self.storeModel {
                            self.storeId_Array.add(i.storeID)
                        }
    
                        self.setupMap(info: self.storeModel)
                        self.markerCountIncrement = 1
                        
                    } catch {
                        /* handle exception */
                        print("Server Responce:-", error.localizedDescription)
   
                        GlobalMethod.init().showAlert(title: APP_NAME, message: error.localizedDescription, vc: self)
                    }
                }
                
            } else {
                
                if let msg = response["message"] as? String {
                    GlobalMethod.init().showAlert(title: APP_NAME, message: msg, vc: self)
                }
                
            }
        }
    }
    
    private func ExploreSearchApi(isloading: Bool) {
         
        var cat: String = ""
        
        if latitude == "" {
            latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
        }
        
        if longitude == "" {
            longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
        }
        
        if let cate = category{ cat = cate.capitalizingFirstLetter() }
        
        if categorySearch_field.text != "" {
            cat = categorySearch_field.text ?? ""
        }
        
        let param = ["session_id": LocalStorage.shared.fetchData(key: userDefaultKeys.SESSION_ID),
                     "search": cat,
                     "latitude": latitude!,
                     "longitude": longitude!,
                     "limit": "10",
                     "page": "1"
        ]
        
        print(param)
        
        ApiManager.shared.postRequest(controller: self, url: UrlConstants.SEARCH_API, parameters: param, isLoading: isloading) { (success, response) in
            
            if success {
                
                print(response)
                
                DispatchQueue.main.async {
                    
                    let getdata = GetArrayOfDict(fromobject: response)
                    
                    do {
                        
                        let storeListModel = try JSONDecoder().decode(HomeSearchModel.self, from: getdata)
                        self.storeModel = storeListModel.resturantsList
                        
                        for i in self.storeModel {
                            self.storeId_Array.add(i.storeID)
                        }
                        
                        self.setupMap(info: self.storeModel)
                        
                        self.markerCountIncrement = 1
                        
                    } catch {
                        /* handle exceptio n */
                        print("Server Responce:-", error.localizedDescription)
                        GlobalMethod.init().showAlert(title: APP_NAME, message: error.localizedDescription, vc: self)
                    }
                }
                
            } else {
                
                if let msg = response["message"] as? String {
                    GlobalMethod.init().showAlert(title: APP_NAME, message: msg, vc: self)
                }
                
            }
        }
    }
    
    //MARK:- Category List Api Calls.
    
    private  func CategoryList() {
        
        ApiManager.shared.getRequest(controller: self, url: UrlConstants.CATEGORY_API, parameters: [:]) { (success, response) in
            
            print(response)
            
            if success {
                
                DispatchQueue.main.async {
                    
                    let getdata = GetArrayOfDict(fromobject: response)
                    do {
                        let CategoryModel =  try JSONDecoder().decode(CategoryListModel.self, from: getdata)
                        self.CateGoryListData = CategoryModel.categoryList
                        self.CateGoryListData.removeFirst()
                        //self.CategoryTableView.reloadData()
                    } catch {
                        /* handle exception */
                        print("Server Responce:-", error.localizedDescription)
                        GlobalMethod.init().showAlert(title: APP_NAME, message: error.localizedDescription, vc: self)
                    }
                }
                
            } else {
                
                if let msg = response["message"] as? String {
                    GlobalMethod.init().showAlert(title: APP_NAME, message: msg, vc: self)
                }
                
            }
        }
    }
    
    func showInfoWindow(marker:GMSMarker)->UIView {
        
        let view = Bundle.main.loadNibNamed("MarkerView", owner: self, options: nil)?.first as! UIView
        self.infoWindow = view
        self.infoWindow?.tag = view.tag
        // view.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
    
        
        /*
         if let index = markerList.firstIndex(of: marker) {
             
             let data = self.storeModel[index]
             
             DispatchQueue.main.async {
                 //  let imgView = view.viewWithTag(9090) as! UIImageView
                 let imageView1 = view.viewWithTag(1) as! UIImageView
                 let label = view.viewWithTag(2) as! UILabel
                 
                 
                 switch data.type {
                     
                 case .db:
                     
                     let Num = self.storeModel.count
                     
                     for i in 0 ... Num {
                         let str = String(i)
                         label.text = str
                     }
                     
                     // view.addSubview(imgView)
                     view.addSubview(imageView1)
                     view.addSubview(label)
                     
                 case .yelp:
                     break
                     
                 default:
                     break
                 }
             }
         }
         */
        
        
        return view
    }
    
    
    func setupMap(info: [ResturantsList]) {


        var data: [ResturantsList] = info

        mapView.clear()
        
        
        
        if let cat = locationSearch_field.text {
          
            if cat != "Current Location" {
                
                if let cat = categorySearch_field.text {
                    
                    if cat == "" {
                        
                        if data.count != 0 {
                            data.removeFirst()
                            markerCountIncrement = 2
                        }
                        
                    }
                }
            }
        }
        
        
        
        
        for state in data {

            switch state.type {
                
            case .db:
                
                let state_marker = GMSMarker()
                state_marker.position = CLLocationCoordinate2D(latitude: Double(state.latitude)!, longitude: Double(state.longitude)!)
                
                state_marker.userData = state
                state_marker.iconView = showInfoWindow(marker:state_marker)
                
                
                if let str = categorySearch_field.text?.capitalized {

                    if state.name.contains(str) {
                        
                        if let view = self.infoWindow?.subviews {
                            
                            if let img = view[0] as? UIImageView {
                                img.image = UIImage.init(named: "unlocked_pin")
                            }
                            
                            if let lbl = view[1] as? UILabel {
                                lbl.text = "\(markerCountIncrement)"
                                markerCountIncrement = markerCountIncrement+1
                            }
                            
                        }
                        
                    } else {
                        if let view = self.infoWindow?.subviews {
                            if let img = view[0] as? UIImageView {
                                img.image = UIImage.init(named: "unlocked_green_marker")
                            }
                            
                            if let lbl = view[1] as? UILabel {
                                lbl.text = "\(markerCountIncrement)"
                                markerCountIncrement = markerCountIncrement+1
                            }
                        }
                    }
                } else {
                    
                    if let view = self.infoWindow?.subviews {
                        
                        if let img = view[0] as? UIImageView {
                            img.image = UIImage.init(named: "unlocked_green_marker")
                        }
                        if let lbl = view[1] as? UILabel {
                            lbl.text = "\(markerCountIncrement)"
                            markerCountIncrement = markerCountIncrement+1
                        }
                    }
                }
               
                if locationSearch_field.text == "Current Location" {
                    if let str =  categorySearch_field.text?.capitalized {
                        
                        if CateGoryListData.contains(where: { $0.name != categorySearch_field.text }) {
                            
                            if state.name.contains(str) {
                                
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!, zoom: 15.5)
                                self.mapView.camera = camera
                                
                                
                                
                            } else {
                                
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(latitude!) ?? Double(state.latitude) ?? 0.0, longitude: Double(longitude!) ?? Double(state.longitude) ?? 0.0, zoom: 14.0)
                                self.mapView.camera = camera
                            }
                            
                            
                        } else {
                            self.locationManager.startUpdatingLocation()
                        }
                    } else{
                        self.locationManager.startUpdatingLocation()
                    }
                    
                } else {
                    
                    if let str =  categorySearch_field.text?.capitalized {
                        
                        if CateGoryListData.contains(where: { $0.name == categorySearch_field.text }) {
                            if latitude == "" {
                                latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                            }
                            
                            if longitude == "" {
                                longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                            }
                            
                            let camera = GMSCameraPosition.camera(withLatitude: Double(latitude!) ?? Double(latitude!)!, longitude: Double(longitude!) ?? Double(longitude!)!, zoom: 15.5)
                            self.mapView.camera = camera
                            
                        } else {
                            
                            if state.name.contains(str) {
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!, zoom: 15.5)
                                self.mapView.camera = camera
                                
                            } else {
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!, zoom: 15.5)
                                self.mapView.camera = camera
                            }
                        }
                        
                    }
                   
                }
                
                state_marker.map = mapView
                
            case .yelp:
                
                let state_marker = GMSMarker()
                
                state_marker.position = CLLocationCoordinate2D(latitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!)
                
                if let str =  categorySearch_field.text?.capitalized {
                    if state.name.contains(str) {
                        state_marker.icon = UIImage.init(named: "locked_pin")
                    } else {
                        state_marker.icon = UIImage.init(named: "green_marker")
                    }
                }
                
                /*
                 if state.name == categorySearch_field.text?.capitalized {
                 state_marker.icon = UIImage.init(named: "locked_pin")
                 } else {
                 state_marker.icon = UIImage.init(named: "green_marker")
                 }
                 */
                
                state_marker.userData = state
                /* state_marker.iconView = showInfoWindow(marker: state_marker) */
                
                
                if locationSearch_field.text == "Current Location" {
                    
                    if let str =  categorySearch_field.text?.capitalized {
                        
                        if CateGoryListData.contains(where: { $0.name != categorySearch_field.text }) {
                            
                            if state.name.contains(str) {
                                
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!, zoom: 15.5)
                                self.mapView.camera = camera
                                
                            } else {
                                
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(latitude!) ?? Double(state.latitude) ?? 0.0, longitude: Double(longitude!) ?? Double(state.longitude) ?? 0.0, zoom: 14.0)
                                self.mapView.camera = camera
                            }
                             
                            
                        } else {
                            self.locationManager.startUpdatingLocation()
                        }
                    } else{
                        self.locationManager.startUpdatingLocation()
                    }
                    
                } else {
                    
                    if let str =  categorySearch_field.text?.capitalized {
                                                
                        if CateGoryListData.contains(where: { $0.name == categorySearch_field.text }) {
                            
                            if latitude == "" {
                                latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                            }
                            
                            if longitude == "" {
                                longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                            }
                            
                            let camera = GMSCameraPosition.camera(withLatitude: Double(latitude!)!, longitude: Double(longitude!)! , zoom: 15.5)
                            self.mapView.camera = camera
                                                
                        } else {
                            
                            if state.name.contains(str) {
                                
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!, zoom: 15.5)
                                self.mapView.camera = camera
                                
                            } else {
                                
                                if latitude == "" {
                                    latitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LATITUDE)
                                }
                                
                                if longitude == "" {
                                    longitude = LocalStorage.shared.fetchData(key: userDefaultKeys.LONGITUDE)
                                }
                                
                                let camera = GMSCameraPosition.camera(withLatitude: Double(state.latitude) ?? Double(latitude!)!, longitude: Double(state.longitude) ?? Double(longitude!)!, zoom: 15.5)
                                self.mapView.camera = camera
                            }
                            
                        }
                        
                    }

                }
                
                state_marker.map = mapView
                
            default:
                break
            }
            
        }
        
        
        
        if let cat = locationSearch_field.text {
                           
            if cat != "Current Location" {
                if info.count != 0 {
                            let firstVal = info[0]
                            
                            switch firstVal.type {
                                
                            case .db:
                                
                                if let cat = categorySearch_field.text {
                                    
                                    if cat == "" {
                                        
                //                        let state_marker = GMSMarker()
                //                        state_marker.position = CLLocationCoordinate2D(latitude: Double(firstVal.latitude)!, longitude: Double(firstVal.longitude)!)
                //
                //                        state_marker.userData = firstVal
                //                        state_marker.iconView = showInfoWindow(marker:state_marker)
                                        
                                        let state_marker = GMSMarker()
                                        
                                        state_marker.position = CLLocationCoordinate2D(latitude: Double(firstVal.latitude) ?? Double(latitude!)!, longitude: Double(firstVal.longitude) ?? Double(longitude!)!)
                                        state_marker.icon = UIImage.init(named: "marker1")
                                        state_marker.userData = firstVal
                                        
                                        state_marker.map = mapView
                                        
                                        
                                        
                //                        if let view = self.infoWindow?.subviews {
                //
                //                            if let img = view[0] as? UIImageView {
                //                                img.image = UIImage.init(named: "marker1")
                //                            }
                //
                ////                            if let lbl = view[1] as? UILabel {
                ////                                lbl.text = "\(markerCountIncrement)"
                ////                                markerCountIncrement = markerCountIncrement+1
                ////                            }
                //
                //                        }
                                        
                                        
                                        let camera = GMSCameraPosition.camera(withLatitude: Double(firstVal.latitude) ?? Double(latitude!)!, longitude: Double(firstVal.longitude) ?? Double(longitude!)!, zoom: 17.0)
                                        self.mapView.camera = camera
                                        
                                    }
                                    
                                }
                                
                            case .yelp:
                                
                                
                                if let cat = categorySearch_field.text {
                                    
                                    if cat == "" {
                                        
                                        let state_marker = GMSMarker()
                                        
                                        state_marker.position = CLLocationCoordinate2D(latitude: Double(firstVal.latitude) ?? Double(latitude!)!, longitude: Double(firstVal.longitude) ?? Double(longitude!)!)
                                        state_marker.icon = UIImage.init(named: "locked_pin")
                                        state_marker.userData = firstVal
                                        
                                        state_marker.map = mapView

                                        
                                        let camera = GMSCameraPosition.camera(withLatitude: Double(firstVal.latitude) ?? Double(latitude!)!, longitude: Double(firstVal.longitude) ?? Double(longitude!)!, zoom: 17.0)
                                        
                                        self.mapView.camera = camera
                                        
                                    }
                                }
                                
                            default:
                                break
                            }
                            
                        }
            }
        }
        
        
        
        
        
        
                   
        
        
        
//        if info.count != 0 {
//            if info[0].latitude != "" && info[0].latitude != "" {
//
//                switch info[0].type {
//
//                case .db:
//
//                    let state_marker = GMSMarker()
//                    state_marker.position = CLLocationCoordinate2D(latitude: Double(info[0].latitude)!, longitude: Double(info[0].longitude)!)
//
//                    state_marker.userData = info[0]
//                    state_marker.iconView = showInfoWindow(marker:state_marker)
//
//
//                    if let view = self.infoWindow?.subviews {
//                        if let img = view[0] as? UIImageView {
//                            img.image = UIImage.init(named: "unlocked_pin")
//                        }
//
//                        if let lbl = view[1] as? UILabel {
//                            lbl.text = "\(markerCountIncrement)"
//                            markerCountIncrement = markerCountIncrement+1
//                        }
//                    }
//
//                    let camera = GMSCameraPosition.camera(withLatitude: Double(info[0].latitude) ?? Double(latitude!)!, longitude: Double(info[0].longitude) ?? Double(longitude!)!, zoom: 15.5)
//                    self.mapView.camera = camera
//
//                    state_marker.map = mapView
//
//                case .yelp:
//                    let state_marker = GMSMarker()
//
//                    state_marker.position = CLLocationCoordinate2D(latitude: Double(info[0].latitude) ?? Double(latitude!)!, longitude: Double(info[0].longitude) ?? Double(longitude!)!)
//
//                   state_marker.icon = UIImage.init(named: "locked_pin")
//
//                    state_marker.userData = info[0]
//
//                    let camera = GMSCameraPosition.camera(withLatitude: Double(info[0].latitude) ?? Double(latitude!)!, longitude: Double(info[0].longitude) ?? Double(longitude!)!, zoom: 15.5)
//                    self.mapView.camera = camera
//
//                    state_marker.map = mapView
//
//                default:
//                    break
//                }
//
//            } else if info[1].latitude != "" && info[1].latitude != "" {
//
//            }
//        }
        
        
        
    }
    
}

extension ExploreSearchVC: ControllerDismissDelegate {
    
    func success() {
        isPopUp = "false"
        isButtonPressed = ""
        giftcard_btn.setTitle("Nominated", for: .normal)
        
        searchApi(loadingStatus: false)
    }
    
    func dismiss() {
        
        if isPopUp == "false" {
            slideDownBottomSheet()
        }
        
        if isButtonPressed == "Yelp_Invite" {
            slideDownSheet()
            if !(alertPopUp.isViewLoaded) {
                if let loadVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "InviteBusinessPopUpVC") as? InviteBusinessPopUpVC {
                    loadVC.delegate = self
                    loadVC.storeId = self.storeId
                    self.addChild(loadVC)
                    self.view.addSubview(loadVC.view)
                    alertPopUp.view.alpha = 0
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.alertPopUp.view.alpha = 1
                    }, completion: nil)
                    
                    alertPopUp = loadVC
                }
            } else {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.alertPopUp.view.alpha = 0
                }, completion: nil)
                alertPopUp.view.removeFromSuperview()
                alertPopUp = UIViewController()
            }
        } else if isButtonPressed == "inviteAllBusiness" {
            if !(alertPopUp.isViewLoaded) {
                if let loadVC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "InviteSendVC") as? InviteSendVC {
                    loadVC.delegate = self
                    loadVC.storeIds = self.storeId
                    self.addChild(loadVC)
                    self.view.addSubview(loadVC.view)
                    alertPopUp.view.alpha = 0
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.alertPopUp.view.alpha = 1
                    }, completion: nil)
                    
                    alertPopUp = loadVC
                }
            } else {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.alertPopUp.view.alpha = 0
                }, completion: nil)
                alertPopUp.view.removeFromSuperview()
                alertPopUp = UIViewController()
            }
        }
        
    }
    
}


// MARK: - Google Place Picker

extension ExploreSearchVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        
        if let info = place.formattedAddress {
            
            latitude = String(place.coordinate.latitude)
            longitude = String(place.coordinate.longitude)
            
            self.locationSearch_field.text = info
            
            self.searchApi(loadingStatus: true)
            
            /*
             getAddressFromLatLon(address: info, pdblLatitude: String(place.coordinate.latitude), withLongitude: String(place.coordinate.longitude))
             */
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    func getAddressFromLatLon(address: String, pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        print(lat)
        print(lon)
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                print(placemarks)
                
                if let pm = placemarks {
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        
                        
                        print(pm.country)
                        
                        print(pm.locality)
                        
                        print(pm.subLocality)
                        
                        print(pm.thoroughfare)
                        
                        print("zip code", pm.postalCode)
                        
                        print(pm.subThoroughfare)
                        
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        
                        
                        
                    }
                }
        })
        
    }
    
    
}


extension ExploreSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if categorySearch_field.text == "" {
            
            if CateGoryListData.count == 0 {
                CatListView.isHidden = true
            } else {
                CatListView.isHidden = false
            }
            
            return CateGoryListData.count
            
        } else {
            
            if isFiltring == true {
                
                if FilterStoreModel.count == 0 {
                    CatListView.isHidden = true
                } else {
                    CatListView.isHidden = false
                }
                return FilterStoreModel.count
            } else {
                if storeModel.count == 0 {
                    CatListView.isHidden = true
                } else {
                    CatListView.isHidden = false
                }
                
                return storeModel.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let RestorentAutoPopulateCell = tableView.dequeueReusableCell(withIdentifier: "RestorentAutoPopulateCell", for: indexPath) as! RestorentAutoPopulateCell
        
        if categorySearch_field.text == "" {
            
            let index = CateGoryListData[indexPath.row]
            cell.CategoryLabel.text = index.name.capitalizingFirstLetter()
            cell.CategoryImage.sd_setImage(with: URL(string:CateGoryListData[indexPath.row].image), placeholderImage: UIImage(named: "LoadingImage"), options: [], context: nil)
            
            /*
             if indexPath.row == 0 {
             cell.CategoryImage.image = UIImage.init(named: "more-teal")
             } else {
             cell.CategoryImage.sd_setImage(with: URL(string:CateGoryListData[indexPath.row].image), placeholderImage: UIImage(named: "restaurant_img"), options: [], context: nil)
             }
             */
            
            return cell
            
        } else {
            
            if isFiltring == true {
                let index = FilterStoreModel[indexPath.row]
                RestorentAutoPopulateCell.name.text = index.name
                RestorentAutoPopulateCell.addressLbl.text = index.address
                RestorentAutoPopulateCell.storeImg.sd_setImage(with: URL(string: index.image), placeholderImage: UIImage(named: "LoadingImage"), options: [], context: nil)
                
            } else {
                let index = storeModel[indexPath.row]
                RestorentAutoPopulateCell.name.text = index.name
                RestorentAutoPopulateCell.addressLbl.text = index.address
                RestorentAutoPopulateCell.storeImg.sd_setImage(with: URL(string: index.image), placeholderImage: UIImage(named: "LoadingImage"), options: [], context: nil)
            }
            
            return RestorentAutoPopulateCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if categorySearch_field.text == "" {
            
            categorySearch_field.text = CateGoryListData[indexPath.row].name
            
            CategoryTableView.isHidden = true
            CatListView.isHidden = true
            categorySearch_field.resignFirstResponder()
            
            searchApi(loadingStatus: true)
            
        } else {
            
            if isFiltring == true {
                
                let index = FilterStoreModel[indexPath.row]
                
                switch index.type {
                    
                case .db:
                    
                    let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
                    VC.storeId = FilterStoreModel[indexPath.row].storeID
                     VC.ZIpCode = FilterStoreModel[indexPath.row].zipcode
                    self.navigationController?.pushViewController(VC, animated: true)
                    
                case .yelp:
                    print("Its lock")
                    let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
                    VC.storeId = FilterStoreModel[indexPath.row].storeID
                     VC.ZIpCode = FilterStoreModel[indexPath.row].zipcode
                    self.navigationController?.pushViewController(VC, animated: true)
                default:
                    break
                }
                
                
                
            } else {
                let index = storeModel[indexPath.row]
                
                switch index.type {
                    
                case .db:
                    
                    let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
                    VC.storeId = storeModel[indexPath.row].storeID
                     VC.ZIpCode = storeModel[indexPath.row].zipcode
                    self.navigationController?.pushViewController(VC, animated: true)
                    
                case .yelp:
                    print("Its lock")
                    let VC = EXPLORE_STORYBOARD.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
                    VC.storeId = storeModel[indexPath.row].storeID
                       VC.ZIpCode = storeModel[indexPath.row].zipcode
                    self.navigationController?.pushViewController(VC, animated: true)
                default:
                    break
                }
                
            }
            CategoryTableView.isHidden = true
            CatListView.isHidden = true
            categorySearch_field.resignFirstResponder()
        }
        
    }
    
}
