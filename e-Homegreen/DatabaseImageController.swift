//
//  DatabaseImageController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 8/17/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseImageController: NSObject {
    
    static let shared = DatabaseImageController()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    func getImageById(_ id:String) -> Image? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Image.fetchRequest()
        
        fetchRequest.predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [NSPredicate(format: "imageId == %@", id)]
        )
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Image] {
                    if fetResults.count != 0 { return fetResults.first }
                }
                
            }
            
        } catch {}
        
        return nil
    }

}
