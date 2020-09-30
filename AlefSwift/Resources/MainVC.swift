//
//  MainVC.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class MainVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let newsVC = segue.destination as? NewsVC {
			if segue.identifier ?? "" == "showNewsHomepage" {
				newsVC.setScreenModeToHomepage()
			} else if segue.identifier ?? "" == "showNewsGroup" {
				newsVC.setScreenModeToGroup(1)
			} else if segue.identifier ?? "" == "showNewsProfile" {
				newsVC.setScreenModeToProfile(user: 1)
			} else if segue.identifier ?? "" == "showNewsMyProfile" {
				newsVC.setScreenModeToProfile(user: 0)
			}
		}
		
		if let usersVC = segue.destination as? UsersVC {
			if segue.identifier ?? "" == "showUsersStaff" {
				usersVC.setScreenModeToStaff()
			} else if segue.identifier ?? "" == "showUsersLikers" {
				usersVC.setScreenModeToLikers(post: 1)
			} else if segue.identifier ?? "" == "showUsersFollowers" {
				usersVC.setScreenModeToFollowers(user: 1)
			} else if segue.identifier ?? "" == "showUsersGroupMembers" {
				usersVC.setScreenModeToGroupMembers(1)
			}
		}
		
		if let albumVC = segue.destination as? AlbumVC {
			if segue.identifier ?? "" == "showAlbumMy" {
				albumVC.setScreenModeToMy()
			} else if segue.identifier ?? "" == "showAlbumTheir" {
				albumVC.setScreenModeToTheir()
			}
		}
		
		
	}

}
