//
//  NewsFirstLevelCommentCounters.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsFirstLevelCommentCounters: NewsCell {
	@IBOutlet var dtLbl: UILabel!
	@IBOutlet var replyBtn: UIButton!
	@IBOutlet var likeBtn: UIButton!
	@IBOutlet var likesCounterLbl: UILabel!
	
	override func render(data: [String : Any?]) {
		if let comment = data[AQ.fields.comment] as? [String: Any?] {
			replyBtn.tag = comment[AQ.fields.id] as? Int ?? 0
			likeBtn.tag = comment[AQ.fields.id] as? Int ?? 0
			if let likes = comment[AQ.fields.likes] as? [String: Any?] {
				let likesCount = likes[AQ.fields.userLikesCount] as? Int ?? 0
				likesCounterLbl.text = likesCount.description
				if likes[AQ.fields.isLiked] as? Int ?? 0 == 1 {
					likeBtn.isSelected = true
				} else {
					likeBtn.isSelected = false
				}
			}
			
			dtLbl.text = Date(timeIntervalSince1970: Double(comment[AQ.fields.createdTimeStamp] as? Int ?? 0)).russianInterval()
		}
	}
}
