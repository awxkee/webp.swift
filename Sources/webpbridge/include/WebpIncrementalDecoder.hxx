//
//  Header.h
//  
//
//  Created by Radzivon Bartoshyk on 18/05/2022.
//

#import <Foundation/Foundation.h>

#import "TargetConditionals.h"

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#define WebPImage   NSImage
#else
#import <UIKit/UIKit.h>
#define WebPImage   UIImage
#endif

@interface WebpIncrementalDecoderResult : NSObject
@property (nonatomic) WebPImage* _Nullable image;
@end

@interface WebpIncrementalDecoder : NSObject;
-(nonnull id)init;
-(nullable WebpIncrementalDecoderResult*)incremetallyDecodeData:(nonnull NSData*)chunk error:(NSError *_Nullable*_Nullable)error;
@end
