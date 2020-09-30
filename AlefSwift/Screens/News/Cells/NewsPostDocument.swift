//
//  NewsPostDocument.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsPostDocument: NewsCell {
	@IBOutlet private var titleLbl: UILabel!
	@IBOutlet var documentBtn: UIButton!
	
	
	override func render(data: [String : Any?]) {
		if let attachment = data["attachment"] as? [String: Any?] {
			titleLbl.text = attachment[AQ.fields.name] as? String ?? ""
			documentBtn.accessibilityIdentifier = attachment[AQ.fields.fileUrl] as? String ?? ""
		}
		
	}
}
