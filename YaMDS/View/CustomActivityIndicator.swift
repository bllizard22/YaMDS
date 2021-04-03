//
//  ActivityIndicator.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 03.04.2021.
//

import UIKit

class CustomActivityIndicator: UIActivityIndicatorView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }

}
