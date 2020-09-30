//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CreateGroupVC: BaseVC {
    override var v: CreateGroupView! { return self.view as? CreateGroupView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [:];
    }
	
	@IBAction func saveBtnPRessed(_ sender: Any) {
		returnFromVC()
	}
	
	@IBAction func cancelBtnPRessed(_ sender: Any) {
		returnFromVC()
	}
	
}

