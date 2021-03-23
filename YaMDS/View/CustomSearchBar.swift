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
            textField.font = UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "PrimaryFontColor")!])
            
            if let backgroundView = textField.subviews.first {
                backgroundView.backgroundColor = UIColor(named: "EvenCell")
                backgroundView.layer.cornerRadius = 20
                backgroundView.clipsToBounds = true
//                backgroundView.layer.borderColor = UIColor.black.cgColor
//                backgroundView.layer.borderWidth = 1
            }
            let button = textField.value(forKey: "clearButton") as! UIButton
            button.setImage(UIImage(named: "Close"), for: .normal)
            
            textField.leftViewMode = UITextField.ViewMode.never
        }
    }

}
