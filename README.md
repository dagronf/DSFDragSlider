# DSFDragSlider

![](https://img.shields.io/github/v/tag/dagronf/DSFDragSlider) ![](https://img.shields.io/badge/macOS-10.11+-red) ![](https://img.shields.io/badge/Swift-5.0-orange.svg)
![](https://img.shields.io/badge/License-MIT-lightgrey) [![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A virtual trackpad macOS control.

![](https://github.com/dagronf/dagronf.github.io/raw/master/art/projects/DSFDragSlider/dsfdragslider.gif)

## Why

I have a project that needs the ability to change 2-dimension values (x:y or width:height for example).  The project has limited UI space so I wanted a control that acted like a trackpad for controlling 

## Features

* Dark mode support, high contrast support
* Keyboard support (use the arrow keys when the field is focussed)
* Cancelable drags (hit the ESC key during drag)
* shift-drag to temporarily increase the delta values by 10 during the drag (faster tracking)
* option-drag to temporarily decrease the delta values by 10 during the drag (slower tracking)


## Properties

All properties support Cocoa Bindings.

* `isEnabled` : Whether the control is enabled (Bool)

### Dimensions

* `minX` : The minimum x-value represented (CGFloat)
* `minY` : The minimum y-value represented (CGFloat)
* `maxX` : The maximum x-value represented (CGFloat)
* `maxY` : The maximum y-value represented (CGFloat)
* `deltaX` : The dragging x scale factor (CGFloat). The higher the value, the faster the tracking.
* `deltaY` : The dragging y scale factor (CGFloat). The higher the value, the faster the tracking.

#### Positions

* `position` : The current position (CGPoint)
* `x` : The current x position (CGFloat)
* `y` : The current y position (CGFloat)

## Delegate

The control can report updates via a supplied delegate (DSFDragSliderProtocol)

```swift
/// A drag was started at a particular point
@objc func dragSlider(_ dragSlide: DSFDragSlider, didStartDragAtPoint: CGPoint)

/// The position changed for the specified drag slider
@objc func dragSlider(_ dragSlide: DSFDragSlider, didChangePosition: CGPoint)

/// The user cancelled an active drag (using the ESC key)
@objc func dragSlider(_ dragSlide: DSFDragSlider, didCancelDragAtPoint: CGPoint)
```
## License

```
MIT License

Copyright (c) 2020 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
