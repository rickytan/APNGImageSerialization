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



FOUNDATION_EXTERN NSString *const APNGImageErrorDomain;

/**
 *  These functions decode a APNG format data into a @banimated @cUIImage
 *
 *  @param NSData The APNG data
 *
 *  @return A animated UIImage
 */
UIKIT_EXTERN __attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data);

UIKIT_EXTERN __attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, NSTimeInterval duration);
UIKIT_EXTERN __attribute((overloadable)) UIImage * UIAnimatedImageWithAPNGData(NSData *data, NSTimeInterval duration, CGFloat scale, NSError * __autoreleasing * error);



UIKIT_EXTERN NSData * __nullable UIImageAPNGRepresentation(UIImage * __nonnull image);



@interface APNGImageSerialization : NSObject

+ (NSData *)dataWithAnimatedImage:(UIImage *)image
                            error:(NSError * __autoreleasing * )error;

+ (NSData *)dataWithImages:(NSArray <UIImage *> *)images
                  duration:(NSTimeInterval)duration
                     error:(NSError *__autoreleasing *)error;

+ (NSData *)dataWithImages:(NSArray <UIImage *> *)images
                  duration:(NSTimeInterval)duration
               repeatCount:(NSInteger)repeatCount
                     error:(NSError *__autoreleasing *)error;
@end


@interface UIImage (Animated_PNG)

/**
 *  Load and return a animated @c UIImage from main bundle, **DO NOT** put your apng file into Image Assets Catalog,
 *  it is @b NOT supported !
 *
 *  @param name image name with out @b @2x @b @3x subfix
 *
 *  @return A new animated image
 */
+ (UIImage *)animatedImageNamed:(NSString *)name;

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data;

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data
                                   duration:(NSTimeInterval)duration;

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data
                                      scale:(CGFloat)scale;

+ (UIImage *)apng_animatedImageWithAPNGData:(NSData *)data
                                   duration:(NSTimeInterval)duration
                                      scale:(CGFloat)scale;

@end
