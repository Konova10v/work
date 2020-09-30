//
//  NewsProfile.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 15/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsProfile: NewsCell {	
	@IBOutlet private var profileContainer: UIView!
	var onControllerEmbeded: ((ProfileVC)->(Void))?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func render(data: [String : Any?]) {
		if let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as? ProfileVC{
			profileVC.setUserId(data["user_id"] as? Int ?? 0)
			if let onControllerEmbeded = onControllerEmbeded {
				onControllerEmbeded(profileVC)
			}
			profileContainer.addSubview(profileVC.view)
			
			
			
			profileVC.view.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor).isActive = true;
			profileVC.view.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor).isActive = true;
			profileVC.view.topAnchor.constraint(equalTo: profileContainer.topAnchor).isActive = true;
			profileVC.view.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor).isActive = true;
			profileVC.view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true;
			layoutIfNeeded()
		}
	}

}
