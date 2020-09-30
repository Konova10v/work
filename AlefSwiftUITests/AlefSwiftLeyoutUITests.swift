//
//  AlefSwiftUITests.swift
//  	UITests
//
//  Created by Станислав Гольденшлюгер on 12/07/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import XCTest

class AlefSwiftLayoutUITests: XCTestCase {

	var app = XCUIApplication()
	
    override func setUp() {
		Snapshot.setupSnapshot(self.app, waitForAnimations: false)
		app.launchEnvironment = ["isUITest":"YES"];
		app.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
		
    }

	func testScreensots() throws {
		
		XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
		
		for i in 0..<app.buttons.count {
			let title = app.buttons.element(boundBy: i).label
			print("GENERATING PORTRAIT: "+title)
			app.buttons.element(boundBy: i).tap()
			Snapshot.snapshot("portrait_\(title)", timeWaitingForIdle: 30)
			print("     GENERATING — done")
			app.buttons["UITestBackBtn"].firstMatch.tap()
			print("     GENERATING — exit");
		}
		
		XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
		
		for i in 0..<app.buttons.count {
			let title = app.buttons.element(boundBy: i).label
			print("GENERATING LANDSCAPE: "+title)
			app.buttons.element(boundBy: i).tap()
			Snapshot.snapshot("landscape_\(title)", timeWaitingForIdle: 30)
			app.buttons["UITestBackBtn"].firstMatch.tap()
		}
		
	}
   
}
