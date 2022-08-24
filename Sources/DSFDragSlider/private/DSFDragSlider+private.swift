//
// DSFDragSlider+private.swift
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
import Carbon.HIToolbox
import Foundation

import DSFAppearanceManager

// MARK: - Configuration

internal extension DSFDragSlider {
	func setup() {
		let r = DSFKeyedPanGestureRecognizer(target: self, action: #selector(self.userDidPan(_:)))
		if #available(OSX 10.12.2, *) {
			r.numberOfTouchesRequired = 1
		}
		r.delegate = self
		self.addGestureRecognizer(r)
		self.recognizer = r
	}
}

// MARK: - Drawing and layout

extension DSFDragSlider {
	override public var focusRingMaskBounds: NSRect {
		return self.bounds
	}

	override public func drawFocusRingMask() {
		let pth = NSBezierPath(roundedRect: self.bounds, xRadius: 4.5, yRadius: 4.5)
		pth.fill()
	}

	override public func layout() {
		super.layout()

		if let t = self.tracker {
			self.removeTrackingArea(t)
		}

		self.tracker = NSTrackingArea(
			rect: self.bounds,
			options: [.mouseEnteredAndExited, .activeInKeyWindow],
			owner: self,
			userInfo: nil
		)
		self.addTrackingArea(self.tracker!)
	}

	override public func draw(_ dirtyRect: NSRect) {
		self.alphaValue = self.isEnabled ? 1.0 : 0.4

		super.draw(dirtyRect)

		let rect = self.bounds.insetBy(dx: 1, dy: 1)

		// Drawing code here.

		let rectanglePath = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)

		// Trackpad area

		NSGraphicsContext.enterState {
			rectanglePath.setClip()

			if DSFAppearanceManager.IncreaseContrast {
				NSColor.textColor.setStroke()
			}
			else if self.isDarkMode {
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
				if self.isDarkMode {
					NSColor.disabledControlTextColor.setFill()
				}
				else {
					NSColor.windowBackgroundColor.setFill()
				}
			}
			else {
				if self.isDarkMode {
					NSColor(calibratedWhite: 0.2, alpha: 1.0).setFill()
				}
				else {
					NSColor(calibratedWhite: 0.85, alpha: 1.0).setFill()
				}
			}

			if !DSFAppearanceManager.IncreaseContrast {
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
				let b = DragSliderBadgePath()
				b.transform(using: AffineTransform(translationByX: self.bounds.width - 15.5, byY: 3.5))

				if self.isDarkMode {
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

			if self.isDarkMode {
				NSColor(calibratedWhite: 0.7, alpha: 1.0).setFill()
				NSColor(calibratedWhite: 1, alpha: 1.0).setStroke()
			}
			else {
				NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
				if DSFAppearanceManager.IncreaseContrast {
					NSColor.textColor.setStroke()
				}
				else {
					NSColor(calibratedWhite: 0.1, alpha: 1.0).setStroke()
				}
			}

			let c = NSBezierPath()
			c.lineWidth = DSFAppearanceManager.IncreaseContrast ? 1.0 : 0.5
			c.move(to: NSPoint(x: inset.minX, y: ypos))
			c.line(to: NSPoint(x: inset.maxX, y: ypos))
			c.move(to: NSPoint(x: xpos, y: inset.minY))
			c.line(to: NSPoint(x: xpos, y: inset.maxY))
			c.setLineDash([1, 1], count: 2, phase: 0)
			c.stroke()

			let r = NSRect(x: xpos - 3, y: ypos - 3, width: 6, height: 6)
			let b = NSBezierPath(ovalIn: r)
			b.fill()

			if self.isDarkMode {
				NSColor.white.setStroke()
			}
			else {
				NSColor.systemGray.setStroke()
			}
			b.lineWidth = DSFAppearanceManager.IncreaseContrast ? 1.0 : 0.5
			b.stroke()
		}
	}

	private func DragSliderBadgePath() -> NSBezierPath {
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
	}
}


// MARK: - User interaction

extension DSFDragSlider {

	internal var canChangeX: Bool {
		return (self.maxX - self.minX) > 0.0
	}

	internal var canChangeY: Bool {
		return (self.maxY - self.minY) > 0.0
	}

	override public var acceptsFirstResponder: Bool {
		return self.isEnabled
	}

	override public func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return self.isEnabled
	}

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

		self.lastPosition = translation

		self.needsDisplay = true
	}

	// MARK: Mouse handling

	override public func mouseEntered(with event: NSEvent) {
		guard self.isEnabled else { return }
		self.isHover = true
		NSCursor.openHand.push()

		self.needsDisplay = true
	}

	override public func mouseExited(with event: NSEvent) {
		guard self.isEnabled else { return }
		self.isHover = false
		if self.isPanning == false {
			NSCursor.pop()
		}

		self.needsDisplay = true
	}

	override public func mouseDown(with event: NSEvent) {
		guard self.isEnabled else { return }
		self.isPanning = true
		self.needsDisplay = true

		self.lastPosition = nil
		self.originalPosition = self.position // Save so we can cancel using esc
		self.isPanning = true
		NSCursor.closedHand.push()

		self.needsDisplay = true
	}

	override public func mouseUp(with event: NSEvent) {
		guard self.isEnabled else { return }

		NSCursor.pop()

		if !self.isPanning {
			return
		}

		self.isPanning = false

		self.needsDisplay = true

		self.delegate?.dragSlider(self, didEndDragAtPoint: self.position)
	}

	// MARK: key handling

	override public func keyDown(with event: NSEvent) {
		var incr: CGFloat = 1
		if event.modifierFlags.contains(.shift) { incr *= 10 }
		else if event.modifierFlags.contains(.option) { incr /= 10 }

		if event.keyCode == kVK_LeftArrow {
			if self.canChangeX {
				let nx = min(max(self.minX, self.position.x - incr), self.maxX)
				self.position.x = nx
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else if event.keyCode == kVK_RightArrow {
			if self.canChangeX {
				let nx = min(max(self.minX, self.position.x + incr), self.maxX)
				self.position.x = nx
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else if event.keyCode == kVK_UpArrow {
			if self.canChangeY {
				let ny = min(max(self.minY, self.position.y + incr), self.maxY)
				self.position.y = ny
				self.delegate?.dragSlider(self, didChangePosition: self.position)
			}
			else {
				NSSound.beep()
			}
		}
		else if event.keyCode == kVK_DownArrow {
			if self.canChangeY {
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
			// self.interpretKeyEvents([event])
		}
		self.needsDisplay = true
	}

	override public func cancelOperation(_ sender: Any?) {
		self.recognizer?.state = .cancelled
		self.isPanning = false
		if let orig = self.originalPosition {
			self.position = orig
		}

		// Tell the delegate we've reverted back to our original value
		self.delegate?.dragSlider(self, didCancelDragAtPoint: self.position)

		self.needsDisplay = true
	}

}

// MARK: - Accessibility

extension DSFDragSlider {
	override public func isAccessibilityEnabled() -> Bool {
		return true
	}

	override public func isAccessibilityElement() -> Bool {
		return true
	}

	override public func accessibilityRole() -> NSAccessibility.Role? {
		return NSAccessibility.Role.incrementor
	}

	override public func accessibilityLabel() -> String? {
		return NSLocalizedString("Infinite Scroller", comment: "")
	}
}

#endif
