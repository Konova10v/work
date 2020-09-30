//
//  MenuView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class MenuView: BaseView {
	@IBOutlet var nameLbl: UILabel!
	@IBOutlet var avatarImg: UIImageView!
	override func customizeUI() {
		
	}
	
    override func render() {
		nameLbl.text = state[AQ.fields.fullName] as? String ?? ""
		if let url = state[AQ.fields.avatarUrl] as? String {
			avatarImg.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "userPlaceholder"), options: .highPriority, context: nil)
		}

		super.render()   
    }
    
}
