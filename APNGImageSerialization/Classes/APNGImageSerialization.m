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

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
#define kCGImagePropertyAPNGDelayTime           CFSTR("DelayTime")
#define kCGImagePropertyAPNGLoopCount           CFSTR("LoopCount")
#define kCGImagePropertyAPNGUnclampedDelayTime  CFSTR("UnclampedDelayTime")
#endif

NSString * const APNGImageErrorDomain = @"APNGImageErrorDomain";


#if TARGET_OS_IOS
#define APNG_SCREEN_SCALE (UIScreen.mainScreen.scale)
#elif TARGET_OS_WATCH
#define APNG_SCREEN_SCALE (WKInterfaceDevice.currentDevice.screenScale)
#endif

__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data)
{
    return UIAnimatedImageWithAPNGData(data, APNG_SCREEN_SCALE, 0.f, nil);
}

__attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, CGFloat scale, NSTimeInterval duration, NSError * __autoreleasing * error)
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
            CFRelease(sourceRef);
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

            NSDictionary *frameProperty = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, i, nil));
            NSDictionary *apngProperty = frameProperty[(__bridge NSString *)kCGImagePropertyPNGDictionary];
            NSNumber *delayTime = apngProperty[(__bridge NSString *)kCGImagePropertyAPNGUnclampedDelayTime];

            if (delayTime != nil) {
                imageDuration += [delayTime doubleValue];
            }
            else {
                delayTime = apngProperty[(__bridge NSString *)kCGImagePropertyAPNGDelayTime];
                if (delayTime != nil) {
                    imageDuration += [delayTime doubleValue];
                }
            }
            UIImage *image = [UIImage imageWithCGImage:imageRef
                                                 scale:scale > 0.f ? scale : APNG_SCREEN_SCALE
                                           orientation:UIImageOrientationUp];
            [frames addObject:image];

            CFRelease(imageRef);
        }

        CFRelease(sourceRef);

        if (duration > CGFLOAT_MIN) {
            imageDuration = duration;
        }
        else if (imageDuration < CGFLOAT_MIN) {
            imageDuration = 0.1 * frameCount;
        }

        if (frames.count <= 1) {
            resultImage = frames.firstObject;
        }
        else {
            resultImage = [UIImage animatedImageWithImages:frames.copy
                                                  duration:imageDuration];
        }
    } while (0);

    if (resultImage == nil && error != nil) {
        *error = [NSError errorWithDomain:APNGImageErrorDomain
                                     code:APNGErrorCodeNoEnoughData
                                 userInfo:userInfo];
    }

    return resultImage;
}

static BOOL AnimatedPngDataIsValid(NSData *data) {
    if (data.length > 8) {
        const unsigned char * bytes = [data bytes];

        return
            bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 &&
            bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A;
    }

    return NO;
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


static NSString *APNGImageNameOfScale(NSString *name, CGFloat scale) {
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
        if (!targetImage) {
            if (error) {
                *error = [NSError errorWithDomain:APNGImageErrorDomain
                                             code:APNGErrorCodeFailToCreate
                                         userInfo:@{NSLocalizedDescriptionKey: @"Fail to create image"}];
            }
            return nil;
        }
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
                                             code:APNGErrorCodeFailToFinalize
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
                                     code:APNGErrorCodeNoEnoughData
                                 userInfo:@{NSLocalizedDescriptionKey: @"At least 1 image"}];
    }
    return nil;
}

@end

@implementation UIImage (NamedAnimatedPNG)

+ (UIImage *)animatedImageNamed:(NSString *)name __attribute__((objc_method_family(new)))
{
    CGFloat scale = APNG_SCREEN_SCALE;
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
        if (AnimatedPngDataIsValid(data)) {
            return UIAnimatedImageWithAPNGData(data, scale, 0.f, nil);
        }
    }
    return nil;
}

@end

#pragma mark -

#ifndef ANIMATED_PNG_NO_UIIMAGE_INITIALIZER_SWIZZLING
#import <objc/runtime.h>

static inline void apng_swizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface UIImage (Animated_PNG)
@end

@implementation UIImage (Animated_PNG)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            apng_swizzleSelector(object_getClass((id)self), @selector(imageWithData:), @selector(apng_animatedImageWithAPNGData:));
            apng_swizzleSelector(object_getClass((id)self), @selector(imageWithData:scale:), @selector(apng_animatedImageWithAPNGData:scale:));
            apng_swizzleSelector(object_getClass((id)self), @selector(imageWithContentsOfFile:), @selector(apng_imageWithContentsOfFile:));
            apng_swizzleSelector(self, @selector(initWithContentsOfFile:), @selector(apng_initWithContentsOfFile:));
            apng_swizzleSelector(self, @selector(initWithData:), @selector(apng_initWithData:));
            apng_swizzleSelector(self, @selector(initWithData:scale:), @selector(apng_initWithData:scale:));
        }
    });
}

#pragma mark -

+ (UIImage *)apng_imageWithContentsOfFile:(NSString *)path __attribute__((objc_method_family(new)))
{
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (AnimatedPngDataIsValid(data)) {
            if ([[path stringByDeletingPathExtension] hasSuffix:@"@3x"]) {
                return UIAnimatedImageWithAPNGData(data, 3.0f, 0.0f, nil);
            } else if ([[path stringByDeletingPathExtension] hasSuffix:@"@2x"]) {
                return UIAnimatedImageWithAPNGData(data, 2.0f, 0.0f, nil);
            } else {
                return UIAnimatedImageWithAPNGData(data);
            }
        }
    }

    return [self apng_imageWithContentsOfFile:path];
}

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data __attribute__((objc_method_family(new)))
{
    if (AnimatedPngDataIsValid(data)) {
        return UIAnimatedImageWithAPNGData(data);
    }

    return [self apng_animatedImageWithAPNGData:data];

}

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data scale:(CGFloat)scale __attribute__((objc_method_family(new)))
{
    if (AnimatedPngDataIsValid(data)) {
        return UIAnimatedImageWithAPNGData(data, scale, 0.0f, nil);
    }

    return [self apng_animatedImageWithAPNGData:data scale:scale];
}

#pragma mark -

- (id)apng_initWithContentsOfFile:(NSString *)path __attribute__((objc_method_family(init))) {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (AnimatedPngDataIsValid(data)) {
        if ([[path stringByDeletingPathExtension] hasSuffix:@"@3x"]) {
            return UIAnimatedImageWithAPNGData(data, 3.0, 0.0f, nil);
        } else if ([[path stringByDeletingPathExtension] hasSuffix:@"@2x"]) {
            return UIAnimatedImageWithAPNGData(data, 2.0, 0.0f, nil);
        } else {
            return UIAnimatedImageWithAPNGData(data);
        }
    }

    return [self apng_initWithContentsOfFile:path];
}

- (id)apng_initWithData:(NSData *)data __attribute__((objc_method_family(init))) {
    if (AnimatedPngDataIsValid(data)) {
        return UIAnimatedImageWithAPNGData(data);
    }

    return [self apng_initWithData:data];
}

- (id)apng_initWithData:(NSData *)data
                  scale:(CGFloat)scale __attribute__((objc_method_family(init)))
{
    if (AnimatedPngDataIsValid(data)) {
        return UIAnimatedImageWithAPNGData(data, scale, 0.0f, nil);
    }

    return [self apng_initWithData:data scale:scale];
}

@end
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
#undef kCGImagePropertyAPNGDelayTime
#undef kCGImagePropertyAPNGLoopCount
#undef kCGImagePropertyAPNGUnclampedDelayTime
#endif
