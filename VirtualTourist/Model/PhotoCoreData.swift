//
//  PhotoCoreData.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 10/02/2022.
//

import Foundation

import UIKit
import CoreData

class PhotoCoreData: NSObject {
    class func addData(photoData: PhotoDetails){
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        {
            
            let myItem = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: managedObjectContext) as! Photo
            
            myItem.data  = binaryData(photoData)
//            myItem.urlString = long
            
            do {
                try managedObjectContext.save()
                
            } catch { // Replace this implementation with code to handle the error appropriately. // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }//end of check for managed object
    }
    
    class func getData()->([Photo], Data){
        var DataArr:[Photo] = []
        
        var data = Data()
                
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            
            // Add Sort Descriptor
            
            let sortDescriptorLat = NSSortDescriptor(key: "data", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorLat]
            
            do {
                DataArr = try managedObjectContext.fetch(Photo.fetchRequest())
                for i in DataArr{
                    data = i.data!
                }
            } catch {
                //print("Failed to retrieve record")
                print(error)
            }
        }
        return (DataArr, data)
    }
    
    class func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    class func deleteObject(photo: Photo){
        let context = getContext()
        context.delete(photo)
        do {
            try context.save()
        }catch{
            
        }
    }
    
}


