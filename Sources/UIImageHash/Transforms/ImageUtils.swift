import Foundation
import Accelerate
import AppKit

var RgbFormat8 = vImage_CGImageFormat(bitsPerComponent: 8,bitsPerPixel: 8 * 4,
                                      colorSpace: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))!

func grayscaleAndResize(cgImage: CGImage, width: Int = 32, height: Int = 32) -> vImage_Buffer? {
    
    let rgbBuffer8 = try!vImage.PixelBuffer<vImage.Interleaved8x4>(cgImage: cgImage, cgImageFormat: &RgbFormat8)
    let grayscaleBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: cgImage.width, height: cgImage.height)
    
    let divisor: Int = 0x1000
    let fDivisor = Float(divisor)
    rgbBuffer8.multiply(by: (0, Int(0.2126 * fDivisor), Int(0.7152 * fDivisor), Int(0.0722 * fDivisor)),
                        divisor: divisor,
                        preBias: (0, 0, 0, 0),
                        postBias: 0,
                        destination: grayscaleBuffer8)
    
    let resizeData = UnsafeMutablePointer<UInt8>.allocate(capacity: height * width)
    defer { resizeData.deallocate() }
    
    var resizeBuffer = vImage_Buffer(data: resizeData,
                                   height: vImagePixelCount(height),
                                   width: vImagePixelCount(width),
                                   rowBytes: width)
    
    grayscaleBuffer8.withUnsafePointerToVImageBuffer {
        vImageBufferPtr in
        _ = vImageScale_Planar8(vImageBufferPtr, &resizeBuffer, nil, vImage_Flags(kvImageHighQualityResampling))
    }
    
    return resizeBuffer
}

func resizeAndGrayscale(cgImage: CGImage, width: Int = 32, height: Int = 32) -> vImage.PixelBuffer<vImage.Planar8>? {

    let rgbBuffer8 = try!vImage.PixelBuffer<vImage.Interleaved8x4>(cgImage: cgImage, cgImageFormat: &RgbFormat8)
    let resizeRgbBuffer8 = vImage.PixelBuffer<vImage.Interleaved8x4>(width: width, height: height)
    
    rgbBuffer8.scale(destination: resizeRgbBuffer8)
    
    let grayscaleBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: width, height: height)
    
    let divisor: Int = 0x1000
    let fDivisor = Float(divisor)
    resizeRgbBuffer8.multiply(by: (0, Int(0.2126 * fDivisor), Int(0.7152 * fDivisor), Int(0.0722 * fDivisor)),
                        divisor: divisor,
                        preBias: (0, 0, 0, 0),
                        postBias: 0,
                        destination: grayscaleBuffer8)
    
    return grayscaleBuffer8
}

let GrayFormat8 = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 8,
                                       colorSpace: CGColorSpaceCreateDeviceGray(),
                                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue))!

func createUIImageFromBuffer(_ buffer: vImage.PixelBuffer<vImage.Planar8>) -> CGImage? {
    return buffer.makeCGImage(cgImageFormat: GrayFormat8)!
}

func createUIImageFromBuffer(_ buffer: vImage_Buffer) -> CGImage? {
    guard let cgImgResult = try? buffer.createCGImage(format: GrayFormat8) else { return nil }
    return cgImgResult
}

func loadImageFromResource(named imageName: String, imagetype: String = "png") -> NSImage? {
    let imagePath = Bundle.main.path(forResource: imageName, ofType: imagetype)
    let image = NSImage(contentsOfFile: imagePath!)
    return image
}

enum ImageSaveError: Error {
    case failedToSave
    case invalidImageData
    case failedToCreateFileURL
}

func saveImageSimulator(image: NSImage, named imageName: String) -> Result<String, Error> {
    guard let data = image.pngData() else {
        return .failure(ImageSaveError.invalidImageData)
    }
    
    let savePath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    let fileURL = savePath?.appendingPathComponent(imageName)
    
    do {
        if let fileURL = fileURL {
            try data.write(to: fileURL)
            return .success(fileURL.path)
        } else {
            return .failure(ImageSaveError.failedToCreateFileURL)
        }
    } catch {
        return .failure(ImageSaveError.failedToSave)
    }
}
