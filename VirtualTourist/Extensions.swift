//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 10/02/2022.
//

import Foundation
import UIKit

extension UIImageView{
    func downloadImage(url: String, completion: @escaping (Bool, Error?)->Void){
        print(url, "sopfsdfsdF")
        if let imageurl = URL(string: url){
            let task = URLSession.shared.dataTask(with: imageurl) { data, response, error in
                guard let data = data else{
                    return
            }
                DispatchQueue.main.async {
                    if let img = UIImage(data: data){
                        self.image = img
                        completion(true, nil)
                    }else{
                        self.image = UIImage(named: "VirtualTourist_180")
                    }
                }
            }
            task.resume()
        }
    }
}
