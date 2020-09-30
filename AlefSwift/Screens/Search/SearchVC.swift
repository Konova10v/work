//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class SearchVC: BaseVC {
    override var v: SearchView! { return self.view as? SearchView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [:];
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {		
		if let usersVC = segue.destination as? UsersVC {
			usersVC.setScreenModeToSearch(serverData: [:])
		}
		
		if let newsVC = segue.destination as? NewsVC {
			newsVC.setScreenModeToSearch(serverData: [:])
		}
		
		if let groupsVC = segue.destination as? GroupsVC {
			groupsVC.setScreenModeToSearch(serverData: [:])
		}
	}
      
}

