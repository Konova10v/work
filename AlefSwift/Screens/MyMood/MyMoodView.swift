//
//  MyMoodView.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class MyMoodView: BaseView {
    
    @IBOutlet private var myMoodTxt: UITextView!
    
	override func customizeUI() {
        myMoodTxt.becomeFirstResponder()
	}
	
    override func render() {
		super.render()   
    }
}
