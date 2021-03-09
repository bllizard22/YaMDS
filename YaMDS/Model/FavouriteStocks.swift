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
//    var likedList: [String] = []
    
    init() {
        loadCoreData()
    }
    
    // Get context for app
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // Reload data from CoreData
    func loadCoreData() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<StockCardLikes> = StockCardLikes.fetchRequest()
        // Sorting of tasks list
        let sortDescriptor = NSSortDescriptor(key: "ticker", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Obtain data from context
        
        do {
            try stockList = context.fetch(fetchRequest)
            for value in stockList{
//                likedList.append(value.ticker!)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Add new record in CoreData
    func saveString(withTicker title: String) {
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "StockCardLikes", in: context) else {return}
        
        // Create new task
        let taskObject = StockCardLikes(entity: entity, insertInto: context)
        taskObject.ticker = title
        
        // Save new task in memory at 0 position
        do {
            try context.save()
            //            tasks.append(taskObject)
            stockList.insert(taskObject, at: 0)
        } catch let error as NSError  {
            print(error.localizedDescription)
        }
    }
    
    // Add new record in CoreData
    func deleteString(withTicker title: String) {
        let context = getContext()
        
        
        
        let fetchRequest: NSFetchRequest<StockCardLikes> = StockCardLikes.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for image in result {
                    context.delete(image)
                    guard let index = stockList.firstIndex(where: {$0.ticker == title}) else {return}
                    stockList.remove(at: index)
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        
        do {
            try context.save()
        } catch let error as NSError  {
            print(error.localizedDescription)
        }
    }
    
    // Clear all records in CoreData
    func clearString() {
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
        stockList = []
    }
}
