//
//  AlbumItemCell.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 14/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class AlbumItemCell: UICollectionViewCell {

	@IBOutlet var videoImg: UIImageView!
	@IBOutlet var durationLbl: UILabel!
	@IBOutlet var checkboxBtn: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func render(item: [String: Any?]) {
		checkboxBtn.isHighlighted = item["checked"] as? Bool ?? false
		checkboxBtn.isHidden = !(item["editing"] as? Bool ?? false)
		
		let type = item[AQ.fields.type] as? String ?? "photo"
		
		if type == "photo" {
			videoImg.isHidden = true
			durationLbl.isHidden = true
		} else {
			durationLbl.text = item["duration"] as? String ?? ""
			videoImg.isHidden = false
			durationLbl.isHidden = false
		}
	}
}
