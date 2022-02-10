//
//  VTClient.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 31/01/2022.
//

import Foundation
import UIKit

func getImages(latitude: Double, Longitude: Double ,completion: @escaping (Bool, Error?, _Data?, [UIImage]?) -> Void){
    let request = URLRequest(url: URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=7499f896ac0201eb6f8be76d0fae523d&lat=\(latitude)&lon=\(Longitude)&format=json&nojsoncallback=1&extras=url_o")!)
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
      if error != nil { // Handle error...
          return
      }
        print(String(data: data!, encoding: .utf8)!)
        
        
        let decoder = JSONDecoder()
        do{
            let model = try decoder.decode(_Data.self, from: data!)
            
            DispatchQueue.main.async {
                for i in model.photos.photo{
                    downloadImage(url: i.url_o) { boolean2, error2, images in
                        completion(true, nil, model, images)
                    }
                }
            }
            
            
            print(model.photos, "orpeore")
        }catch{
            completion(false, nil, nil, nil)
            print(error, "HEEEEH2")
        }
    }
    task.resume()
}

func downloadImage(url: String, completion: @escaping (Bool, Error?, [UIImage]?) -> Void){
    var image : UIImage = UIImage()
    var images : [UIImage] = [UIImage]()
    if let imageurl = URL(string: url){
        let task = URLSession.shared.dataTask(with: imageurl) { data, response, error in
            guard let data = data else{
                return
        }
            
            DispatchQueue.main.async {
                if let simage = UIImage(data: data){
                    images.append(simage)
                }
                
            }
        }
        task.resume()
        completion(true, nil, images)
    }
}
//Image link
//https://www.flickr.com/photos/148268138@N05/49203076068/in/00-DSC_8346/
