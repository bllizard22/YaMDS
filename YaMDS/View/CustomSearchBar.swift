//
//  CustomSearchBar.swift
//  YaMDS
//
//  Created by nick on 3/18/21.
//

import UIKit

class CustomSearchBar: UISearchBar {

	// FIXME: зачем эта переменная.
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
			// FIXME: лучше вынеси в extension UIFont
            textField.font = UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "PrimaryFontColor")!])
            
            if let backgroundView = textField.subviews.first {
                backgroundView.backgroundColor = UIColor(named: "EvenCell")
                backgroundView.layer.cornerRadius = 20
                backgroundView.clipsToBounds = true
            }
            let button = textField.value(forKey: "clearButton") as! UIButton
            button.setImage(UIImage(named: "Close"), for: .normal)
            
            textField.leftViewMode = UITextField.ViewMode.never
        }
    }

}
