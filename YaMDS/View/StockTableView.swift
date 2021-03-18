//
//  StockTableView.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 04.03.2021.
//

import UIKit

class StockTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configureTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTableView()
    }

    func configureTableView() {
        self.separatorStyle = .none
        self.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "stockCell")
    }
}
