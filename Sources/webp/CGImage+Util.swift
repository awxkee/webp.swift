import Foundation

#if canImport(CoreGraphics)
import CoreGraphics

#if os(macOS)
import AppKit
public typealias WebPPlatformImage = NSImage
#else
import UIKit
public typealias WebPPlatformImage = UIImage
#endif

#if SWIFT_PACKAGE
import webpbridge
#endif

extension CGImage {
    func getBaseAddress() throws -> UnsafeMutablePointer<UInt8> {
        guard let dataProvider = dataProvider,
            let data = dataProvider.data else {
            throw WebPError.unexpectedPointerError
        }
        // This downcast always succeeds
        let mutableData = data as! CFMutableData
        return CFDataGetMutableBytePtr(mutableData)
    }
    
    func getBaseAddressUnpremultiplied() throws -> UnsafeMutablePointer<UInt8> {
        guard let dataProvider = dataProvider,
            let data = dataProvider.data else {
            throw WebPError.unexpectedPointerError
        }
        let unpremultiplied = WebpRGBAMultiplier.unpremultiply((data as NSData) as Data, width: self.width, height: self.height)
        let mutableData = unpremultiplied as! CFMutableData
        return CFDataGetMutableBytePtr(mutableData)
    }
}
#endif
