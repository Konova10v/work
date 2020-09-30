//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class LoginVC: BaseVC {
    override var v: LoginView! { return self.view as? LoginView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [
			"login": UserDefaults.standard.string(forKey: "rememberMeLogin") ?? "",
			"pass": "",
			"rememberMe": 	UserDefaults.standard.bool(forKey: "rememberMe"),
			"userAgreement": true
		];
    }
      
		
	@IBAction func rememberMeCheckboxBtnPressed(_ sender: UIButton) {
		UserDefaults.standard.set(!sender.isSelected, forKey: "rememberMe")
		if (sender.isSelected) {
			UserDefaults.standard.set("", forKey: "rememberMeLogin")
		} else {
			UserDefaults.standard.set(state["login"] as? String ?? "", forKey: "rememberMeLogin")
		}
		UserDefaults.standard.synchronize()
		state["rememberMe"] = !sender.isSelected
	}
	
	@IBAction func userAgreementCheckboxBtnPressed(_ sender: UIButton) {
		state["userAgreement"] = !sender.isSelected
	}
	
	@IBAction func loginEditingDidChange(_ sender: UITextField) {
		state["login"] = sender.text
	}
	
	@IBAction func passEditingDidChange(_ sender: UITextField) {
		state["pass"] = sender.text
	}
	
	@IBAction func loginEditingDidEnd(_ sender: UITextField) {
		if state["rememberMe"] as? Bool ?? false {
			UserDefaults.standard.set(sender.text ?? "", forKey: "rememberMeLogin")
			UserDefaults.standard.synchronize()
		}
	
		state["loginEdited"] = true
	}
	
	@IBAction func loginEditingDidBegin(_ sender: Any) {
		v.render()
	}
	
	@IBAction func userAgreementDocumentBtnPressed(_ sender: Any) {
		if let vc = UIStoryboard(name: "HtmlArticle", bundle: nil).instantiateInitialViewController() {
			present(vc, animated: true, completion: nil)
		}
	}
	
	@IBAction func loginBtnPressed(_ sender: Any) {
		showLoadingIndicator()
		AQ.login(user_name: state["login"] as? String ?? "", password: state["login"] as? String ?? "", failure: { (error) in
			self.hideLoadingIndicator()
			AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
				self.loginBtnPressed(sender)
			}
		}) { (result) in
			self.hideLoadingIndicator()
			AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
				UserDefaults.standard.set(true, forKey: "userIsAuthorized")
				UserDefaults.standard.set(result[AQ.fields.profile], forKey: "user")
				UserDefaults.standard.synchronize()
				self.dismiss(animated: true, completion: nil)
			}, onRetry: {
				self.loginBtnPressed(sender)
			}, onSkip: nil)
		}
	}
	
}

