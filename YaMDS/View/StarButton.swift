//
//  StarButton.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 03.04.2021.
//

import UIKit

class StarButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func animateDislikeTap() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
            UIView.transition(with: self.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.setImage(UIImage(named: "StarGray"), for: .normal)
            }, completion: nil)
            self.imageView?.transform = (self.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
        }
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseOut]) {
            self.imageView?.transform = (self.imageView?.transform.scaledBy(x: 1.0, y: 1.0))!
        }
    }
    
    func animateLikeTap() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
            UIView.transition(with: self.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.setImage(UIImage(named: "StarGold"), for: .normal)
            }, completion: nil)
            self.imageView?.transform = (self.imageView?.transform.scaledBy(x: 1.25, y: 1.25))!
        }
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseOut]) {
            self.imageView?.transform = (self.imageView?.transform.scaledBy(x: 1.0, y: 1.0))!
        }
    }
}
