//
//  CommentImageCell.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 19/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CommentImageCell: UICollectionViewCell {
	@IBOutlet private var previewImg: UIImageView!
	@IBOutlet var btn: UIButton!
	func render(data: [String: Any?]) {
		
		if data[AQ.fields.type] as? String ?? "" == "photo" {
			if let url = data[AQ.fields.fileUrl] as? String {
				previewImg.sd_setImage(with: URL(string: url), completed: nil)
			}
		} else {
			if let url = data[AQ.fields.previewUrl] as? String  {
				previewImg.sd_setImage(with: URL(string: url), completed: nil)
			}
		}
				
		btn.accessibilityLabel = data[AQ.fields.unique_id] as? String ?? ""
	}
}
