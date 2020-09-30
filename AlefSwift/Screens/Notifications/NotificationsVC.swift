//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NotificationsVC: BaseVC {
	static private var _count: Int = 0
	static let notificationCountChanged = "notificationCountChanged"
	static var count: Int {
		get {
			_count
		}
		
		set {
			_count = newValue
			NotificationCenter.default.post(name: .init(rawValue: notificationCountChanged), object: nil)
		}
	}
    override var v: NotificationsView! { return self.view as? NotificationsView }
    
    func getNotifications() {
        self.showLoadingIndicator()
        AQ.getNotifications(failure: { (error) in
            AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
                self.getNotifications()
            }
        }) { (result) in
            self.hideLoadingIndicator()
            AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
                self.state["notifications"] = result[AQ.fields.items] as? [[String: Any?]] ?? []
            }) {
                self.getNotifications()
            }
        }
    }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [
            "notifications": [:]
        ]
        getNotifications()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);		
	}
      
	@IBAction func notificationBtnPressed(_ sender: UIButton) {
        let id = sender.tag
        var targetType = ""
        let post = (state["notifications"] as? [[String: Any?]] ?? []).first { $0[AQ.fields.id] as? Int ?? 0 == id}
        targetType = post?[AQ.fields.targetType] as? String ?? ""
        if targetType == "group" {
            if let profileVC = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
                profileVC.setScreenModeToGroup(post?[AQ.fields.targetId] as? Int ?? 0)
                self.showLoadingIndicator()
                AQ.markNotificationAsRead(id: post?[AQ.fields.id] as? Int ?? 0, failure: { (error) in
                    self.notificationBtnPressed(sender)
                }) { (result) in
                    self.hideLoadingIndicator()
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        } else if targetType == "user" {
            if let vc = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
                vc.setScreenModeToProfile(user: post?[AQ.fields.targetId] as? Int ?? 0)
                self.showLoadingIndicator()
                AQ.markNotificationAsRead(id: post?[AQ.fields.id] as? Int ?? 0, failure: { (error) in
                    self.notificationBtnPressed(sender)
                }) { (result) in
                    self.hideLoadingIndicator()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
	}
    
    @IBAction func clearNotificationsPressed(_ sender: UIButton) {
        var posts : [[String: Any?]] { state["notifications"] as? [[String: Any?]] ?? [] }
        self.showLoadingIndicator()
        AQ.markNotificationAsRead(id: 0, failure: { (error) in
            AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
                self.clearNotificationsPressed(sender)
            }
        }) { (result) in
            self.hideLoadingIndicator()
            AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
                self.returnFromVC()
            }) {
                self.clearNotificationsPressed(sender)
            }
        }
    }
}

