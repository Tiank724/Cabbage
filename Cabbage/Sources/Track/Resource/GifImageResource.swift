//
//  LocalGifImageResource.swift
//  VFCabbage
//
//  Created by szcck006 on 2024/4/11.
//

import ImageIO
import CoreMedia

/// Provide a Image as video frame
open class LocalGifImageResource: BaseResource {
    
    public convenience init(gifName: String, duration: CMTime) {
        let (images, times, size) = LocalGifImageResource.parseGif(with: gifName)
        self.init(images: images, times: times, size: size, duration: duration)
    }
    
    public init(images: [CGImage], times: [CMTime], size: CGSize, duration: CMTime) {
        super.init()
        self.images = images.map({ CIImage(cgImage: $0) })
        self.times = times
        self.status = .avaliable
        self.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: duration)
        self.size = size
        self.duration = duration
    }
    
    required public init() {
        super.init()
    }
    
    public var gifDuration: CMTime {
        get {
            return times.last ?? .zero
        }
    }
        
    open var images: [CIImage] = []
    
    open var times: [CMTime] = []
    
    open override func image(at time: CMTime, renderSize: CGSize) -> CIImage? {
        let second = time.seconds.truncatingRemainder(dividingBy: gifDuration.seconds)
        //debugPrint("====== \(second), \(gifDuration.seconds)")
        guard let index = times.map({ $0.seconds }).firstIndex(where: { $0 >= second }) else {
            return nil
        }
        //debugPrint(second, index)
        return images[index]
    }
    
    // MARK: - NSCopying
    open override func copy(with zone: NSZone? = nil) -> Any {
        let resource = super.copy(with: zone) as! LocalGifImageResource
        resource.images = images
        return resource
    }
}

public extension LocalGifImageResource {
    // 获取GIF图片的每一帧
    static func parseGif(with name: String) -> ([CGImage], [CMTime], CGSize) {
        var images: [CGImage] = [] // CGImage数组（存放每一帧的图片）
        var times: [CMTime] = [] // DelayTime数组（存放每一帧的图片的时间）
        var totalTime: Double = 0.0
        var size: CGSize = .zero
        if let url = Bundle.main.url(forResource: (name as NSString).deletingPathExtension, withExtension: (name as NSString).pathExtension),
            let gifSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
            // GIF图片个数
            let imageCount = CGImageSourceGetCount(gifSource)
            
            for i in 0..<imageCount { // 获取每一帧图片
                if let imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, nil) {
                    images.append(imageRef)
                    let ciImage = CIImage(cgImage: imageRef)
                    size = CGSize(width: ciImage.extent.width, height: ciImage.extent.height)
                }

                // 解析每一帧图片
                if let sourceDict = CGImageSourceCopyPropertiesAtIndex(gifSource, i, nil) as? Dictionary<String, Any>,
                   let gifDict = sourceDict[String(kCGImagePropertyGIFDictionary)] as? NSDictionary {
                    var frameDuration: Double = 0.0
                    if let delayTime = gifDict[String(kCGImagePropertyGIFUnclampedDelayTime)] as? NSNumber {
                        frameDuration = delayTime.doubleValue
                    }
                    else if let delayTime = gifDict[String(kCGImagePropertyGIFDelayTime)] as? NSNumber {
                        frameDuration = delayTime.doubleValue
                    }
                    
                    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
                    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
                    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082> for more information.
                    if frameDuration < 0.011 {
                        frameDuration = 0.1
                    }
                    totalTime += frameDuration
                    
                    let time = CMTime(seconds: totalTime, preferredTimescale: 600)
                    times.append(time)
                }
            }
        }
        //debugPrint(times)
        return (images, times, size)
    }
}
