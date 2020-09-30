//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

enum UserVCModes {
	case groupMembers
	case likers
	case followers
	case staff
	case search
}

class UsersVC: BaseVC {
	var groupId = 0
	var postId = 0
	var userId = 0
	private var mode: UserVCModes = .staff
    override var v: UsersView! { return self.view as? UsersView }

	func setScreenModeToGroupMembers(_ _groupId: Int) {
		mode = .groupMembers
		groupId = _groupId
	}
	
	func setScreenModeToLikers(post _postId: Int) {
		mode = .likers
		postId = _postId
	}
	
	func setScreenModeToFollowers(user _userId: Int) {
		mode = .followers
		userId = _userId
	}
	
	func setScreenModeToStaff() {
		mode = .staff
	}
	
	func setScreenModeToSearch(serverData: [String: Any?]) {
		mode = .search
		var data = serverData
		data["mode"] = mode
		self.v.prepareForEmbedding()
		
		// установка стейта приводит к отрисовке
		// вызывать отрисовку до добавления в структуру View плохо
		// поэтому делаем это с задержкой
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			self.state = data			
		}
	}
	
	private func populateForGroupMembers() {
		state = ["mode": mode];
	}
	
	private func populateForLikers() {
		state = ["mode": mode];
	}
	
	private func populateForFollowers() {
		state = ["mode": mode];
	}
	
	private func populateForStaff() {
		
		state = ["mode": mode];
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if (mode == .groupMembers) {
			populateForGroupMembers()
		}
		
		if (mode == .likers) {
			populateForLikers()
		}
		
		if (mode == .followers) {
			populateForFollowers()
		}
		
		if (mode == .staff) {
			populateForStaff()
		}			
	}
      
	@IBAction func backBtnPressed(_ sender: Any) {
		if let nav = self.navigationController {
			nav.popViewController(animated: true)
		} else {
			dismiss(animated: true, completion: nil)
		}
	}
	
	@IBAction func userBtnPressed(_ sender: Any) {
		if let profileVC = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
			profileVC.setScreenModeToProfile(user: 1)
			navigationController?.pushViewController(profileVC, animated: true)
		}
	}
	
	@IBAction func searchBtnPressed(_ sender: Any) {
		if let searchVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "Search") as? SearchVC {
			navigationController?.pushViewController(searchVC, animated: true)
		}
	}
}

