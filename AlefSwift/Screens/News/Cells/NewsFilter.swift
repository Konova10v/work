//
//  NewsFilter.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsFilter: NewsCell {
	@IBOutlet private var groupLbl: UILabel!
	@IBOutlet private var dateFromLbl: UILabel!
	@IBOutlet private var dateToLbl: UILabel!
	@IBOutlet private var filterPanelHeightC: NSLayoutConstraint!
	
	override func render(data: [String : Any?]) {
		if let filter = data["filter"] as? [String : Any?] {
			if filter["isExpanded"] as? Bool ?? false {
				filterPanelHeightC.constant = 166
			} else {
				filterPanelHeightC.constant = 0
			}
			
			groupLbl.text = filter["groupStr"] as? String ?? "Все группы"
			dateFromLbl.text = filter["dateFromStr"] as? String ?? "Дата с"
			dateToLbl.text = filter["dateToStr"] as? String ?? "Дата по"
		}
	}
	
}
