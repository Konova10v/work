//
//  BaseVC.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер on 11/07/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import MBProgressHUD


class BaseVC: UIViewController {
	@IBOutlet var sideMenuLeftButtonContainer: UIView?
	@IBOutlet var sideMenuRightButtonContainer: UIView?
	
	var v: BaseView! { return self.view as? BaseView }
    
    private var _state : [String: Any?] = [:]
    public var state : [String: Any?] {
        get { _state}
        set {
            _state = newValue
            v.getState = { [weak self] in self?.state ?? [:]}
            v.render()
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupSideMenuButtons()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		prepareForUITests()
	}
	
	func setupSideMenuButtons() {
		setupSideMenuLeftButton()
		setupSideMenuRightButton()
	}
	
	func setupSideMenuLeftButton() {
		if let v = sideMenuLeftButtonContainer {
			v.backgroundColor = .clear
			
			var nav = navigationController
			var parent: UIViewController?
			if let profileVC = self as? ProfileVC {
				nav = profileVC.parentNewsVC?.navigationController
				parent = profileVC.parentNewsVC
			}
			
			var icon: String;
			if nav == nil {
				if sideMenuController != nil {
					icon = "iconMenu"
				} else {
					icon = "icon.ArrowLeft"
				}
			} else {
				if nav?.viewControllers.first == self  || nav?.viewControllers.first == parent {
					icon = "iconMenu"
				} else {
					icon = "icon.ArrowLeft"
				}
			}
			
			
			
			let imgV = UIImageView(image: UIImage(named: icon))
			
			v.addSubview(imgV)
			imgV.translatesAutoresizingMaskIntoConstraints = false
			imgV.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
			imgV.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
			
			let btn = UIButton()
			v.addSubview(btn)
			btn.translatesAutoresizingMaskIntoConstraints = false
			btn.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
			btn.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
			btn.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
			btn.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
			btn.addTarget(self, action: #selector(sideMenuLeftBtnPressed(sender:)), for: .touchUpInside)
			
			if (icon == "iconMenu") {
				let lbl = UILabel()
				v.addSubview(lbl)
				lbl.translatesAutoresizingMaskIntoConstraints = false
				lbl.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
				lbl.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
				lbl.centerXAnchor.constraint(equalTo: v.centerXAnchor, constant: 20).isActive = true
				lbl.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: -1).isActive = true
				lbl.backgroundColor = .red
				lbl.textColor = .white
				lbl.minimumScaleFactor = 0.5
				lbl.layer.cornerRadius = 8.0
				lbl.textAlignment = .center
				lbl.clipsToBounds = true
				lbl.font = UIFont(name: "Roboto-Medium", size: 8)
							
				updateNotificationCounter(lbl)
				NotificationCenter.default.addObserver(forName: .init(rawValue: NotificationsVC.notificationCountChanged), object: nil, queue: nil) { (n) in
					self.updateNotificationCounter(lbl)
				}			
			}
			
						
			v.layoutIfNeeded()
		}
	}
	
	
	func updateNotificationCounter(_ lbl: UILabel) {
		lbl.text = NotificationsVC.count.description
		lbl.isHidden = NotificationsVC.count == 0
	}
	
	func setupSideMenuRightButton() {
		if let v = sideMenuRightButtonContainer {
			
			var parent: UIViewController?
			var nav = navigationController
			if let profileVC = self as? ProfileVC {
				nav = profileVC.parentNewsVC?.navigationController
				parent = profileVC.parentNewsVC
			}
			
			if nav == nil || nav?.viewControllers.first == self || nav?.viewControllers.first == parent {
				v.isHidden = true
			} else {
				v.backgroundColor = .clear
				let imgV = UIImageView(image: UIImage(named: "iconMenu"))
				v.addSubview(imgV)
				imgV.translatesAutoresizingMaskIntoConstraints = false
				imgV.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
				imgV.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
				
				let btn = UIButton()
				v.addSubview(btn)
				btn.translatesAutoresizingMaskIntoConstraints = false
				btn.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
				btn.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
				btn.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
				btn.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
				
				btn.addTarget(self, action: #selector(sideMenuRightBtnPressed(sender:)), for: .touchUpInside)
				v.layoutIfNeeded()
			}
		}
	}
	
	@objc func sideMenuRightBtnPressed(sender: Any?) {
		if let smc = sideMenuController {
			smc.revealMenu()
		}
	}
	
	@objc func sideMenuLeftBtnPressed(sender: Any?) {
		
		var nav = navigationController
		var parent: UIViewController?
		
		if let profileVC = self as? ProfileVC {
			nav = profileVC.parentNewsVC?.navigationController
			parent = profileVC.parentNewsVC
		}
		
		if nav == nil {
			if let side = sideMenuController {
				side.revealMenu()
			} else {
				dismiss(animated: true, completion: nil)
			}
		} else {
			if nav?.viewControllers.first == self || nav?.viewControllers.first == parent {
				if let side = sideMenuController {
					side.revealMenu()
				} else {
					dismiss(animated: true, completion: nil)
				}
			} else {
				navigationController?.popViewController(animated: true)
			}
		}
	}
			
	func prepareForUITests() {
		// Если программа запущена в рамках теста (скриншотилки), то
		// создаем кнопку размером в один пиксель,
		// которая возвращает из этого контроллера.
		// В зависимости от ситуации это
		// либо pop либо dismiss
		// Это нужно, чтобы возвращаться с экранов
		// где нет кнопки назад
		if(ProcessInfo.processInfo.environment["isUITest"] == "YES") {
			let btn = UIButton(type: .custom);
			v.addSubview(btn);
			btn.setTitle("", for: .normal);
			btn.accessibilityIdentifier = "UITestBackBtn";
			btn.translatesAutoresizingMaskIntoConstraints = false;
			btn.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true;
			btn.topAnchor.constraint(equalTo: v.topAnchor).isActive = true;
			btn.widthAnchor.constraint(equalToConstant: 100).isActive = true;
			btn.heightAnchor.constraint(equalToConstant: 100).isActive = true;
			btn.addTarget(self, action: #selector(returnFromVC), for: .touchUpInside);
			v.layoutIfNeeded();
		}
	}
	
	@objc func returnFromVC() {
		if let navigationController = navigationController
		{
			if(navigationController.viewControllers.first == self) {
				if let side = navigationController.sideMenuController {
					side.revealMenu()
				} else {
					navigationController.dismiss(animated: true, completion: nil);
				}
			} else {
				navigationController.popViewController(animated: true)
			}
		} else {
			if let side = sideMenuController {
				side.revealMenu()
			} else {
				dismiss(animated: true, completion: nil);
			}
		}
	}
	
	var backgroundTasks: [DispatchWorkItem] = [];
	
	func showLoadingIndicator() {
		showLoadingIndicator(title: "", description: "")
	}
	
	func showLoadingIndicator(title: String, description: String) {
		
		let task = DispatchWorkItem {
			let indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
			indicator.label.text = title
			indicator.isUserInteractionEnabled = false
			indicator.detailsLabel.text = description
			indicator.bezelView.color = UIColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
			indicator.bezelView.style = .solidColor
			indicator.contentColor = UIColor(#colorLiteral(red: 0.1650000066, green: 0.5879999995, blue: 0.6859999895, alpha: 1))
			indicator.show(animated: true)
		}
		
		backgroundTasks.append(task);
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: task)
	}
	
	func hideLoadingIndicator() {
		backgroundTasks.forEach { (task) in
			task.cancel();
		}
		MBProgressHUD.hide(for: self.view, animated: true)
	}
	
	func alert(title: String, text: String) {
		let appearance = SCLAlertViewWideButton.SCLAppearance(
			kDefaultShadowOpacity: 0.5,
			kCircleBackgroundTopPosition: 50,
			kCircleHeight: 50,
			kCircleIconHeight: 50,
			kTitleTop: 80,
			kWindowWidth: 300,
			kWindowHeight: 300,
			kButtonHeight: 50.0,
			kTitleFont: UIFont(name: "Roboto-Medium", size: 18)!,
			kButtonFont: UIFont(name: "Roboto", size: 18)!,
			showCloseButton: false,
			contentViewCornerRadius: 25.0,
			buttonCornerRadius: 18.0,
			circleBackgroundColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			contentViewColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			titleColor: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		)
		let alert = SCLAlertViewWideButton(appearance: appearance)
		
		
		alert.addButton(NSLocalizedString("Ок", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
			
		}
		
		alert.showCustom(title, subTitle: text, color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
	}

}
