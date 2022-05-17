import Foundation

#if os(macOS) || os(iOS)
import CoreGraphics

extension WebPDecoder {
    public func decode(_ webPData: Data, options: WebpDecoderOptions) throws -> CGImage {
        let feature = try WebpImageInspector.inspect(webPData)
        let height: Int = Int(options.useScaling ? Int(Int32(options.scaledHeight)) : feature.height)
        let width: Int = Int(options.useScaling ? Int(Int32(options.scaledWidth)) : feature.width)

        let decodedData: CFData = try decode(byRGBA: webPData, options: options) as CFData
        guard let provider = CGDataProvider(data: decodedData) else {
            throw WebPError.unexpectedError(withMessage: "Couldn't initialize CGDataProvider")
        }

        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let renderingIntent = CGColorRenderingIntent.defaultIntent
        let bytesPerPixel = 4

        if let cgImage = CGImage(width: width,
                                 height: height,
                                 bitsPerComponent: 8,
                                 bitsPerPixel: 8 * bytesPerPixel,
                                 bytesPerRow: bytesPerPixel * width,
                                 space: colorSpace,
                                 bitmapInfo: bitmapInfo,
                                 provider: provider,
                                 decode: nil,
                                 shouldInterpolate: false,
                                 intent: renderingIntent) {
            return cgImage
        }

        throw WebPError.unexpectedError(withMessage: "Couldn't initialize CGImage")
    }
}
#endif

extension WebPDecoder {
    public func decode(toImage webPData: Data, options: WebpDecoderOptions) throws -> WebPPlatformImage {
        let cgImage: CGImage = try decode(webPData, options: options)
#if os(iOS)
        return WebPPlatformImage(cgImage: cgImage)
#else
        return WebPPlatformImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
#endif
    }
}
