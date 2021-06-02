//
//  AlertViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 26.03.2021.
//

import UIKit

class AlertViewController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func configureAlertVC(request: AlertMessage) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: "Please, try reload app", preferredStyle: .alert)
        if request == .connection {
            alert.title = "No connection"
            alert.message = "Cannot connect to server.\nPlease check your Internet\nand tap \"Reload\""
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                let rootVC = UIApplication.shared.windows.first!.rootViewController as! ViewController
                print(rootVC.stockCards.count)
                rootVC.loadStocksInView()

            }))
        } else if request == .connectionDetailVC {
            alert.title = "No connection"
            alert.message = "Cannot connect to server.\nPlease check your Internet\nand try again later."
        } else if request == .apiLimit {
            alert.title = "API Error"
            alert.message = "Too many API requests\n(~1 min to reset limit).\nPlease try later."
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                let rootVC = UIApplication.shared.windows.first!.rootViewController as! ViewController
                print( #line, #function, rootVC.stockCards.count )
                rootVC.loadStocksInView()
//                if rootVC.stockCards.count < StockList().stockList.count {
//                    rootVC.priceSocket.startWebSocket(tickerArray: StockList().stockList)
//                }
//                rootVC.loadPrices()
            }))
        } else if request == .apiLimitDetailVC {
            alert.title = "API Error"
            alert.message = "Too many API requests\n(~1 min to reset limit).\nPlease try later."
            alert.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                if let presenter = self.presentingViewController as? ViewController {
                    presenter.stockTableView.reloadData()
                    self.dismiss(animated: true, completion: nil)
                }
            }))
        } else {
            alert.title = "Error"
            alert.message = "Unknown error occured.\nPlease try again or restart the app."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            guard action.style == .cancel else { return }
            print("Cancel")
        }))
        return alert
    }
}
