//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

enum GroupsVCModes {
	case groups
	case search
}

class GroupsVC: BaseVC {
	private var mode: GroupsVCModes = .groups
    override var v: GroupsView! { return self.view as? GroupsView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [:];
    }
	
	func setScreenModeToSearch(serverData: [String: Any?]) {
		mode = .search
		var data = serverData
		data["mode"] = mode
		self.v.prepareForEmbedding()
				
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			self.state = data
		}
	}
	
	@IBAction func searchBtnPressed(_ sender: Any) {
		if let searchVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "Search") as? SearchVC {
			navigationController?.pushViewController(searchVC, animated: true)
		}
	}
	
	@IBAction func filtersBtnPressed(_ sender: Any) {
	}
	
	@IBAction func createGroupBtnPressed(_ sender: Any) {
		if let vc = UIStoryboard(name: "CreateGroup", bundle: nil).instantiateInitialViewController() {
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func groupBtnPressed(_ sender: Any) {
		if let profileVC = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
			profileVC.setScreenModeToGroup(1)
			navigationController?.pushViewController(profileVC, animated: true)
		}
	}
}

