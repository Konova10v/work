//
//  AppDelegate.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер on 10/07/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

	func setUpAudio() {
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playback, mode: .moviePlayback)
		}
		catch {
			print("Setting category to AVAudioSessionCategoryPlayback failed.")
		}
	}
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		setUpAudio();
		if ProcessInfo().arguments.contains("SKIP_ANIMATIONS") {
			UIView.setAnimationsEnabled(false)
		}
        // Override point for customization after application launch.
		AQ.startMonitoringRadio();
//		AQ.verbose = true
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
