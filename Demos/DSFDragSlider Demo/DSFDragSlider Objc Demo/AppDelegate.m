//
//  AppDelegate.m
//  DSFDragSlider Objc Demo
//
//  Created by Darren Ford on 21/9/20.
//

#import "AppDelegate.h"

@import DSFDragSlider;

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@property (weak) IBOutlet DSFDragSlider *dragSlider1;
@property (weak) IBOutlet DSFDragSlider *dragSlider2;
@property (weak) IBOutlet DSFDragSlider *dragSlider3;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application

	self.dragSlider1.position = CGPointMake(200, 400);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction)randomPressed:(id)sender {

	CGFloat rx = arc4random_uniform(1000.0) - 500.0;
	CGFloat ry = arc4random_uniform(1000.0) - 500.0;

	self.dragSlider1.position = CGPointMake(rx, ry);
}

- (IBAction)resetPressed:(id)sender {
	self.dragSlider1.position = CGPointMake(0, 0);
}

@end
