//
//  WebpRGBAMultiplier.h
//  
//
//  Created by Radzivon Bartoshyk on 27/05/2022.
//

#import "Foundation/Foundation.h"

@interface WebpRGBAMultiplier: NSObject
+(nullable NSData*)premultiply:(nonnull NSData*)data width:(NSInteger)width height:(NSInteger)height;
+(nullable NSData*)unpremultiply:(nonnull NSData*)data width:(NSInteger)width height:(NSInteger)height;
+(nullable unsigned char*)premultiplyBytes:(nonnull unsigned char*)data width:(NSInteger)width height:(NSInteger)height;
+(nullable unsigned char*)unpremultiplyBytes:(nonnull unsigned char*)data width:(NSInteger)width height:(NSInteger)height;
@end
