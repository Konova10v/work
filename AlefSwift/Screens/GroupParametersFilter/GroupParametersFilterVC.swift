//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class GroupParametersFilterVC: BaseVC {
	// это ссылка на наш view, но с правильным классом
    override var v: GroupParametersFilterView! { return self.view as? GroupParametersFilterView }
    
    override func viewDidLoad() {
		// это Dictionary в котором хранятся все данные, влияющие на данный экран
		// каждый раз, когда мы что-то меняем в нем,
		// во вью автоматически вызывается метод render
		
		super.viewDidLoad();
		state = [:];
    }
      
}

