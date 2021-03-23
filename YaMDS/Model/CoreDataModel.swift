//
//  CoreDataModel.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 17.03.2021.
//

import Foundation
import UIKit
import CoreData

class ModelCD {
    
    private var stockCards = Dictionary<String, StockTableCard>()   // Dict for all Cards
    
    // Get context for app
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    // Reload data from CoreData
    func loadCardsFromCoreData() -> Dictionary<String, StockTableCard> {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<StockCard> = StockCard.fetchRequest()
        
        do {
            let dataStockList = try context.fetch(fetchRequest)
            for record in dataStockList {
                let decodedCard = try! JSONDecoder().decode(StockTableCard.self, from: record.card!)
                stockCards[record.ticker!] = decodedCard
                print(#function, decodedCard.currentPrice)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return stockCards
    }
    
    // Save all cards to CoreData as dictionary
    func saveCoreData(cards: Dictionary<String, StockTableCard>) {
        let cardsCD = loadCardsFromCoreData()
        print("loaded cards count", cardsCD.count)
        let mergedCards = cardsCD.merging(cards) { (_, new) in new }
        
        clearCoreData()
        
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "StockCard", in: context) else { return }
        
        print("Saving Cards to CoreData")
        for (key, value) in mergedCards {
            print(value.currentPrice)
            
            // Create new task
            let taskObject = StockCard(entity: entity, insertInto: context)
            taskObject.ticker = key
            let encodedCard = try! JSONEncoder().encode(value)
            taskObject.card = encodedCard
            
            // Save new task in memory at 0 position
            do {
                try context.save()
                print(taskObject.ticker!)
//                print(taskObject.card!)
            } catch let error as NSError  {
                print(error.localizedDescription)
            }
        }
    }
    
    private func clearCoreData() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<StockCard> = StockCard.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
}
