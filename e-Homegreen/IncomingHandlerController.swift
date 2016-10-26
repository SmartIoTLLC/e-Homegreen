//
//  IncomingHandlerController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/24/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class IncomingHandlerController: NSObject {

    static let shared = IncomingHandlerController()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func fetchDeviceByGateway(_ gateway: Gateway, address: Int) -> [Device]? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway == %@", gateway)]
        predicateArray.append(NSPredicate(format: "address == %@", NSNumber(value: address)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Device]
            if fetResults.count > 0 {
                return fetResults
            }
        } catch {
            
        }
        return nil
    }
    
    func fetchDeviceByGatewayAndChannelAndAddress(_ gateway: Gateway, address: Int, channel: Int) -> Device? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway == %@", gateway)]
        predicateArray.append(NSPredicate(format: "address == %@", NSNumber(value: address)))
        predicateArray.append(NSPredicate(format: "channel == %@", NSNumber(value: channel)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Device]
            if fetResults.count > 0 {
                return fetResults[0]
            }
        } catch {
            
        }
        return nil
    }
    
    func fetchDevicesByGatewayAndAddress(_ gateway: Gateway, address: Int) -> [Device] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway == %@", gateway)]
        predicateArray.append(NSPredicate(format: "address == %@", NSNumber(value: address)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Device]
            
            return fetResults
            
        } catch {
            
        }
        return []
    }
    
    
}
