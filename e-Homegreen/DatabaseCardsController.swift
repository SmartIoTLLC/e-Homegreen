//
//  DatabaseCardsController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 9/12/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseCardsController: NSObject {
    
    static let shared = DatabaseCardsController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getCardsByGateway(gateway: Gateway) -> [Card] {
        let fetchRequest = NSFetchRequest(entityName: "Card")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Card]
            return fetResults!
        } catch  {
        }
        return []
    }
    
    func createCard(id: Int, cardId: String?, cardName: String?, moduleAddress: Int, gateway: Gateway, isEnabled:Bool = true, timerAddress:Int = 0, timerId:Int = 0){
        var itExists = false
        var existingCard:Card?
        let cardArray = fetchCardWithIdAndAddress(id, gateway: gateway, moduleAddress: moduleAddress)
        if cardArray.count > 0 {
            existingCard = cardArray.first
            itExists = true
        }
        if !itExists {
            let card = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: appDel.managedObjectContext!) as! Card
            card.id = id
            
            
            card.cardId = ""
            card.isEnabled = isEnabled
            card.timerAddress = timerAddress
            card.timerId = timerId
            
            if let cardName = cardName {
                card.cardName = cardName
            }else{
                card.cardName = ""
            }
            
            card.address = moduleAddress
            
            card.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            if let cardName = cardName {
                existingCard!.cardName = cardName
            }
            
            if let cardId = cardId{
                existingCard!.cardId = cardId
            }else{
                existingCard!.cardId = ""
            }
            
            existingCard!.isEnabled = isEnabled
            existingCard!.timerAddress = timerAddress
            existingCard!.timerId = timerId
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func fetchCardWithIdAndAddress(cardId: Int, gateway: Gateway, moduleAddress:Int) -> [Card]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: String(Flag))
        let predicateLocation = NSPredicate(format: "id == %@", NSNumber(integer: cardId))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(integer: moduleAddress))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Card]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    
    

}
