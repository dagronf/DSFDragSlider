//
// DSFDragSliderProtocol.swift
//
// Copyright © 2022 Darren Ford. All rights reserved.
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(macOS)

import Foundation
import AppKit

/// Protocol for handling drag slider events
@objc public protocol DSFDragSliderProtocol: AnyObject {
	/// The position changed for the specified drag slider
	@objc func dragSlider(_ dragSlide: DSFDragSlider, didChangePosition point: CGPoint)

	/// The user cancelled an active drag (using the ESC key)
	@objc func dragSlider(_ dragSlide: DSFDragSlider, didCancelDragAtPoint point: CGPoint)

	/// A drag was completed
	@objc func dragSlider(_ dragSlide: DSFDragSlider, didEndDragAtPoint point: CGPoint)
}

#endif
