//
//  NewsPostCounters.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsPostCounters: NewsCell {
	@IBOutlet private var likesCounterLbl: UILabel!
	@IBOutlet private var commentsCounterLbl: UILabel!
	@IBOutlet var shareBtn: UIButton!
	@IBOutlet var likesBtn: UIButton!
	@IBOutlet var commentsBtn: UIButton!
	
	override func render(data: [String : Any?]) {
		if let post = data[AQ.fields.post] as? [String: Any?] {
			if let likes = post[AQ.fields.likes] as? [String: Any?] {
				let cnt = likes[AQ.fields.userLikesCount] as? Int ?? 0
				likesCounterLbl.text = cnt.description
				if likes[AQ.fields.isLiked] as? Int ?? 0 == 1 {
					likesBtn.isSelected = true
				} else {
					likesBtn.isSelected = false
				}
			}
			
			if let comments = post[AQ.fields.comments] as? [String: Any?] {
				let cnt = comments[AQ.fields.total] as? Int ?? 0
				commentsCounterLbl.text = cnt.description
			}
			
			shareBtn.tag = post[AQ.fields.id] as? Int ?? 0
			likesBtn.tag = post[AQ.fields.id] as? Int ?? 0
			commentsBtn.tag = post[AQ.fields.id] as? Int ?? 0
		}
	}
}
