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

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const APNGImageErrorDomain;

typedef NS_ENUM(NSInteger, APNGErrorCode) {
    APNGErrorCodeFailToCreate       = -1,
    APNGErrorCodeFailToFinalize     = -2,
    APNGErrorCodeNoEnoughData       = -3,
};

/**
 *  These functions decode a APNG format data into a @b animated @cUIImage
 *
 *  @param data The APNG data
 *
 *  @return A animated UIImage
 */
UIKIT_EXTERN __attribute((overloadable)) UIImage * _Nullable UIAnimatedImageWithAPNGData(NSData *data);

UIKIT_EXTERN __attribute((overloadable)) UIImage * _Nullable UIAnimatedImageWithAPNGData(NSData *data, CGFloat scale, NSTimeInterval duration, NSError *  __nullable __autoreleasing * error);


/**
 *  return animated image as APNG format data, if image has only one frame, return as PNG
 */
UIKIT_EXTERN __attribute((overloadable)) NSData * __nullable UIImageAPNGRepresentation(UIImage * image);
/**
 *
 *
 *  @param image The animated image
 *  @param compressionQuality range form 0.0 ~ 1.0, while 0 mean max compression, it will cost more memory and return less data
 *
 *  @return the raw data representation this image
 */
UIKIT_EXTERN __attribute((overloadable)) NSData * __nullable UIImageAPNGRepresentation(UIImage * image, CGFloat compressionQuality);


@interface APNGImageSerialization : NSObject

+ (NSData * __nullable)dataWithAnimatedImage:(UIImage *)image
                                       error:(NSError * __nullable __autoreleasing * )error;

+ (NSData * __nullable)dataWithImages:(NSArray <UIImage *> *)images
                             duration:(NSTimeInterval)duration
                                error:(NSError * __nullable __autoreleasing *)error;

+ (NSData * __nullable)dataWithImages:(NSArray <UIImage *> *)images
                             duration:(NSTimeInterval)duration
                          repeatCount:(NSInteger)repeatCount
                                error:(NSError * __nullable __autoreleasing *)error;

+ (NSData * __nullable)dataWithImages:(NSArray <UIImage *> *)images
                             duration:(NSTimeInterval)duration
                          repeatCount:(NSInteger)repeatCount
                              quality:(CGFloat)quality
                                error:(NSError * __nullable __autoreleasing *)error;
@end

@interface UIImage (NamedAnimatedPNG)

/**
 *  Load and return a animated @c UIImage from main bundle, **DO NOT** put your apng file into Image Assets Catalog,
 *  it is @b NOT supported !
 *
 *  @param name image name with out @b @2x @b @3x subfix
 *
 *  @return A new animated image
 */
+ (UIImage * __nullable)animatedImageNamed:(NSString *)name __attribute__((objc_method_family(new)));

@end

NS_ASSUME_NONNULL_END
