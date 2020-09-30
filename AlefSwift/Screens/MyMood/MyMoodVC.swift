//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class MyMoodVC: BaseVC, UITextViewDelegate {
    
    override var v: MyMoodView! { return self.view as? MyMoodView }
    
    override func viewDidLoad() {		
		super.viewDidLoad();
		state = [
            "myMood": ""
        ]
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        state["myMood"] = textView.text
    }
    
	@IBAction func saveBtnPressed(_ sender: Any) {
        self.showLoadingIndicator()
        AQ.editMyMood(mood_text: state["myMood"] as? String ?? "", failure: { (error) in
            AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
                self.saveBtnPressed(sender)
            }
        }) { (result) in
            self.hideLoadingIndicator()
            AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
                self.returnFromVC()
            }) {
                self.saveBtnPressed(sender)
            }
        }
	}
}

