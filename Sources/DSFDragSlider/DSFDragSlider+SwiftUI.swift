//
// DSFDragSlider+SwiftUI.swift
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

#if canImport(SwiftUI) && os(macOS)

import AppKit
import SwiftUI

@available(macOS 10.15, *)
public struct DSFDragSliderUI: NSViewRepresentable {

	public typealias NSViewType = DSFDragSlider

	public struct Configuration {
		let range: CGRect
		let deltaX: CGFloat
		let deltaY: CGFloat

		public init(range: CGRect, deltaX: CGFloat, deltaY: CGFloat) {
			self.range = range
			self.deltaX = deltaX
			self.deltaY = deltaY
		}
	}

	@Binding var configuration: Configuration
	@Binding var currentPosition: CGPoint
	let isEnabled: Bool

	private var dragChangedBlock: ((CGPoint) -> Void)? = nil
	private var dragEndedBlock: ((CGPoint) -> Void)? = nil

	public init(
		configuration: Binding<Configuration>,
		currentPosition: Binding<CGPoint>,
		dragChangedBlock: ((CGPoint) -> Void)? = nil,
		dragEndedBlock: ((CGPoint) -> Void)? = nil
	) {
		self.isEnabled = true
		self._configuration = configuration
		self._currentPosition = currentPosition
		self.dragChangedBlock = dragChangedBlock
		self.dragEndedBlock = dragEndedBlock
	}

	// Modifier for enabling/disabling the control
	public func disabled(_ disabled: Bool) -> some View {
		return DSFDragSliderUI(
			isEnabled: !disabled,
			configuration: self.$configuration,
			currentPosition: self.$currentPosition,
			dragChangedBlock: self.dragChangedBlock,
			dragEndedBlock: self.dragEndedBlock
		)
	}
}

@available(macOS 10.15, *)
extension DSFDragSliderUI {
	internal init(
		isEnabled: Bool,
		configuration: Binding<Configuration>,
		currentPosition: Binding<CGPoint>,
		dragChangedBlock: ((CGPoint) -> Void)? = nil,
		dragEndedBlock: ((CGPoint) -> Void)? = nil
	) {
		self.isEnabled = isEnabled
		self._configuration = configuration
		self._currentPosition = currentPosition
		self.dragChangedBlock = dragChangedBlock
		self.dragEndedBlock = dragEndedBlock
	}
}

@available(macOS 10.15, *)
extension DSFDragSliderUI {
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeNSView(context: Context) -> DSFDragSlider {
		let dragSlider = DSFDragSlider()
		dragSlider.isEnabled = self.isEnabled
		dragSlider.range = configuration.range
		dragSlider.deltaX = configuration.deltaX
		dragSlider.deltaY = configuration.deltaY
		dragSlider.delegate = context.coordinator
		return dragSlider
	}

	public func updateNSView(_ nsView: DSFDragSlider, context: Context) {
		nsView.isEnabled = self.isEnabled
		nsView.position = self.currentPosition
		nsView.range = configuration.range
		nsView.deltaX = configuration.deltaX
		nsView.deltaY = configuration.deltaY
	}

	public class Coordinator: NSObject, DSFDragSliderProtocol {
		let parent: DSFDragSliderUI
		init(_ slider: DSFDragSliderUI) {
			self.parent = slider
		}

		public func dragSlider(_ dragSlide: DSFDragSlider, didChangePosition point: CGPoint) {
			parent.currentPosition = point
			parent.dragChangedBlock?(point)
		}

		public func dragSlider(_ dragSlide: DSFDragSlider, didCancelDragAtPoint point: CGPoint) {
			Swift.print("drag cancelled...")
		}

		public func dragSlider(_ dragSlide: DSFDragSlider, didEndDragAtPoint point: CGPoint) {
			parent.currentPosition = point
			parent.dragEndedBlock?(point)
		}
	}
}

//////////
@available(macOS 10.15, *)
let DemoPosition = CGPoint(x: 0, y: 0)

@available(macOS 10.15, *)
let DemoConfig = DSFDragSliderUI.Configuration(
	range: CGRect(x: -1000, y: -1000, width: 2000, height: 2000),
	deltaX: 1,
	deltaY: 1)

@available(macOS 10.15, *)
struct DragSlider_Previews: PreviewProvider {
	static var previews: some View {
		DSFDragSliderUI(
			configuration: .constant(DemoConfig),
			currentPosition: .constant(DemoPosition)
		)
		DSFDragSliderUI(
			configuration: .constant(DemoConfig),
			currentPosition: .constant(DemoPosition)
		)
		.disabled(true)
	}
}

#endif
