//
//  CoreImageExtension.swift
//  Cabbage
//
//  Created by Vito on 2018/11/11.
//  Copyright © 2018 Vito. All rights reserved.
//

import Foundation
import CoreImage

extension CIImage {
    
    func apply(alpha: CGFloat) -> CIImage {
        let filter = CIFilter(name: "CIColorMatrix")
        filter?.setDefaults()
        filter?.setValue(self, forKey: kCIInputImageKey)
        let alphaVector = CIVector.init(x: 0, y: 0, z: 0, w: alpha)
        filter?.setValue(alphaVector, forKey: "inputAVector")
        if let outputImage = filter?.outputImage {
            return outputImage
        }
        return self
    }
    
    func apply(blendWithMask: URL) -> CIImage {
        let filter = CIFilter(name: "CIBlendWithAlphaMask")
        filter?.setDefaults()
        
        // set the background image
        filter?.setValue(self, forKey: kCIInputImageKey)
        
        // set the mask image
        let bkgInput = CIImage(contentsOf: blendWithMask)?.scaleFillSize(to: extent)
        filter?.setValue(bkgInput, forKey: kCIInputMaskImageKey)

        if let outputImage = filter?.outputImage {
            return outputImage
        }
        return self
    }
    
    func apply(maskImage: CIImage) -> CIImage {
        let filter = CIFilter(name: "CIBlendWithAlphaMask")
        filter?.setDefaults()
        
        // set the background image
        filter?.setValue(self, forKey: kCIInputImageKey)
        
        // set the mask image
        let bkgInput = maskImage.scaleFillSize(to: extent)
        filter?.setValue(bkgInput, forKey: kCIInputMaskImageKey)

        if let outputImage = filter?.outputImage {
            return outputImage
        }
        return self
    }
    
    func scaleFillSize(to: CGRect) -> CIImage {
        let newFrame = extent.aspectTopFill(in: to)
        let transform = CGAffineTransform.transform(by: extent, aspectFillRect: newFrame)
        return transformed(by: transform).cropped(to: newFrame)
    }
}
