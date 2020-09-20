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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

