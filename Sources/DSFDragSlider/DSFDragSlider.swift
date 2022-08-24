//
// DSFDragSlider.swift
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

import AppKit

/// A 2d-position selector
@IBDesignable
public class DSFDragSlider: NSView, NSGestureRecognizerDelegate {
	/// The delegate receives callbacks as the control is dragged
	@objc public weak var delegate: DSFDragSliderProtocol?

	/// Is the control enabled?
	@IBInspectable var isEnabled: Bool = true {
		didSet {
			self.needsDisplay = true
			self.recognizer?.isEnabled = self.isEnabled
		}
	}

	/// Minimum allowed X value
	@IBInspectable var minX: CGFloat = 0
	/// Maximum allowed X value
	@IBInspectable var maxX: CGFloat = 1000

	/// Minimum allowed Y value
	@IBInspectable var minY: CGFloat = 0
	/// Maximum allowed Y value
	@IBInspectable var maxY: CGFloat = 1000

	/// Convenience for getting/setting the range via a rect
	@objc public var range: CGRect {
		get {
			return CGRect(x: self.minX, y: self.minY, width: self.maxX - self.minX, height: self.maxY - self.minY)
		}
		set {
			self.minX = newValue.minX
			self.maxX = newValue.maxX
			self.minY = newValue.minY
			self.maxY = newValue.maxY

			self.needsDisplay = true
		}
	}

	/// The delta recorded per horizontal pixel move
	@IBInspectable var deltaX: CGFloat = 1.0
	/// The delta recorded per vertical pixel move
	@IBInspectable var deltaY: CGFloat = 1.0

	/// The current position
	@objc public dynamic var position = CGPoint(x: 500, y: 500) {
		willSet {
			self.willChangeValue(for: \.x)
			self.willChangeValue(for: \.y)
		}

		didSet {
			self.didChangeValue(for: \.x)
			self.didChangeValue(for: \.y)
			self.needsDisplay = true
		}
	}

	/// The current X value for the control
	@objc public dynamic var x: CGFloat {
		get {
			self.position.x
		}
		set {
			self.willChangeValue(for: \.position)
			let nv = min(max(minX, newValue), maxX)
			self.position.x = nv
			self.didChangeValue(for: \.position)
			self.needsDisplay = true
		}
	}

	/// The current Y value for the control
	@objc public dynamic var y: CGFloat {
		get {
			self.position.y
		}
		set {
			self.willChangeValue(for: \.position)
			let nv = min(max(minY, newValue), maxY)
			self.position.y = nv
			self.didChangeValue(for: \.position)
		}
	}

	@objc override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	@objc public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	// Private

	deinit {
		if let r = self.recognizer {
			self.removeGestureRecognizer(r)
			self.recognizer = nil
		}
	}

	// Drag/Key recognizer
	internal var recognizer: DSFKeyedPanGestureRecognizer?

	// Mouse tracker
	internal var tracker: NSTrackingArea?

	// Are we currently panning on the control?
	internal var isPanning = false

	internal var isHover = false

	// The previous position for the drag
	internal var lastPosition: CGPoint?

	// The position before the user started interacting with the control
	internal var originalPosition: CGPoint?
}

#endif
