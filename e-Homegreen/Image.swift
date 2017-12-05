//
//  Image.swift
//  
//
//  Created by Vladimir Zivanov on 8/17/16.
//
//

import Foundation
import CoreData


class Image: NSManagedObject {

    convenience init(context: NSManagedObjectContext, image: Data, id: String) {
        self.init(context: context)
        self.imageData = image
        self.imageId = id
    }
// Insert code here to add functionality to your managed object subclass

}
