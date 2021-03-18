//
//  CustomSearchBar.swift
//  YaMDS
//
//  Created by nick on 3/18/21.
//

import UIKit

class CustomSearchBar: UISearchBar {

    var searchBar: UISearchBar!
    let placeholderPhrase = "Find company or ticker"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        searchBar = UISearchBar()
        configureSearchBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSearchBar()
    }
    
    func configureSearchBar() {
        self.searchTextPositionAdjustment = UIOffset(horizontal: -6, vertical: 0)
        
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.layer.cornerRadius = 20
            textField.clipsToBounds = true
            textField.frame = CGRect(x: -5, y: -5, width: textField.frame.width+10, height: textField.frame.height+10)
            textField.layer.borderWidth = 2
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.font = UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            
            if let backgroundView = textField.subviews.first {
                backgroundView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.2)
                backgroundView.layer.cornerRadius = 20
                backgroundView.clipsToBounds = true
                backgroundView.layer.borderColor = UIColor.black.cgColor
                backgroundView.layer.borderWidth = 1
            }
            let button = textField.value(forKey: "clearButton") as! UIButton
            button.setImage(UIImage(named: "Close"), for: .normal)
            
//            if let leftView = textField.leftView as? UIImageView {
//                let searchImage = UIImage(named: "Search_24")
//                leftView.image = searchImage!.withRenderingMode(.alwaysTemplate)
//                leftView.tintColor = .black
//            }
            textField.leftViewMode = UITextField.ViewMode.never
        }
    }

}
