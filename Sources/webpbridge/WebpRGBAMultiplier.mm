//
//  WebpRGBAMultiplier.m
//  
//
//  Created by Radzivon Bartoshyk on 27/05/2022.
//

#import <Foundation/Foundation.h>
#import "WebpRGBAMultiplier.hxx"
#import <Accelerate/Accelerate.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation WebpRGBAMultiplier

+(nullable NSData*)premultiply:(nonnull NSData*)data width:(NSInteger)width height:(NSInteger)height {
    auto newBytes = [WebpRGBAMultiplier premultiplyBytes:(unsigned char*)data.bytes width:width height:height];
    auto returningData = [[NSData alloc] initWithBytesNoCopy:newBytes length:width*height*4 deallocator:^(void * _Nonnull bytes, NSUInteger length) {
        free(bytes);
    }];
    return returningData;
}

+(nullable unsigned char*)premultiplyBytes:(nonnull unsigned char*)data width:(NSInteger)width height:(NSInteger)height {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    vImage_Buffer src = {
        .data = static_cast<void*>(data),
        .width = width,
        .height = height,
        .rowBytes = width * 4
    };
    
    vImage_Buffer dest = {
        .data = malloc(width * height * 4),
        .width = width,
        .height = height,
        .rowBytes = width * 4
    };
    auto vEerror = vImagePremultiplyData_RGBA8888(&src, &dest, kvImageNoFlags);
    if (vEerror != kvImageNoError) {
        free(src.data);
        free(dest.data);
        CGColorSpaceRelease(colorSpace);
        return nullptr;
    }
    
    free(src.data);
    CGColorSpaceRelease(colorSpace);
    return reinterpret_cast<unsigned char*>(dest.data);
}

+(nullable unsigned char*)unpremultiplyBytes:(nonnull unsigned char*)data width:(NSInteger)width height:(NSInteger)height {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    vImage_Buffer src = {
        .data = (void*)data,
        .width = width,
        .height = height,
        .rowBytes = width * 4
    };
    
    vImage_Buffer dest = {
        .data = malloc(width * height * 4),
        .width = width,
        .height = height,
        .rowBytes = width * 4
    };
    auto vEerror = vImageUnpremultiplyData_RGBA8888(&src, &dest, kvImageNoFlags);
    if (vEerror != kvImageNoError) {
        free(src.data);
        free(dest.data);
        CGColorSpaceRelease(colorSpace);
        return nullptr;
    }
    
    free(src.data);
    CGColorSpaceRelease(colorSpace);
    return reinterpret_cast<unsigned char*>(dest.data);
}

+(nullable NSData*)unpremultiply:(nonnull NSData*)data width:(NSInteger)width height:(NSInteger)height {
    auto unpremultipliedBytes = [WebpRGBAMultiplier unpremultiplyBytes:(unsigned char*)data.bytes width:width height:height];
    auto returningData = [[NSData alloc] initWithBytesNoCopy:unpremultipliedBytes length:width*height*4 deallocator:^(void * _Nonnull bytes, NSUInteger length) {
        free(bytes);
    }];
    return returningData;
}
@end
