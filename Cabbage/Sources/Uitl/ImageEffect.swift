//
//  ImageEffect.swift
//  VFCabbage
//
//  Created by szcck006 on 2024/4/9.
//

import Foundation
import CoreImage

/*
 
public extension ImageEffect {
    static var all: [ImageEffect] = [
//        ImageEffect(name: ""),
//        ImageEffect(name: "CIPhotoEffectChrome"), // 应用一组预先配置的效果，模仿具有夸张色彩的老式摄影胶片
//        ImageEffect(name: "CIPhotoEffectFade"), // 应用一组预先配置的效果，模仿色彩减弱的老式摄影胶片
        //ImageEffect(name: "CIPhotoEffectInstant"), // 应用一组预先配置的效果，模仿具有扭曲颜色的老式摄影胶片
        //ImageEffect(name: "CIPhotoEffectMono"), // 应用一组预配置的效果来模仿低对比度的黑白摄影胶片
        //ImageEffect(name: "CIPhotoEffectNoir"), // 应用一组预先配置的效果，模仿具有夸张对比度的黑白摄影胶片
        //ImageEffect(name: "CIPhotoEffectProcess"), // 应用一组预配置的效果，模仿复古摄影胶片，强调冷色调
        //ImageEffect(name: "CIPhotoEffectTonal"), // 应用一组预先配置的效果来模仿黑白摄影胶片，而不会显着改变对比度
        //ImageEffect(name: "CIPhotoEffectTransfer"), // 应用一组预配置的效果，模仿复古摄影胶片，强调暖色
//        ImageEffect(name: "CILinearToSRGBToneCurve"), // 将颜色强度从线性伽马曲线映射到sRGB颜色空间
//        ImageEffect(name: "CISRGBToneCurveToLinear"), // 将颜色强度从sRGB颜色空间映射到线性伽玛曲线
        //ImageEffect(name: "CISepiaTone"), // 将图像的颜色映射为各种深浅的棕色
        
//        ImageEffect(name: "CIVignette"), // 降低图像边缘的亮度
//        ImageEffect(name: "CISharpenLuminance"), // 通过锐化增加图像细节
//        ImageEffect(name: "CIUnsharpMask"), // 增加图像中不同颜色像素之间的边缘对比度
        
//        ImageEffect(name: "CIMedianFilter"), // 计算一组相邻像素的中值，并用中值替换每个像素值
//        ImageEffect(name: "CINoiseReduction"), // 使用阈值来定义什么被视为噪声来减少噪声
        
//        ImageEffect(name: "CIColorControls"), // 调整饱和度、亮度和对比度值
//        ImageEffect(name: "CIExposureAdjust"), // 调整图像的曝光设置，类似于更改光圈值时控制相机曝光的方式
        ImageEffect(name: "CIStraightenFilter"), // 将源图像旋转指定的弧度角度
        
        //ImageEffect(name: "CIBloom"), // 柔化边缘并为图像带来宜人的光泽
        //ImageEffect(name: "CIDepthOfField"), // 模拟景深效果
        
        //ImageEffect(name: "CIHighlightShadowAdjust"), // 调整图像的色调映射，同时保留空间细节
    ]
    
    /**
     CICircularWrap
     CIGlassDistortion
     CIStretchCrop
     
     CIAffineTransform
     CICrop
     CILanczosScaleTransform
     CIStraightenFilter
     
     CIBlendWithAlphaMask   // 使用蒙版中的 Alpha 值在图像和背景之间进行插值
     CIBlendWithMask  // 使用灰度蒙版中的值在图像和背景之间进行插值
     
     CIComicEffect  // 通过勾勒边缘并应用颜色半色调效果来模拟漫画书绘画
     CIConvolution3X3  // 通过执行 3x3 矩阵卷积来修改像素值
     CICrystallize
     CIGloom
     
     CIHeightFieldFromMask  // 从灰度蒙版产生连续的三维、阁楼形状的高度场
     CILineOverlay
     CIPixellate
     CIShadedMaterial  // 从高度场生成阴影图像
     */
    
    var filter: CIFilter? {
        if !name.isEmpty {
            let filter = CIFilter(name: name)
            filter?.setDefaults()
            if name == "CIColorControls" {
                filter?.setValue(NSNumber(value: Double.random(in: 0.45...0.55)), forKey: kCIInputBrightnessKey) // 亮度
                filter?.setValue(NSNumber(value: Double.random(in: 0.45...0.55)), forKey: kCIInputContrastKey)   // 对比度
                filter?.setValue(NSNumber(value: Double.random(in: 0.45...0.55)), forKey: kCIInputSaturationKey) // 饱和度
            }
            else if name == "CIExposureAdjust" {
                filter?.setValue(NSNumber(value: Double.random(in: 0.45...0.55)), forKey: kCIInputEVKey)
            }
            else if name == "CIStraightenFilter" {
                filter?.setValue(NSNumber(value: Double.random(in: -0.1...0.1) * Double.pi), forKey: kCIInputAngleKey)
            }
            return filter
        }
        return nil
    }
}
 */

public enum CSVideoSplitDirection: String {
    case horizontal, vertical
}

public extension CIImage {
    /// 裁切尺寸
    func cropSize(withHorizontalPadding value: Float) -> CIImage? {
        let width = extent.width - CGFloat(value) * 2
        //let height = width * extent.height / extent.width
        //let cropped = cropped(to: extent.insetBy(dx: CGFloat(value), dy: (extent.height - height) / 2.0))
        let cropped = cropped(to: extent.insetBy(dx: CGFloat(value), dy: CGFloat(value) / extent.width * extent.height))
        
        // resize
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")
        resizeFilter?.setValue(cropped, forKey: kCIInputImageKey)
        resizeFilter?.setValue(extent.width / width, forKey: kCIInputScaleKey)
        return resizeFilter?.outputImage
    }
    
    /// 缩放尺寸
    func scaleSize(withHorizontalPadding value: CGFloat, frame: CGRect) -> CIImage {
        var newFrame = frame
        if value > 0.0 {
            newFrame = frame.insetBy(dx: value, dy: value / frame.width * frame.height)
        }
        let transform = CGAffineTransform.transform(by: extent, aspectFillRect: newFrame)
        return transformed(by: transform).cropped(to: newFrame)
    }
    
    func scaleSize(to: CGRect) -> CIImage {
        let newFrame = extent.aspectFit(in: to)
        let transform = CGAffineTransform.transform(by: extent, aspectFillRect: newFrame)
        return transformed(by: transform).cropped(to: newFrame)
    }
}

public extension CIImage {
    /// 高斯模糊
    func gaussianBlur(frame: CGRect, horizontalPadding: CGFloat = 0.0) -> CIImage? {
        let gaussianFilter = CIFilter(name: "CIGaussianBlur")
        gaussianFilter?.setValue(self, forKey: kCIInputImageKey)
        gaussianFilter?.setValue(10.0, forKey: kCIInputRadiusKey)
        if var bgImage = gaussianFilter?.outputImage {
            /// 背景图，裁切由模糊引起的黑边
            /*
            let transform = CGAffineTransform.transform(by: bgImage.extent, aspectFillRect: frame)
            bgImage = bgImage.transformed(by: transform).cropped(to: frame)
             */
            if let outputImage = bgImage.cropSize(withHorizontalPadding: 5) {
                bgImage = outputImage
            }
                        
            /// 前景图
            let frontImage = scaleSize(withHorizontalPadding: horizontalPadding, frame: frame)
            
            // 图层叠加
            let compFilter = CIFilter(name: "CISourceOverCompositing")
            compFilter?.setValue(frontImage, forKey: kCIInputImageKey)
            compFilter?.setValue(bgImage, forKey: kCIInputBackgroundImageKey)
            return compFilter?.outputImage
        }
        return nil
    }
    
    /// splitTwoImage
    func splitTwoImage(frame: CGRect, direction: CSVideoSplitDirection = .horizontal, filters: [CIFilter?] = []) -> CIImage? {
        var (image1, image2) = splitImage(with: direction, frame: frame)
        
        /// 添加滤镜
        if let first = filters.first, let filter = first {
            if let output = image1.apply(filter) {
                image1 = output
            }
            
            if let output = image2.apply(filter) {
                image2 = output
            }
        }
        
        // 图层叠加
        let compFilter = CIFilter(name: "CISourceOverCompositing")
        compFilter?.setValue(image1, forKey: kCIInputImageKey)
        compFilter?.setValue(image2, forKey: kCIInputBackgroundImageKey)
        return compFilter?.outputImage
    }
    
    private func splitImage(with direction: CSVideoSplitDirection, frame: CGRect) -> (CIImage, CIImage) {
        var image1: CIImage
        var image2: CIImage
        switch direction {
        //case .auto:
            //(image1, image2) = splitImage(with: Bool.random() ? .horizontal : .vertical, frame: frame)
        case .horizontal:
            /// 左视图
            let leftFrame = CGRect(x: 0, y: 0, width: frame.width / 2, height: frame.height)
            image1 = scaleSize(withHorizontalPadding: 0, frame: leftFrame)
            
            /// 右视图
            let rightFrame = CGRect(x: frame.width / 2, y: 0, width: frame.width / 2, height: frame.height)
            image2 = scaleSize(withHorizontalPadding: 0, frame: rightFrame)
        case .vertical:
            /// 上视图
            let leftFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2)
            image1 = scaleSize(withHorizontalPadding: 0, frame: leftFrame)
            
            /// 下视图
            let rightFrame = CGRect(x: 0, y: frame.height / 2, width: frame.width, height: frame.height / 2)
            image2 = scaleSize(withHorizontalPadding: 0, frame: rightFrame)
        }
        return (image1, image2)
    }
}

/// 滤镜
/// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
public extension CIImage {
    /// 调整旋转角度 Rotates the source image by the specified angle in radians.
    static func angleFilter(inputAngle: CGFloat = 0.0, random: Bool = true) -> CIFilter? {
        let filter = CIFilter(name: "CIStraightenFilter")
        if !random {
            filter?.setValue(NSNumber(value: inputAngle), forKey: kCIInputAngleKey)
        }
        else {
            filter?.setValue(NSNumber(value: Double.random(in: -0.1...0.1) * Double.pi), forKey: kCIInputAngleKey)
        }
        return filter
    }
    
    /// 调整曝光度 Adjusts the exposure setting for an image similar to the way you control exposure for a camera when you change the F-stop.
    static func exposureAdjustFilter(inputEV: CGFloat = 0.5, random: Bool = true) -> CIFilter? {
        let filter = CIFilter(name: "CIExposureAdjust")
        if !random {
            filter?.setValue(NSNumber(value: inputEV), forKey: kCIInputEVKey)
        }
        else {
            filter?.setValue(NSNumber(value: Double.random(in: 0.45...0.55)), forKey: kCIInputEVKey)
        }
        return filter
    }
    
    /// 调整亮度、对比度、饱和度 Adjusts saturation, brightness, and contrast values.
    static func colorControlsFilter(saturation: CGFloat? = nil, brightness: CGFloat? = nil, contrast: CGFloat? = nil, random: Bool = true) -> CIFilter? {
        let filter = CIFilter(name: "CIColorControls")
        if !random {
            // 饱和度
            if let saturation {
                filter?.setValue(NSNumber(value: saturation), forKey: kCIInputBrightnessKey)
            }
            
            // 亮度
            if let brightness {
                filter?.setValue(NSNumber(value: brightness), forKey: kCIInputBrightnessKey)
            }
            
            // 对比度
            if let contrast {
                filter?.setValue(NSNumber(value: contrast), forKey: kCIInputBrightnessKey)
            }
        }
        else {
            filter?.setValue(NSNumber(value: Double.random(in: 0.05...0.1)), forKey: kCIInputBrightnessKey)
            filter?.setValue(NSNumber(value: Double.random(in: 0.05...0.1)), forKey: kCIInputContrastKey)
            filter?.setValue(NSNumber(value: Double.random(in: 0.05...0.1)), forKey: kCIInputSaturationKey)
        }
        return filter
    }
    
    static func randomBuiltinFilter() -> CIFilter {
        let filters = [
            //#CIFilter(name: "CILinearToSRGBToneCurve"),  // 将颜色强度从线性伽马曲线映射到sRGB颜色空间
            //#CIFilter(name: "CISRGBToneCurveToLinear"),  // 将颜色强度从sRGB颜色空间映射到线性伽玛曲线
            CIFilter(name: "CIVignette"),               // 降低图像边缘的亮度
            CIFilter(name: "CISharpenLuminance"),       // 通过锐化增加图像细节
            CIFilter(name: "CIUnsharpMask"),            // 增加图像中不同颜色像素之间的边缘对比度
            CIFilter(name: "CIMedianFilter"),           // 计算一组相邻像素的中值，并用中值替换每个像素值
            CIFilter(name: "CINoiseReduction"),         // 使用阈值来定义什么被视为噪声来减少噪声
//            colorControlsFilter(random: true)
        ]
        return  filters[Int.random(in: 0..<filters.count)]!
    }
    
    func apply(_ filter: CIFilter) -> CIImage? {
        filter.setValue(self , forKey: kCIInputImageKey)
        return filter.outputImage
    }
}
