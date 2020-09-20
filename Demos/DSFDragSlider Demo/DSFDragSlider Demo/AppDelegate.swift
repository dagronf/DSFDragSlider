//
//  AppDelegate.swift
//  DSFDragSlider Demo
//
//  Created by Darren Ford on 20/9/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!

	@IBOutlet weak var dragSlider: DSFDragSlider!

	@IBOutlet weak var dragSlider2: DSFDragSlider!
	@IBOutlet weak var xValue: NSTextField!
	@IBOutlet weak var yValue: NSTextField!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application

		dragSlider2.delegate = self
		self.xValue.doubleValue = Double(dragSlider2.x)
		self.yValue.doubleValue = Double(dragSlider2.y)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}

extension AppDelegate: DSFDragSliderProtocol {
	func dragSlider(_ dragSlide: DSFDragSlider, didStartDragAtPoint point: CGPoint) {
		Swift.print("Start Drag (\(point))")
	}

	func dragSlider(_ dragSlide: DSFDragSlider, didChangePosition point: CGPoint) {
		self.xValue.doubleValue = Double(point.x)
		self.yValue.doubleValue = Double(point.y)
	}

	func dragSlider(_ dragSlide: DSFDragSlider, didCancelDragAtPoint point: CGPoint) {
		Swift.print("Drag cancelled (\(point))")
	}

	func dragSlider(_ dragSlide: DSFDragSlider, didEndDragAtPoint point: CGPoint) {
		Swift.print("Drag ended (\(point))")
	}
}
