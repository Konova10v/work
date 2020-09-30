//
//  NewsPostLink.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsPostLink: NewsCell {
	@IBOutlet private var img: UIImageView!
	@IBOutlet private var btn: UIButton!
	@IBOutlet private var domainLbl: UILabel!
	@IBOutlet private var titleLbl: UILabel!
	@IBOutlet private var descrLbl: UILabel!
	
	override func render(data: [String : Any?]) {
		if let link = data["link"] as? [String : Any?] {
			if let url = link[AQ.fields.imageUrl] as? String {
				img.sd_setImage(with: URL(string: url), completed: nil)
			}
			
			btn.accessibilityIdentifier = link[AQ.fields.originalUrl] as? String ?? ""
			titleLbl.text = link[AQ.fields.title] as? String ?? ""
			descrLbl.text = link[AQ.fields.description] as? String ?? ""
			
			if let url = URL(string: link[AQ.fields.originalUrl] as? String ?? "") {
				domainLbl.text = url.host
			}
		}
	}

}
