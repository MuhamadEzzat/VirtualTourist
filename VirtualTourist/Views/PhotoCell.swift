//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 10/02/2022.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        // still visible on screen (window's view hierarchy)
        if self.window != nil { return }

        img.image = nil
    }
}
