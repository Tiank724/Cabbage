//
//  GifImageOverlayItem.swift
//  VFCabbage
//
//  Created by szcck006 on 2024/4/10.
//

import CoreMedia
import CoreImage

open class GifImageOverlayItem: NSObject, ImageCompositionProvider, NSCopying {
    
    public var identifier: String
    public var resource: LocalGifImageResource
    required public init(resource: LocalGifImageResource, type: ResourceType? = nil) {
        identifier = ProcessInfo.processInfo.globallyUniqueString
        self.resource = resource
        let frame = CGRect(origin: CGPoint.zero, size: resource.size)
        self.videoConfiguration.contentMode = .aspectFit
        self.videoConfiguration.frame = frame
        self.type = type
    }
    
    public var videoConfiguration: VideoConfiguration = .createDefaultConfiguration()
    public var type: ResourceType?
    
    // MARK: - NSCopying
    open func copy(with zone: NSZone? = nil) -> Any {
        let item = Swift.type(of: self).init(resource: resource.copy() as! LocalGifImageResource, type: type)
        item.identifier = identifier
        item.videoConfiguration = videoConfiguration.copy() as! VideoConfiguration
        item.startTime = startTime
        return item
    }
    
    // MARK: - ImageCompositionProvider
    
    public var startTime: CMTime = CMTime.zero
    public var duration: CMTime {
        get {
            return resource.scaledDuration
        }
    }
    
    open func applyEffect(to sourceImage: CIImage, at time: CMTime, renderSize: CGSize) -> CIImage {
        //debugPrint(">>>>>>>>>> time: \(time)")
        let relativeTime = time - timeRange.start
        guard let image = resource.image(at: relativeTime, renderSize: renderSize) else {
            return sourceImage
        }
        
        var finalImage = image
        
        let info = VideoConfigurationEffectInfo.init(time: time, renderSize: renderSize, timeRange: timeRange, type: type)
        finalImage = videoConfiguration.applyEffect(to: finalImage, info: info)

        finalImage = finalImage.composited(over: sourceImage)
        return finalImage
    }
    
}
