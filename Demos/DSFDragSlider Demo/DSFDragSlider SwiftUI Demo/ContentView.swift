//
//  ContentView.swift
//  DSFDragSlider SwiftUI Demo
//
//  Created by Darren Ford on 21/9/20.
//

import SwiftUI

struct ContentView: View {

	@State private var isState1 = true
	private static let state1 = DSFDragSliderUI.Configuration(
		rect: CGRect(x: -1000, y: -1000, width: 2000, height: 2000),
		deltaX: 1,
		deltaY: 1
	)
	private static let state2 = DSFDragSliderUI.Configuration(
		rect: CGRect(x: 0, y: 0, width: 100, height: 100),
		deltaX: 0.5,
		deltaY: 0.5
	)

	////

	@State var config = state1
	@State private var position = CGPoint(x: 0, y: 0)

	var config2 = DSFDragSliderUI.Configuration(
		rect: CGRect(x: 0, y: 0, width: 512, height: 512),
		deltaX: 1,
		deltaY: 1
	)
	@State private var position2 = CGPoint(x: 200, y: 350)

	@State private var xValue: String = "200.00"
	@State private var yValue: String = "350.00"

	var body: some View {
		VStack {
			DSFDragSliderUI(
				configuration: $config,
				currentPosition: $position,
				dragChangedBlock: { point in
					Swift.print("changed point = \(point)")
				},
				dragEndedBlock: { point in
					Swift.print("ended point = \(point)")
				}
			)
			.padding()

			Text("\(String(format: "X = %.02f, Y = %.02f", self.position.x, self.position.y))")

			HStack {
				Button("Reset") {
					self.position = CGPoint(x: 0, y: 0)
				}

				Button("Change") {
					if isState1 {
						self.config = ContentView.state2
					}
					else {
						self.config = ContentView.state1
					}
					self.position = CGPoint(x: 0, y: 0)
					isState1.toggle()
				}
			}
			.padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))

			HStack {
				DSFDragSliderUI(
					configuration: .constant(config2),
					currentPosition: $position2,
					dragChangedBlock: { point in
						xValue = String(format: "%.02f", point.x)
						yValue = String(format: "%.02f", point.y)
					},
					dragEndedBlock: { point in
						Swift.print("ended point = \(point)")
					}
				)
				.frame(width: 51, height: 51, alignment: .center)
				VStack {
					TextField(
						"X Value", text: $xValue,
						onCommit: {
							let v = Float(xValue)
							position2.x = CGFloat(v ?? 0)
						}
					)
					TextField(
						"Y Value", text: $yValue,
						onCommit: {
							let v = Float(xValue)
							position2.x = CGFloat(v ?? 0)
						}
					)
				}
			}
			.padding()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
