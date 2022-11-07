// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "DSFDragSlider",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(name: "DSFDragSlider", targets: ["DSFDragSlider"]),
		.library(name: "DSFDragSlider-static", type: .static, targets: ["DSFDragSlider"]),
		.library(name: "DSFDragSlider-shared", type: .dynamic, targets: ["DSFDragSlider"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "3.3.0")
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
