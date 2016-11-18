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
#import <MobileCoreServices/MobileCoreServices.h>

#import "APNGImageSerialization.h"



const NSString *APNGImageErrorDomain = @"APNGImageErrorDomain";


__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data)
{
    return UIAnimatedImageWithAPNGData(data, 0.f);
}

__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, NSTimeInterval duration)
{
    return UIAnimatedImageWithAPNGData(data, duration, 0.f, NULL);
}

__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, NSTimeInterval duration, CGFloat scale, NSError * __autoreleasing * error)
{
    NSDictionary *userInfo = nil;
    UIImage *resultImage = nil;

    do {
        if (!data.length) {
            userInfo = @{NSLocalizedDescriptionKey: @"Data is empty"};
            break;
        }

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
        if (frameCount <= 1) {
            resultImage = [[UIImage alloc] initWithData:data];
        }
        else {
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
                                                     scale:scale > 0.f ? scale : [UIScreen mainScreen].scale
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
        }

        CFRelease(sourceRef);

        return resultImage;
    } while (0);


    if (error) {
        *error = [NSError errorWithDomain:APNGImageErrorDomain code:-1 userInfo:userInfo];
    }

    return resultImage;
}



__attribute((overloadable)) NSData * __nullable UIImageAPNGRepresentation(UIImage * __nonnull image) {
    return [APNGImageSerialization dataWithAnimatedImage:image
                                                   error:NULL];
}

__attribute((overloadable)) NSData * __nullable UIImageAPNGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality) {
    return [APNGImageSerialization dataWithImages:image.images ?: @[image]
                                         duration:image.duration
                                      repeatCount:0
                                          quality:compressionQuality
                                            error:NULL];
}


static NSString *APNGImageNameOfScale(NSString *name, CGFloat scale) __attribute__((const)) {
    int ratio = (int)scale;
    if (scale > 1) {
        return [NSString stringWithFormat:@"%@@%dx", name.stringByDeletingPathExtension, ratio];
    }
    return name.stringByDeletingPathExtension;
}


@implementation APNGImageSerialization

+ (NSData *)dataWithAnimatedImage:(UIImage *)image
                            error:(NSError * __autoreleasing *)error
{
    if (image.images.count > 1) {
        return [self dataWithImages:image.images
                           duration:image.duration
                              error:error];
    }
    else {
        return UIImagePNGRepresentation(image.images.firstObject ?: image);
    }
}

+ (NSData *)dataWithImages:(NSArray<UIImage *> *)images
                  duration:(NSTimeInterval)duration
               repeatCount:(NSInteger)repeatCount
                     error:(NSError *__autoreleasing *)error
{
    return [self dataWithImages:images
                       duration:duration
                    repeatCount:repeatCount
                        quality:.8f
                          error:error];
}

+ (NSData *)dataWithImages:(NSArray<UIImage *> *)images
                  duration:(NSTimeInterval)duration
                     error:(NSError *__autoreleasing *)error
{
    return [self dataWithImages:images duration:duration repeatCount:0 error:error];
}

+ (NSData *)dataWithImages:(NSArray<UIImage *> *)images
                  duration:(NSTimeInterval)duration
               repeatCount:(NSInteger)repeatCount
                   quality:(CGFloat)quality
                     error:(NSError *__autoreleasing *)error
{
    if (images.count > 1) {
        NSMutableData *imageData = [NSMutableData data];
        CGImageDestinationRef targetImage = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, kUTTypePNG, images.count, NULL);
        
        NSTimeInterval delay = duration / images.count;
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGImageDestinationAddImage(targetImage, obj.CGImage, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImagePropertyPNGDictionary: @{(__bridge NSString *)kCGImagePropertyAPNGDelayTime: @(delay)}});
        }];
        CGImageDestinationSetProperties(targetImage, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImagePropertyPNGDictionary: @{(__bridge NSString *)kCGImagePropertyAPNGLoopCount: @(repeatCount)},
                                                                                 (__bridge NSString *)kCGImageDestinationLossyCompressionQuality: @(quality)});
        if (!CGImageDestinationFinalize(targetImage)) {
            imageData = nil;
            
            if (error) {
                *error = [NSError errorWithDomain:APNGImageErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"Fail to finalize image!"}];
            }
        }
        CFRelease(targetImage);
        
        return [imageData copy];
    }
    else if (images.count == 1) {
        return UIImagePNGRepresentation(images.firstObject);
    }
    else if (error) {
        *error = [NSError errorWithDomain:APNGImageErrorDomain
                                     code:-1
                                 userInfo:@{NSLocalizedDescriptionKey: @"At least 1 image"}];
    }
    return nil;
}

@end


@implementation UIImage (Animated_PNG)

+ (UIImage *)animatedImageNamed:(NSString *)name
{
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *extension = name.pathExtension;
    if (!extension.length) {
        extension = @"png";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:APNGImageNameOfScale(name, scale)
                                                     ofType:extension];
    while (!path && scale > 0.f) {
        scale -= 1.f;
        path = [[NSBundle mainBundle] pathForResource:APNGImageNameOfScale(name, scale)
                                               ofType:extension];
    }
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return UIAnimatedImageWithAPNGData(data, 0.f, scale, NULL);
    }
    return nil;
}

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data
{
    return UIAnimatedImageWithAPNGData(data);
}

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data scale:(CGFloat)scale
{
    return UIAnimatedImageWithAPNGData(data, 0.f, scale, NULL);
}


+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data duration:(NSTimeInterval)duration
{
    return UIAnimatedImageWithAPNGData(data, duration);
}

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data
                                   duration:(NSTimeInterval)duration
                                      scale:(CGFloat)scale
{
    return UIAnimatedImageWithAPNGData(data, duration, scale, NULL);
}

@end
