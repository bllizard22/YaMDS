//
//  FavouriteStocks.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 09.03.2021.
//

import Foundation
import CoreData
import UIKit

class Favourites {
    
    var stockList: [StockCardLikes] = []
    var likedList: [String] = []
    
    // Return array of all liked tickers
    var liked: Array<String> {
        var likes = Array<String>()
        for item in stockList {
            likes.append(item.ticker!)
        }
//        clearAllLikes()
        return likes
    }
    
    init() {
        loadCoreData()
        likedList = liked
    }
    
    // Get context for app
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // Reload data from CoreData
    private func loadCoreData() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<StockCardLikes> = StockCardLikes.fetchRequest()
        // Sorting of tasks list
        let sortDescriptor = NSSortDescriptor(key: "ticker", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Obtain data from context
        do {
            try stockList = context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Add new record in CoreData
    func saveTicker(withTicker title: String) {
        let context = getContext()
                
        guard let entity = NSEntityDescription.entity(forEntityName: "StockCardLikes", in: context) else {return}
        
        // Create new task
        let taskObject = StockCardLikes(entity: entity, insertInto: context)
        taskObject.ticker = title
        
        // Save new task in memory at 0 position
        do {
            try context.save()
            stockList.append(taskObject)
//            print("liked after add: ",stockList)
        } catch let error as NSError  {
            print(error.localizedDescription)
        }
    }
    
    // Delete record in CoreData
    func deleteTicker(withTicker title: String) {
        let context = getContext()
                
        let fetchRequest: NSFetchRequest<StockCardLikes> = StockCardLikes.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for item in result {
                if item.ticker == title {
                    context.delete(item)
                    guard let index = stockList.firstIndex(where: {$0.ticker == title}) else {return}
                    stockList.remove(at: index)
                }
            }
        }
//        print("liked after delete: ",stockList)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        
        do {
            try context.save()
        } catch let error as NSError  {
            print(error.localizedDescription)
        }
    }
    
    // Check whether ticker liked
    func contains(ticker: String) -> Bool {
        if stockList.first(where: {$0.ticker == ticker}) != nil {
            return true
        }
        return false
    }
    
    // Clear all records in CoreData
    func clearAllLikes() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<StockCardLikes> = StockCardLikes.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError  {
            print(error.localizedDescription)
        }
        print("All likes deleted")
        stockList = []
    }
}
