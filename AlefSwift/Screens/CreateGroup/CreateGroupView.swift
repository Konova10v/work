//
//  CreateGroupView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CreateGroupView: BaseView, UITextViewDelegate {
    
	@IBOutlet var descriptionTxt: UITextView!
	override func customizeUI() {
		descriptionTxt.text = "Описание"
		descriptionTxt.textColor = #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1)
	}
	
    override func render() {
		super.render()   
    }
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1) {
			textView.text = ""
			textView.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "Описание"
			textView.textColor = #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1)
		}
	}
    
}
