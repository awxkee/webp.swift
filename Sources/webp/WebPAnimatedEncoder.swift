//
//  WebPAnimatedEncoder.swift
//  Document Scanner
//
//  Created by Radzivon Bartoshyk on 04/05/2022.
//

import Foundation
import webpbridge

public struct WebPAnimatedEncoderError: Error, Equatable { }
public struct WebPAnimatedEncoderStateError: Error, Equatable { }

public class WebPAnimatedEncoder {
    
    private var encoder: OpaquePointer? = nil
    
    private var opts = WebPAnimEncoderOptions()
    private var animConfig = WebPAnimEncoderOptions()
    
    private var config: WebpEncoderConfig = WebpEncoderConfig.preset(.picture, quality: 80)
    
    private var timestamp: Int32 = 0
    private var originWidth: Int32 = 0
    private var originHeight: Int32 = 0
    
    public func create(config: WebpEncoderConfig, width: Int, height: Int) throws {
        finalize()
        self.config = config
        self.originWidth = Int32(width)
        self.originHeight = Int32(height)
        encoder = WebPAnimEncoderNew(Int32(width), Int32(height), &opts)
        if encoder == nil {
            throw WebPAnimatedEncoderError()
        }
    }
    
    public func addImage(image: WebPPlatformImage, duration: Int) throws {
        guard let encoder = encoder else {
            throw WebPAnimatedEncoderStateError()
        }

        var picture = WebPPicture()
        if WebPPictureInit(&picture) == 0 {
            throw WebPEncoderError.invalidParameter
        }
        
        let cgImage = try convertUIImageToCGImageWithRGBA(image)
        let stride = cgImage.bytesPerRow
        let address = try cgImage.getBaseAddress()

        picture.use_argb = config.lossless == 0 ? 0 : 1
        picture.width = Int32(originWidth)
        picture.height = Int32(originHeight)
        var ok = WebPPictureImportRGBA(&picture, address, Int32(stride))
        if ok == 0 {
            WebPPictureFree(&picture)
            throw WebPEncoderError.versionMismatched
        }

        if originWidth != picture.width && originHeight != picture.height {
            if (WebPPictureRescale(&picture, Int32(originWidth), Int32(originHeight)) == 0) {
                throw WebPEncodeStatusCode.outOfMemory
            }
        }
        
        var cfg = config.rawValue
        ok = WebPAnimEncoderAdd(encoder, &picture, timestamp, &cfg)
        WebPPictureFree(&picture)
        if ok == 0 {
            throw WebPEncoderError.invalidParameter
        }
        timestamp = timestamp + Int32(duration)
    }
    
    public func encode(loopCount: Int = 0) throws -> Data {
        guard let encoder = encoder else {
            throw WebPAnimatedEncoderStateError()
        }
        var ok = WebPAnimEncoderAdd(encoder, nil, timestamp, nil)
        if ok == 0 {
            throw WebPEncoderError.encodingImageError
        }
        var webpData = WebPData()
        WebPDataInit(&webpData)
        
        ok = WebPAnimEncoderAssemble(encoder, &webpData)
        if ok == 0 {
            throw WebPEncoderError.encodingImageError
        }
        
        finalize()
        
        if loopCount > 0 {
            do {
                try setLoopCount(loopCount: Int32(loopCount), webpData: &webpData)
            } catch {
                WebPDataClear(&webpData)
                throw error
            }
        }
        
        let data = Data(bytes: webpData.bytes, count: webpData.size)
        WebPDataClear(&webpData)
        return data
    }
    
    private func setLoopCount(loopCount: Int32, webpData: inout WebPData) throws {
        let mux = WebPMuxCreate(&webpData, 1)
        
        if mux == nil {
            throw WebPEncoderError.invalidParameter
        }
        var animParams = WebPMuxAnimParams()
        var features: UInt32 = 0
        var err = WebPMuxGetFeatures(mux, UnsafeMutablePointer(&features))
        if err != WEBP_MUX_OK {
            WebPMuxDelete(mux)
            throw WebPEncoderError.invalidParameter
        }
        err = WebPMuxGetAnimationParams(mux, &animParams)
        if err != WEBP_MUX_OK {
            WebPMuxDelete(mux)
            throw WebPEncoderError.invalidParameter
        }
        animParams.loop_count = loopCount
        WebPMuxSetAnimationParams(mux, &animParams)
        if err != WEBP_MUX_OK {
            WebPMuxDelete(mux)
            throw WebPEncoderError.invalidParameter
        }
        WebPDataClear(&webpData)
        err = WebPMuxAssemble(mux, &webpData)
        WebPMuxDelete(mux)
        if err != WEBP_MUX_OK {
            throw WebPEncoderError.invalidParameter
        }
    }
    
    private func finalize() {
        if encoder != nil {
            WebPAnimEncoderDelete(encoder)
        }
        encoder = nil
        timestamp = 0
        opts = WebPAnimEncoderOptions()
        animConfig = WebPAnimEncoderOptions()
    }
    
    deinit {
        finalize()
    }
    
}
