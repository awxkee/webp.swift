//
//  Header.h
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import <Foundation/Foundation.h>

#import "TargetConditionals.h"

#if TARGET_OS_MAC
#import <AppKit/AppKit.h>
#define WebPImage   NSImage
#else
#import <UIKit/UIKit.h>
#define WebPImage   UIImage
#endif

@interface WebpSpecialDecoderResult : NSObject
@property (nonatomic) WebPImage* _Nullable image;
@end

@interface WebpSpecialDecoder : NSObject;
-(nullable id)init:(NSError * _Nullable* _Nullable)error;
-(nullable WebpSpecialDecoderResult*)incremetallyDecodeData:(nonnull NSData*)chunk error:(NSError *_Nullable*_Nullable)error;
@end
