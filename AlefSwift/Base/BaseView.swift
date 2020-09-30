//
//  BaseView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер on 11/07/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class BaseView: UIView {
	@IBOutlet var bottomConstraintForKeyboard: NSLayoutConstraint?
    public var getState: () -> Dictionary<String, Any?> = {[:]}
    
    var state: [String: Any?] {
        return getState();
    }
	
	override func awakeFromNib() {
		super.awakeFromNib();
		startKeyboardHidingMechanism();
		customizeUI();
	}
	
	func startKeyboardHidingMechanism() {
		self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(endEditing)));
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func hideKeyboard() {
		self.endEditing(true);
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let bottomConstraintForKeyboard = bottomConstraintForKeyboard {
			if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
				bottomConstraintForKeyboard.constant = keyboardSize.height;
				self.layoutIfNeeded();
			}
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		if let bottomConstraintForKeyboard = bottomConstraintForKeyboard {
			bottomConstraintForKeyboard.constant = 0;
			self.layoutIfNeeded();
		}
	}
	
	func customizeUI() {		
	}
    
    func render() {
    }
   
}
