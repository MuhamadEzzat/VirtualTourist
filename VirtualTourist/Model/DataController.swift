//
//  DataController.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 10/02/2022.
//

import Foundation
import CoreData

class DataController{
    let peresistentContainter : NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        
        return peresistentContainter.viewContext
    }
    
    init (modelname: String){
        peresistentContainter = NSPersistentContainer(name: modelname)
    }
    
    func load(completion: (() -> Void)? = nil){
        peresistentContainter.loadPersistentStores { storerdDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            
            completion?()
        }
        
    }
}
