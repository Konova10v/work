//
//  NewsCreate.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsCreate: NewsCell {
	@IBOutlet private var avatarImg: UIImageView!
	override func render(data: [String : Any?]) {
		if let user = UserDefaults.standard.object(forKey: "user") as? [String: Any?] {
			if let url = user[AQ.fields.avatarUrl] as? String {
				avatarImg.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "userPlaceholder"), options: .highPriority, context: nil)
			}
		}
	}
}
