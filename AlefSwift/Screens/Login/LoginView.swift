//
//  LoginView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class LoginView: BaseView, UITextFieldDelegate {
	@IBOutlet var loginTxt: UITextField!
	@IBOutlet var passTxt: UITextField!
	@IBOutlet var rememberMeBtn: UIButton!
	@IBOutlet var userAgreementBtn: UIButton!
	@IBOutlet var loginBtn: UIButton!
	@IBOutlet var emailUnderline: UIView!
	
	override func customizeUI() {
		
	}
	
    override func render() {
		loginTxt.text = state["login"] as? String ?? ""
		passTxt.text = state["pass"] as? String ?? ""
		rememberMeBtn.isSelected = state["rememberMe"] as? Bool ?? false
		userAgreementBtn.isSelected = state["userAgreement"] as? Bool ?? false
		
		if state["loginEdited"] as? Bool ?? false && loginTxt.text?.count ?? 0 < 3 && !loginTxt.isFirstResponder {
			loginTxt.textColor = #colorLiteral(red: 1, green: 0.00800000038, blue: 0.00800000038, alpha: 1)
			emailUnderline.backgroundColor = #colorLiteral(red: 1, green: 0.00800000038, blue: 0.00800000038, alpha: 1)
		} else {
			loginTxt.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
			emailUnderline.backgroundColor = #colorLiteral(red: 0.7250000238, green: 0.7250000238, blue: 0.7250000238, alpha: 1)
		}
		
		loginBtn.isEnabled =
			userAgreementBtn.isSelected &&
			(loginTxt.text ?? "" != "") &&
			(passTxt.text ?? "" != "")
		loginBtn.isUserInteractionEnabled = loginBtn.isEnabled
		loginBtn.backgroundColor = loginBtn.isEnabled ? #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1) : #colorLiteral(red: 0.7254901961, green: 0.7254901961, blue: 0.7254901961, alpha: 1)

		super.render()   
    }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == loginTxt {
			passTxt.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
		}
		return true
	}
}
