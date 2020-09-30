//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CreateEditPostVC: BaseVC {
    override var v: CreateEditPostView! { return self.view as? CreateEditPostView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [:];
    }
      
}

