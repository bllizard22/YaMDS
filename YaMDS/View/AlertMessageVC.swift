//
//  AlertMessageVC.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 19.03.2021.
//

import UIKit

class AlertMessageVC: UIAlertController {

    var isReloadFromAPINeeded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showAlert(request: AlertMessage) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: "Please, try reload app", preferredStyle: .alert)
        if request == .connection {
            alert.title = "No connection"
            alert.message = "Cannot connect to server.\nPlease check your WiFi/Cellular and tap \"Reload\""
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                self.isReloadFromAPINeeded = true
            }))
        } else if request == .apiLimit {
            alert.title = "API Error"
            alert.message = "Out of API requests (1 min to reset limit). Try again?"
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                self.isReloadFromAPINeeded = true
            }))
        } else {
            alert.title = "Error"
            alert.message = "Unknown error occured.\nPlease restart the app."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            guard action.style == .cancel else { return }
            print("Cancel")
//            self.stocksButton.isEnabled = false
        }))
//        self.present(alert, animated: true, completion: nil)
        return alert
    }

}
