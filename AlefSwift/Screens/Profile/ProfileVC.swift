//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class ProfileVC: BaseVC {
	private var userId = 0
	weak var parentNewsVC: NewsVC?
	
	// это ссылка на наш view, но с правильным классом
    override var v: ProfileView! { return self.view as? ProfileView }
    
    override func viewDidLoad() {
		// это Dictionary в котором хранятся все данные, влияющие на данный экран
		// каждый раз, когда мы что-то меняем в нем,
		// во вью автоматически вызывается метод render
		
		super.viewDidLoad();		
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		state = ["user_id": userId];
	}
	
	func setUserId(_ _userId: Int) {
		userId = _userId
	}
	
	@IBAction func albumBtnPressed(_ sender: Any) {
		if let nav = parentNewsVC?.navigationController {
			if let vc = UIStoryboard(name: "Album", bundle: nil).instantiateInitialViewController() as? AlbumVC {
				if userId == 0 {
					vc.setScreenModeToMy()
				}
				nav.pushViewController(vc, animated: true)
			}
		}
	}
	
	@IBAction func editProfileBtnPressed(_ sender: Any) {
		if let vc = UIStoryboard(name: "EditProfile", bundle: nil).instantiateInitialViewController() {
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func editMoodBtnPressed(_ sender: Any) {
		if let vc = UIStoryboard(name: "MyMood", bundle: nil).instantiateInitialViewController() {
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func createAlbumBtnPressed(_ sender: Any) {
		if let vc = UIStoryboard(name: "CreateAlbum", bundle: nil).instantiateInitialViewController() {
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}

