// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFDragSlider",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(
			name: "DSFDragSlider",
			type: .static,
			targets: ["DSFDragSlider"]
		),
		.library(
			name: "DSFDragSlider-Dynamic",
			type: .dynamic,
			targets: ["DSFDragSlider"]
		),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "3.0.0")
	],
	targets: [
		.target(
			name: "DSFDragSlider",
			dependencies: ["DSFAppearanceManager"]),
		.testTarget(
			name: "DSFDragSliderTests",
			dependencies: ["DSFDragSlider"]),
	]
)
