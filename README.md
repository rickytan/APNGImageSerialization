# APNGImageSerialization

[![CI Status](http://img.shields.io/travis/rickytan/APNGImageSerialization.svg?style=flat)](https://travis-ci.org/rickytan/APNGImageSerialization)
[![Version](https://img.shields.io/cocoapods/v/APNGImageSerialization.svg?style=flat)](http://cocoapods.org/pods/APNGImageSerialization)
[![License](https://img.shields.io/cocoapods/l/APNGImageSerialization.svg?style=flat)](http://cocoapods.org/pods/APNGImageSerialization)
[![Platform](https://img.shields.io/cocoapods/p/APNGImageSerialization.svg?style=flat)](http://cocoapods.org/pods/APNGImageSerialization)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Xcode 7+
* iOS 8+

## Usage

### Decode

```objective-c
self.imageView.image = [UIImage animatedImageNamed:@"clock"];
```

### Encode

```objcective-c
NSData *data = UIImageAPNGRepresentation(image);
[data writeToFile:path atomically:YES];
```

## Installation

APNGImageSerialization is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "APNGImageSerialization"
```

## Author

Ricky Tan, ricky.tan.xin@gmail.com

## License

APNGImageSerialization is available under the MIT license. See the LICENSE file for more info.
