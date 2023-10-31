# webp.swift

## What's This?

webp.swift the package to easy compress(decompress) WebP and *Animated* WebP images in *Swift*
 
## How To Use

```swift
import webp
// Encode UIImage to WebP data
let encoded: Data = try WebPEncoder().encode(image, config: .preset(.picture, quality: 81))
// Decode Data to UIImage
var opts = WebpDecoderOptions()
let image: UIImage = try WebPDecoder().decode(toImage: data, options: opts)
// Encode animated
let encoder = WebPAnimatedEncoder()
try encoder.create(config: .preset(.picture, quality: 81), width: width, height: height)
try encoder.addImage(image: UIImage(), duration: duration)
let imageData: Data = try encoder.encode(loopCount: 0) // 0 - means infinity 
// Incremental decoding if necessary
let incrementalDecoder = WebpIncrementalDecoder()
let image: UIImage = try incrementalDecoder.incremetallyDecode(Data(count: 10))
```
