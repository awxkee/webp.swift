//
//  WebpSpecialDecoder.m
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import "WebpSpecialDecoder.hxx"
#import "decode.h"

@implementation WebpSpecialDecoder {
    WebPDecoderConfig config;
    WebPDecBuffer* outputBuffer;
    WebPBitstreamFeatures* bitstream;
    WebPIDecoder* iDecoder;
}

-(void)dealloc {
    WebPFreeDecBuffer(outputBuffer);
    WebPIDelete(iDecoder);
}

-(nullable id)init:(NSError *_Nullable*_Nullable)error {
    outputBuffer = &config.output;
    bitstream = &config.input;
    if (!WebPInitDecoderConfig(&config)) {
        *error = [[NSError alloc] initWithDomain:@"WebpSpecialDecoder" code:500 userInfo:@{ NSLocalizedDescriptionKey: @"Invalid WebP library version"}];
        return nil;
    }
    outputBuffer->colorspace = MODE_RGBA;
    iDecoder = WebPINewDecoder(outputBuffer);
    if (!iDecoder) {
        *error = [[NSError alloc] initWithDomain:@"WebpSpecialDecoder" code:500 userInfo:@{ NSLocalizedDescriptionKey: @"Can't create Decoder for requested `Config`"}];
        return nil;
    }
    return self;
}

-(nullable WebpSpecialDecoderResult*)incremetallyDecodeData:(nonnull NSData*)chunk error:(NSError *_Nullable*_Nullable)error {
    VP8StatusCode status = WebPIUpdate(iDecoder, (uint8_t*)chunk.bytes, chunk.length);
    if (status != VP8_STATUS_OK && status != VP8_STATUS_SUSPENDED) {
        *error = [[NSError alloc] initWithDomain:@"WebpSpecialDecoder" code:500 userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An error has occured with code: %d", status]}];
        return nil;
    }
    int lastY = 0;
    int width = 0;
    int height = 0;
    int stride = 0;
    void* rgbaBuffer = WebPIDecGetRGB(iDecoder, &lastY, &width, &height, &stride);
    if (rgbaBuffer == nullptr || lastY == 0 || width == 0 || height == 0 || stride == 0) {
        return [[WebpSpecialDecoderResult alloc] init];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int flags = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGContextRef gtx = CGBitmapContextCreate(rgbaBuffer, width, height, 8, stride, colorSpace, flags);
    if (gtx == NULL) {
        *error = [[NSError alloc] initWithDomain:@"WebpSpecialDecoder" code:500 userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An error has occured while decoding"]}];
        return nil;
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(gtx);
    WebPImage *image = nil;
#if TARGET_OS_MAC
    image = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero];
#else
    image = [UIImage imageWithCGImage:imageRef scale:1 orientation: UIImageOrientationUp];
#endif

    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    
    auto result = [[WebpSpecialDecoderResult alloc] init];
    result.image = image;
    
    return result;
}

@end
