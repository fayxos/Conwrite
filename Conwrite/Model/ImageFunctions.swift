//
//  ImageFunctions.swift
//  Handwritting
//
//  Created by Felix Haag on 13.08.21.
//

import Foundation
import UIKit

func getResizedImage(image: UIImage, imgWidth: Double, imgHeight: Double) -> UIImage {
    
    var imageHeight = imgHeight
    var imageWidth = imgWidth
        
    let width = Double(image.size.width.native)
    let height = Double(image.size.height.native)
    
    
    // scale image
    if width > height {
        let ratio = height / width
        imageHeight = Double(imageWidth) * Double(ratio)
    } else if height > width {
        let ratio = width / height
        imageWidth = Double(imageHeight) * Double(ratio)
    }
    
    let resizedImage = UIImage.scaleImageToSize(img: image, size: CGSize(width: imageWidth, height: imageHeight))
    
    return resizedImage
}
