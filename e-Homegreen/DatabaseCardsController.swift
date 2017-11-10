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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getCardsByGateway(_ gateway: Gateway) -> [Card] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Card]
            return fetResults!
        } catch {}
        
        return []
    }
    
    func createCard(_ id: Int, cardId: String?, cardName: String?, moduleAddress: Int, gateway: Gateway, isEnabled:Bool = true, timerAddress:Int = 0, timerId:Int = 0) {
        var itExists = false
        var existingCard:Card?
        let cardArray = fetchCardWithIdAndAddress(id, gateway: gateway, moduleAddress: moduleAddress)
        if cardArray.count > 0 { existingCard = cardArray.first; itExists = true }
        
        if !itExists {
            let card = NSEntityDescription.insertNewObject(forEntityName: "Card", into: appDel.managedObjectContext!) as! Card
            card.id = NSNumber(value: id)
            
            card.cardId = ""
            card.isEnabled = isEnabled as NSNumber
            card.timerAddress = NSNumber(value: timerAddress)
            card.timerId = NSNumber(value: timerId)
            if let cardName = cardName { card.cardName = cardName } else { card.cardName = "" }
            card.address = NSNumber(value: moduleAddress)
            
            card.gateway = gateway
            CoreDataController.sharedInstance.saveChanges()
            
        } else {
            
            if let cardName = cardName { existingCard!.cardName = cardName }
            if let cardId = cardId { existingCard!.cardId = cardId } else { existingCard!.cardId = "" }
            existingCard!.isEnabled = isEnabled as NSNumber
            existingCard!.timerAddress = NSNumber(value: timerAddress)
            existingCard!.timerId = NSNumber(value: timerId)
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func fetchCardWithIdAndAddress(_ cardId: Int, gateway: Gateway, moduleAddress:Int) -> [Card] {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        let predicateLocation = NSPredicate(format: "id == %@", NSNumber(value: cardId as Int))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(value: moduleAddress as Int))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Card]
            return fetResults!
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    
    

}
