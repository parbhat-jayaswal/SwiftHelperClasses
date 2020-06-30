//
//  Extensions.swift
//  uSnapp
//
//  Created by Prabhat on 18/04/18.
//  Copyright © 2018 Prabhat. All rights reserved.
//

import UIKit

@IBDesignable class WTFCatView: LoadableView {

    @IBInspectable var catBackgroundColor: UIColor! {
        didSet {
            backgroundColor = catBackgroundColor
        }
    }

}
