//
//  DropPinsOnMap.swift
//  SwiftHelperClasses
//
//  Created by Prabhat on 20/11/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import UIKit

class DropPinsOnMap: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupMap(info: [ResturantsList]) {


        var data: [ResturantsList] = info

        mapView.clear()
        
        
        let state_marker = GMSMarker()
        
        state_marker.position = CLLocationCoordinate2D(latitude: Double(firstVal.latitude) ?? Double(latitude!)!, longitude: Double(firstVal.longitude) ?? Double(longitude!)!)
        state_marker.icon = UIImage.init(named: "marker1")
        state_marker.userData = firstVal
        
        state_marker.map = mapView
        
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(firstVal.latitude) ?? Double(latitude!)!, longitude: Double(firstVal.longitude) ?? Double(longitude!)!, zoom: 17.0)
        self.mapView.camera = camera
        
        
    }
    

}
