//
//  VTClient.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 31/01/2022.
//

import Foundation
import UIKit

class VTClient{
        
    init() {}
    
    func getImages(latitude: Double, Longitude: Double, page:Int,completion: @escaping (Bool, Error?, _Data?, [UIImage]?) -> Void){
        let request = URLRequest(url: URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=7499f896ac0201eb6f8be76d0fae523d&lat=\(latitude)&lon=\(Longitude)&format=json&nojsoncallback=1&extras=url_m&per_page=20&page=\(page)")!)
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
                    completion(true, nil, model, nil)
                    
                    // Save Images in Coredata
                }
                
            }catch{
                completion(false, nil, nil, nil)
            }
        }
        task.resume()
    }
    
    func downloadImage(url: String, image: UIImageView?, completion: @escaping (Bool, Error?, Data)->Void){
        
        if let imageurl = URL(string: url){
            let task = URLSession.shared.dataTask(with: imageurl) { data, response, error in
                guard let data = data else{
                    return
            }
                completion(true, nil, data)
            }
            task.resume()
        }
    }

}
