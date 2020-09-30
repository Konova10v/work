//
//  ProfileView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class ProfileView: BaseView, UICollectionViewDataSource {
    
	@IBOutlet private var changeAvatarBtn: UIButton!
	@IBOutlet private var teamsCallBtn: UIButton!
	@IBOutlet private var teamsCallBackgroundV: UIView!
	@IBOutlet private var editProfileBtn: UIButton!
	@IBOutlet private var subscribeBtn: UIButton!
	@IBOutlet private var editMoodBtn: UIButton!
	@IBOutlet private var createAlbumBtn: UIButton!
	@IBOutlet private var phoneLbl: UILabel!
	@IBOutlet private var phoneExtLbl: UILabel!
	@IBOutlet private var emailLbl: UILabel!
	@IBOutlet private var phoneBtn: UIButton!
	@IBOutlet private var phoneExtBtn: UIButton!
	@IBOutlet private var emailBtn: UIButton!
	@IBOutlet private var feedTitleLbl: UILabel!
	
	
	override func customizeUI() {
		translatesAutoresizingMaskIntoConstraints = false
	}
	
    override func render() {
		// эта функция автоматически вызывается каждый раз,
		// когда во ViewController изменяется state
		let userId = state["user_id"] as? Int ?? 0
		
		if userId == 0 {
			changeAvatarBtn.isHidden = false
			teamsCallBtn.isHidden = true
			teamsCallBackgroundV.isHidden = true
			editProfileBtn.isHidden = false
			subscribeBtn.isHidden = true
			editMoodBtn.isHidden = false
			createAlbumBtn.isHidden = false
			phoneLbl.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
			phoneExtLbl.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
			emailLbl.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
			phoneBtn.isHidden = true
			phoneExtBtn.isHidden = true
			emailBtn.isHidden = true
			feedTitleLbl.text = NSLocalizedString("Моя лента", comment: "")
		} else {
			changeAvatarBtn.isHidden = true
			teamsCallBtn.isHidden = false
			teamsCallBackgroundV.isHidden = false
			editProfileBtn.isHidden = true
			subscribeBtn.isHidden = false
			editMoodBtn.isHidden = true
			createAlbumBtn.isHidden = true
			phoneLbl.textColor = #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1)
			phoneExtLbl.textColor = #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1)
			emailLbl.textColor = #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1)
			phoneBtn.isHidden = false
			phoneExtBtn.isHidden = false
			emailBtn.isHidden = false
			feedTitleLbl.text = NSLocalizedString("Лента", comment: "")
		}

		super.render()   
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5;
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath);
    }
	
	
}
