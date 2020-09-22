//
//  DragSlider.swift
//  SwiftUI wrapper for DSFDragSlider
//
//  Created by Darren Ford on 21/9/20.
//

// Only works for SwiftUI on macOS
#if canImport(SwiftUI) && os(macOS)

import SwiftUI

@available(macOS 10.15, *)
public struct DSFDragSliderUI: NSViewRepresentable {

	public typealias NSViewType = DSFDragSlider

	public struct Configuration {
		let rect: CGRect
		let deltaX: CGFloat
		let deltaY: CGFloat
	}

	@Binding var configuration: Configuration
	@Binding var currentPosition: CGPoint

	var dragChangedBlock: ((CGPoint) -> Void)? = nil
	var dragEndedBlock: ((CGPoint) -> Void)? = nil

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeNSView(context: Context) -> DSFDragSlider {
		let dragSlider = DSFDragSlider()
		dragSlider.rect = configuration.rect
		dragSlider.deltaX = configuration.deltaX
		dragSlider.deltaY = configuration.deltaY
		dragSlider.delegate = context.coordinator
		return dragSlider
	}

	public func updateNSView(_ nsView: DSFDragSlider, context: Context) {
		nsView.position = self.currentPosition
		nsView.rect = configuration.rect
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
	rect: CGRect(x: -1000, y: -1000, width: 2000, height: 2000),
	deltaX: 1,
	deltaY: 1)

@available(macOS 10.15, *)
struct DragSlider_Previews: PreviewProvider {
	static var previews: some View {
		DSFDragSliderUI(configuration: .constant(DemoConfig),
				   currentPosition: .constant(DemoPosition))
	}
}

#endif
