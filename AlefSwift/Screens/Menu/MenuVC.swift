//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import SideMenuSwift

class MenuVC: BaseVC {
	// это ссылка на наш view, но с правильным классом
    override var v: MenuView! { return self.view as? MenuView }
	@IBOutlet private var notificationsLbl: UILabel!
	
	func monitorLogout() {
		NotificationCenter.default.addObserver(forName: .init(rawValue: AQ.notificationRequestFinished), object: nil, queue: nil) { (n) in
			if let result = n.userInfo?["result"] as? [String: Any?] {
				if result[AQ.fields.status] as? Int ?? 1 == 403 {
					DispatchQueue.main.async {
						UserDefaults.standard.set(false, forKey: "userIsAuthorized")
						UserDefaults.standard.synchronize()
						self.showLoginModal()
					}
				}
			}
		}
		
		NotificationCenter.default.addObserver(forName: .init(rawValue: "loggedOut"), object: nil, queue: nil) { (n) in
			DispatchQueue.main.async {
				UserDefaults.standard.set(false, forKey: "userIsAuthorized")
				UserDefaults.standard.synchronize()
				self.showLoginModal()
			}
		}
	}

	
	func setupSideMenuPreferences() {
		SideMenuController.preferences.basic.position = .sideBySide
		SideMenuController.preferences.basic.menuWidth = 300
		SideMenuController.preferences.basic.statusBarBehavior = .fade
		SideMenuController.preferences.basic.supportedOrientations = .all
	}
	
	func setupViewControllers() {
		sideMenuController?.cache(viewControllerGenerator: {
			UIStoryboard(name: "Search", bundle: nil).instantiateInitialViewController()
		}, with: "Search")
		
		sideMenuController?.cache(viewControllerGenerator: {
			UIStoryboard(name: "News", bundle: nil).instantiateInitialViewController()
		}, with: "News")
		
		sideMenuController?.cache(viewControllerGenerator: {
			UIStoryboard(name: "Groups", bundle: nil).instantiateInitialViewController()
		}, with: "Groups")
		
		sideMenuController?.cache(viewControllerGenerator: {
			UIStoryboard(name: "HtmlArticle", bundle: nil).instantiateInitialViewController()
		}, with: "Info")
		
		sideMenuController?.cache(viewControllerGenerator: {
			let nav = UIStoryboard(name: "Users", bundle: nil).instantiateInitialViewController() as! UINavigationController
			let vc = nav.viewControllers.first! as! UsersVC
			vc.setScreenModeToFollowers(user: 0)
			return nav
		}, with: "Users.Followers")
		
		sideMenuController?.cache(viewControllerGenerator: {
			let nav = UIStoryboard(name: "Users", bundle: nil).instantiateInitialViewController() as! UINavigationController
			let vc = nav.viewControllers.first! as! UsersVC
			vc.setScreenModeToStaff()
			return nav
		}, with: "Users.Staff")
		
		sideMenuController?.cache(viewControllerGenerator: {
			let vc = UIStoryboard(name: "Notifications", bundle: nil).instantiateInitialViewController()
			return vc
		}, with: "Notifications")
		
		sideMenuController?.cache(viewControllerGenerator: {
			let nav = UIStoryboard(name: "News", bundle: nil).instantiateInitialViewController() as! UINavigationController
			let vc = nav.viewControllers.first! as! NewsVC
			vc.setScreenModeToProfile(user: 0)
			return nav
		}, with: "News.MyProfile")
	
	}
	
	func showLoginModal() {
		if let vc = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController() {
			self.present(vc, animated: true, completion: {
				self.newsBtnPressed(self)
			})
		}
	}
	
	func setupNotificationCounter() {
		updateNotificationCounter(notificationsLbl)
		NotificationCenter.default.addObserver(forName: .init(rawValue: NotificationsVC.notificationCountChanged), object: nil, queue: nil) { (n) in
			self.updateNotificationCounter(self.notificationsLbl)
		}
	}
	
    override func viewDidLoad() {
		setupSideMenuPreferences()
		setupViewControllers()
		setupNotificationCounter()
		monitorLogout()
		super.viewDidLoad()
    }
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let loggedIn = UserDefaults.standard.bool(forKey: "userIsAuthorized");
		if !loggedIn {
			showLoginModal()
		}
		
		if let user = UserDefaults.standard.object(forKey: "user") as? [String: Any?] {
			state = user
		}
	}
      
	@IBAction func searchBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "Search")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func newsBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "News")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func groupsBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "Groups")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func infoBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "Info")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func followersBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "Users.Followers")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func staffBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "Users.Staff")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func notificationsBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "Notifications")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func profileBtnPressed(_ sender: Any) {
		sideMenuController?.setContentViewController(with: "News.MyProfile")
		sideMenuController?.hideMenu()
	}
	
	@IBAction func logoutBtnPressed(_ sender: UIButton) {
		sender.alpha = 0.3
		sender.isUserInteractionEnabled = false
		AQ.logout(failure: { (error) in
			sender.alpha = 1.0
			sender.isUserInteractionEnabled = true
			AQResponseChecker.showErrorInVC(vc: self, canSkip: true, onRetry: {
				self.logoutBtnPressed(sender)
			})
		}) { (resp) in
			sender.alpha = 1.0
			sender.isUserInteractionEnabled = true
			AQResponseChecker.checkResponse(result: resp, vc: self, canSkip: true, onSuccess: { (result) in
				UserDefaults.standard.set(false, forKey: "userIsAuthorized")
				UserDefaults.standard.synchronize()
				NotificationCenter.default.post(name: .init("loggedOut"), object: nil)
				self.showLoginModal()
			}, onRetry: {
				self.logoutBtnPressed(sender)
			})
		}
	}
	
}

