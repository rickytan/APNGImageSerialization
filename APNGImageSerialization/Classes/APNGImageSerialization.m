// APNGImageSerialization.h
//
// Copyright (c) 2016 Ricky Tan
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <ImageIO/ImageIO.h>

#import "APNGImageSerialization.h"


NSString * const APNGImageErrorDomain = @"APNGImageErrorDomain";



__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, NSTimeInterval duration)
{
    return UIAnimatedImageWithAPNGData(data, duration, 1.f, NULL);
}

__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, NSTimeInterval duration, CGFloat scale, NSError * __autoreleasing * error)
{
    NSDictionary *userInfo = nil;
    UIImage *resultImage = nil;
    
    do {
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)data, nil);
        CGImageSourceStatus status = CGImageSourceGetStatus(sourceRef);
        if (status != kCGImageStatusComplete && status != kCGImageStatusIncomplete && status != kCGImageStatusReadingHeader) {
            switch (status) {
                case kCGImageStatusUnexpectedEOF: {
                    userInfo = @{NSLocalizedDescriptionKey: @"Unexpected end of file"};
                    break;
                }
                case kCGImageStatusInvalidData: {
                    userInfo = @{NSLocalizedDescriptionKey: @"Invalide data"};
                    break;
                }
                case kCGImageStatusUnknownType: {
                    userInfo = @{NSLocalizedDescriptionKey: @"Unknown type"};
                    break;
                }
                default:
                    break;
            }
            break;
        }
        
        
        size_t frameCount = CGImageSourceGetCount(sourceRef);
        NSTimeInterval imageDuration = 0.f;
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:frameCount];
        
        for (size_t i = 0; i < frameCount; ++i) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, i, nil);
            if (!imageRef) {
                continue;
            }
            
            NSDictionary *frameProperty = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(sourceRef, i, nil);
            NSDictionary *apngProperty = frameProperty[(__bridge NSString *)kCGImagePropertyPNGDictionary];
            NSNumber *delayTime = apngProperty[(__bridge NSString *)kCGImagePropertyAPNGUnclampedDelayTime];
            if (delayTime) {
                imageDuration += [delayTime doubleValue];
            }
            else {
                delayTime = apngProperty[(__bridge NSString *)kCGImagePropertyAPNGDelayTime];
                if (delayTime) {
                    imageDuration += [delayTime doubleValue];
                }
            }
            UIImage *image = [UIImage imageWithCGImage:imageRef
                                                 scale:[UIScreen mainScreen].scale
                                           orientation:UIImageOrientationUp];
            [frames addObject:image];
            
            CFRelease(imageRef);
        }
        
        if (duration > CGFLOAT_MIN) {
            imageDuration = duration;
        }
        else if (imageDuration < CGFLOAT_MIN) {
            imageDuration = 0.1 * frameCount;
        }
        
        resultImage = [UIImage animatedImageWithImages:frames.copy
                                              duration:imageDuration];
        
        return resultImage;
    } while (0);
    
    
    if (error) {
        *error = [NSError errorWithDomain:APNGImageErrorDomain code:-1 userInfo:userInfo];
    }
    
    return resultImage;
}

@implementation APNGImageSerialization


@end
