//
//  CoreData.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 10/02/2022.
//

import Foundation

import UIKit
import CoreData

class PinCoreData: NSObject {
    class func addData(lat:Double, long: Double){
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        {
            
            let myItem = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: managedObjectContext) as! Pin
            
            myItem.lat  = lat
            myItem.lng = long
            
            do {
                try managedObjectContext.save()
                
            } catch { // Replace this implementation with code to handle the error appropriately. // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }//end of check for managed object
    }
    
    class func getData()->([Pin], Double, Double){
        var DataArr:[Pin] = []
        
        var lat  = 0.0
        var lng  = 0.0
       
        
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            
            // Add Sort Descriptor
            
            let sortDescriptorLat = NSSortDescriptor(key: "lat", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorLat]
            let sortDescriptorLong = NSSortDescriptor(key: "lng", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorLong]
            
            
            
            do {
                DataArr = try managedObjectContext.fetch(Pin.fetchRequest())
                for i in DataArr{
                    lat = i.lat
                    lng = i.lng
                }
            } catch {
                //print("Failed to retrieve record")
                print(error)
            }
        }
        return (DataArr, lng, lat)
    }
    
    class func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
}

