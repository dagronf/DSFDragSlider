//
//  DSFDragSlider.swift
//
//  Created by Darren Ford on 26/7/20.
//  Copyright © 2020 Darren Ford. All rights reserved.
//
//	MIT License
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

#if os(macOS)

import AppKit

import Carbon.HIToolbox

/// Pan gesture recognizer that passes key events to its containing view
private class DSFKeyedPanGestureRecognizer: NSPanGestureRecognizer {
	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
		self.view?.keyDown(with: event)
	}

	override func keyUp(with event: NSEvent) {
		super.keyUp(with: event)
		self.view?.keyUp(with: event)
	}

	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		self.view?.mouseDown(with:  event)
	}

	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		self.view?.mouseUp(with:  event)
	}
}

private extension NSGraphicsContext {
	static func enterState(block: () throws -> Void) rethrows -> Void {
		NSGraphicsContext.saveGraphicsState()
		defer {
			NSGraphicsContext.restoreGraphicsState()
		}
		try block()
	}
}

private extension NSView {
	func isDarkMode() -> Bool {
		if #available(*, macOS 10.14) {
			let appearance = self.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
			return appearance == .darkAqua
		}
		return self.effectiveAppearance.name != .aqua && self.effectiveAppearance.name != .vibrantLight
	}
}

@objc public protocol DSFDragSliderProtocol: class {

	/// The position changed for the specified drag slider
	@objc func dragSlider(_ dragSlide: DSFDragSlider, didChangePosition point: CGPoint)

	/// The user cancelled an active drag (using the ESC key)
	@objc func dragSlider(_ dragSlide: DSFDragSlider, didCancelDragAtPoint point: CGPoint)

	/// A drag was completed
	@objc func dragSlider(_ dragSlide: DSFDragSlider, didEndDragAtPoint point: CGPoint)
}

@IBDesignable
public class DSFDragSlider: NSView, NSGestureRecognizerDelegate {

	// Drag/Key recognizer
	private var recognizer: DSFKeyedPanGestureRecognizer?

	/// The delegate receives callbacks as the control is dragged
	public weak var delegate: DSFDragSliderProtocol?

	/// Minimum allowed X value
	@IBInspectable var minX: CGFloat = 0
	/// Maximum allowed X value
	@IBInspectable var maxX: CGFloat = 1000
	public var canChangeX: Bool {
		return (maxX - minX) > 0.0
	}

	/// Minimum allowed Y value
	@IBInspectable var minY: CGFloat = 0
	/// Maximum allowed Y value
	@IBInspectable var maxY: CGFloat = 1000
	public var canChangeY: Bool {
		return (maxY - minY) > 0.0
	}

	/// Convenience for setting extents via a rect
	public var rect: CGRect {
		get {
			return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
		}
		set {
			self.minX = newValue.minX
			self.maxX = newValue.maxX
			self.minY = newValue.minY
			self.maxY = newValue.maxY
			
			self.needsDisplay = true
		}
	}

	/// The delta recorded per pixel move
	@IBInspectable var deltaX: CGFloat = 1.0
	@IBInspectable var deltaY: CGFloat = 1.0

	@IBInspectable var isEnabled: Bool = true {
		didSet {
			self.needsDisplay = true
			self.recognizer?.isEnabled = self.isEnabled
		}
	}

	/// The current position
	@objc public dynamic var position: CGPoint = CGPoint(x: 500, y: 500) {
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
	@IBInspectable
	@objc public dynamic var x: CGFloat {
		get {
			return self.position.x
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
	@IBInspectable
	@objc public dynamic var y: CGFloat {
		get {
			return self.position.y
		}
		set {
			self.willChangeValue(for: \.position)
			let nv = min(max(minY, newValue), maxY)
			self.position.y = nv
			self.didChangeValue(for: \.position)
		}
	}

	public override var acceptsFirstResponder: Bool {
		return self.isEnabled
	}

	public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return self.isEnabled
	}

	public override var focusRingMaskBounds: NSRect {
		return self.bounds
	}

	public override func drawFocusRingMask() {
		let pth = NSBezierPath(roundedRect: self.bounds, xRadius: 4.5, yRadius: 4.5)
		pth.fill()
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	deinit {
		if let r = self.recognizer {
			self.removeGestureRecognizer(r)
			self.recognizer = nil
		}
	}

	var tracker: NSTrackingArea?

	public override func isAccessibilityEnabled() -> Bool {
		return true
	}

	public override func isAccessibilityElement() -> Bool {
		return true
	}

	public override func accessibilityRole() -> NSAccessibility.Role? {
		return NSAccessibility.Role.incrementor
	}

	public override func accessibilityLabel() -> String? {
		return NSLocalizedString("Infinite Scroller", comment: "")
	}

	private func setup() {
		let r = DSFKeyedPanGestureRecognizer(target: self, action: #selector(userDidPan(_:)))
		if #available(OSX 10.12.2, *) {
			r.numberOfTouchesRequired = 1
		}
		r.delegate = self
		self.addGestureRecognizer(r)
		self.recognizer = r
	}

	public override func layout() {
		super.layout()

		if let t = self.tracker {
			self.removeTrackingArea(t)
		}

		tracker = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(tracker!)
	}

	// Are we currently panning on the control?
	private var isPanning: Bool = false

	private var isHover: Bool = false

	// The previous position for the drag
	private var lastPosition: CGPoint?

	// The position before the user started interacting with the control
	private var originalPosition: CGPoint?

	@objc func userDidPan(_ sender: NSPanGestureRecognizer) {

		var scaleX: CGFloat = self.deltaX
		var scaleY: CGFloat = self.deltaY

		if !self.isPanning {
			return
		}

		if let event = NSApp.currentEvent {
			if event.modifierFlags.contains(.shift) { scaleX *= 10; scaleY *= 10 }
			else if event.modifierFlags.contains(.option) { scaleX /= 10; scaleY /= 10 }
		}

		let translation = sender.translation(in: self)
		if let last = lastPosition {
			let xDiff = (translation.x - last.x) * scaleX
			let yDiff = (translation.y - last.y) * scaleY

			let nx = min(max(self.minX, self.position.x + xDiff), self.maxX)
			let ny = min(max(self.minY, self.position.y + yDiff), self.maxY)
			self.position = CGPoint(x: nx, y: ny)

			self.delegate?.dragSlider(self, didChangePosition: self.position)
		}

		lastPosition = translation

		self.needsDisplay = true
	}

	public override func mouseEntered(with event: NSEvent) {
		guard self.isEnabled else { return }
		isHover = true
		NSCursor.openHand.push()

		self.needsDisplay = true
	}

	public override func mouseExited(with event: NSEvent) {
		guard self.isEnabled else { return }
		isHover = false
		if self.isPanning == false {
			NSCursor.pop()
		}

		self.needsDisplay = true
	}

	public override func mouseDown(with event: NSEvent) {
		self.isPanning = true
		self.needsDisplay = true

		lastPosition = nil
		originalPosition = self.position		// Save so we can cancel using esc
		self.isPanning = true
		NSCursor.closedHand.push()

		self.needsDisplay = true
	}

	public override func mouseUp(with event: NSEvent) {
		//let mouseLocation = self.convert(event.locationInWindow, from: nil)
		//if !self.bounds.contains(mouseLocation) {
			NSCursor.pop()
		//}

		NSCursor.pop()

		if !self.isPanning {
			return
		}

		self.isPanning = false

		self.needsDisplay = true

		self.delegate?.dragSlider(self, didEndDragAtPoint: self.position)
	}

	public override func keyDown(with event: NSEvent) {
		var incr: CGFloat = 1
		if event.modifierFlags.contains(.shift) { incr *= 10 }
		else if event.modifierFlags.contains(.option) { incr /= 10 }

		if event.keyCode == kVK_LeftArrow {
			if canChangeX {
				let nx = min(max(self.minX, self.position.x - incr), self.maxX)
				self.position.x = nx
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else if event.keyCode == kVK_RightArrow {
			if canChangeX {
				let nx = min(max(self.minX, self.position.x + incr), self.maxX)
				self.position.x = nx
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else if event.keyCode == kVK_UpArrow {
			if canChangeY {
				let ny = min(max(self.minY, self.position.y + incr), self.maxY)
				self.position.y = ny
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else if event.keyCode == kVK_DownArrow {
			if canChangeY {
				let ny = min(max(self.minY, self.position.y - incr), self.maxY)
				self.position.y = ny
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else {
			super.keyDown(with: event)
			//self.interpretKeyEvents([event])
		}
		self.needsDisplay = true
	}

	public override func cancelOperation(_ sender: Any?) {
		self.recognizer?.state = .cancelled
		self.isPanning = false
		if let orig = self.originalPosition {
			self.position = orig
		}

		// Tell the delegate we've reverted back to our original value
		self.delegate?.dragSlider(self, didCancelDragAtPoint: self.position)

		self.needsDisplay = true
	}

	public override func draw(_ dirtyRect: NSRect) {

		let shouldIncreaseContrast = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast

		self.alphaValue = self.isEnabled ? 1.0 : 0.4

		super.draw(dirtyRect)

		let rect = self.bounds.insetBy(dx: 1, dy: 1)

		// Drawing code here.

		let rectanglePath = NSBezierPath.init(roundedRect: rect, xRadius: 4, yRadius: 4)

		// Trackpad area

		NSGraphicsContext.enterState {
			rectanglePath.setClip()

			if self.isDarkMode() {
				NSColor(calibratedWhite: 0.5, alpha: 1.0).setStroke()
			}
			else {
				NSColor.white.setStroke()
			}
			rectanglePath.lineWidth = 2

			if self.isPanning {
				NSColor.windowBackgroundColor.setFill()
			}
			else if self.isHover {
				if self.isDarkMode() {
					NSColor.disabledControlTextColor.setFill()
				}
				else {
					NSColor.windowBackgroundColor.setFill()
				}
			}
			else {
				if self.isDarkMode() {
					NSColor(calibratedWhite: 0.2, alpha: 1.0).setFill()
				}
				else {
					NSColor(calibratedWhite: 0.85, alpha: 1.0).setFill()
				}
			}

			if !shouldIncreaseContrast {
				let shadow = NSShadow()
				shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
				shadow.shadowOffset = NSSize(width: 0.5, height: -0.5)
				shadow.shadowBlurRadius = 2
				shadow.set()
			}

			rectanglePath.fill()
			rectanglePath.stroke()
		}

		// Arrow Badge

		if self.isEnabled, !self.isPanning {
			NSGraphicsContext.enterState {
				let b = self.badge.copy() as! NSBezierPath
				b.transform(using: AffineTransform(translationByX: self.bounds.width - 15.5, byY: 3.5))

				if self.isDarkMode() {
					NSColor(calibratedWhite: 0.4, alpha: 1.0).setStroke()
				}
				else {
					NSColor(calibratedWhite: 0.7, alpha: 1.0).setStroke()
				}
				b.stroke()
			}
		}

		// Crosshair and button

		NSGraphicsContext.enterState {

			let inset = rect.insetBy(dx: 5, dy: 5)

			let xperc = inset.width / (maxX - minX)
			let yperc = inset.height / (maxY - minY)
			let xpos = (self.x - minX) * xperc + inset.minX
			let ypos = (self.y - minY) * yperc + inset.minY


			if self.isDarkMode() {
				NSColor(calibratedWhite: 0.7, alpha: 1.0).setFill()
				NSColor(calibratedWhite: 1, alpha: 1.0).setStroke()
			}
			else {
				NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
				NSColor(calibratedWhite: 0.4, alpha: 1.0).setStroke()
			}

			let c = NSBezierPath()
			c.lineWidth = 0.5
			c.move(to: NSPoint(x: inset.minX, y: ypos))
			c.line(to: NSPoint(x: inset.maxX, y: ypos))
			c.move(to: NSPoint(x: xpos, y: inset.minY))
			c.line(to: NSPoint(x: xpos, y: inset.maxY))
			c.setLineDash([1, 1], count: 2, phase: 0)
			c.stroke()


			let r = NSRect(x: xpos - 3, y: ypos - 3, width: 6, height: 6)
			let b = NSBezierPath(ovalIn: r)
			b.fill()

			if self.isDarkMode() {
				NSColor.white.setStroke()
			}
			else {
				NSColor.systemGray.setStroke()
			}
			b.lineWidth = 0.5
			b.stroke()
		}
	}

	//// 12 x 12
	lazy var badge: NSBezierPath = {

		let result = NSBezierPath()

		//// Bezier Drawing
		let bezierPath = NSBezierPath()
		bezierPath.move(to: NSPoint(x: 4, y: 3))
		bezierPath.line(to: NSPoint(x: 6, y: 1))
		bezierPath.line(to: NSPoint(x: 8, y: 3))
		bezierPath.lineWidth = 1
		result.append(bezierPath)

		//// Bezier 5 Drawing
		let bezier5Path = NSBezierPath()
		bezier5Path.move(to: NSPoint(x: 6, y: 10))
		bezier5Path.line(to: NSPoint(x: 6, y: 1))
		bezier5Path.lineWidth = 1
		result.append(bezier5Path)

		//// Bezier 6 Drawing
		let bezier6Path = NSBezierPath()
		bezier6Path.move(to: NSPoint(x: 1, y: 6))
		bezier6Path.line(to: NSPoint(x: 11, y: 6))
		bezier6Path.lineWidth = 1
		result.append(bezier6Path)


		//// Bezier 7 Drawing
		let bezier7Path = NSBezierPath()
		bezier7Path.move(to: NSPoint(x: 3, y: 8))
		bezier7Path.line(to: NSPoint(x: 1, y: 6))
		bezier7Path.line(to: NSPoint(x: 3, y: 4))
		bezier7Path.lineWidth = 1
		result.append(bezier7Path)


		//// Bezier 4 Drawing
		let bezier4Path = NSBezierPath()
		bezier4Path.move(to: NSPoint(x: 4, y: 9))
		bezier4Path.line(to: NSPoint(x: 6, y: 11))
		bezier4Path.line(to: NSPoint(x: 8, y: 9))
		bezier4Path.lineWidth = 1
		result.append(bezier4Path)

		//// Bezier 3 Drawing
		let bezier3Path = NSBezierPath()
		bezier3Path.move(to: NSPoint(x: 9, y: 8))
		bezier3Path.line(to: NSPoint(x: 11, y: 6))
		bezier3Path.line(to: NSPoint(x: 9, y: 4))
		bezier3Path.lineWidth = 1
		result.append(bezier3Path)

		return result
	}()

}

#endif
