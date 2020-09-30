//
//  NewsSecondLevelCommentBody.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsSecondLevelCommentBody: NewsCell, UITextViewDelegate {
	@IBOutlet var avatarImg: UIImageView!
	@IBOutlet var nameLbl: UILabel!
	@IBOutlet var userNameBtn: UIButton!
	@IBOutlet var bodyTxt: UITextView!
	@IBOutlet var editBtn: UIButton!
	@IBOutlet var deleteBtn: UIButton!
	private var savedData: [String: Any?] = [:]
	
	override func render(data: [String : Any?]) {
		savedData = data
		
		if let comment = data["comment"] as? [String: Any] {
			let isOwn = (comment["isOwn"] as? Int ?? 0) == 1
			let fromAuthor = comment[AQ.fields.fromAuthor] as? [String: Any] ?? [:]
			let postContent = comment[AQ.fields.postContent] as? [String: Any] ?? [:]
			let mentions = postContent[AQ.fields.mentions] as? [[String: Any?]] ?? []
			
			if let avatar = fromAuthor[AQ.fields.avatarUrl] as? String {
				avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
			}
			userNameBtn.tag = fromAuthor[AQ.fields.id] as? Int ?? 0
			editBtn.tag = comment[AQ.fields.id] as? Int ?? 0
			deleteBtn.tag = comment[AQ.fields.id] as? Int ?? 0
			
			editBtn.isHidden = !isOwn
			deleteBtn.isHidden = !isOwn
			
			nameLbl.text = fromAuthor[AQ.fields.name] as? String ?? ""
			let text = NSMutableAttributedString(string: postContent[AQ.fields.text] as? String ?? "")
			
			for mention in mentions {
				let start = mention[AQ.fields.startLetter] as? Int ?? 0
				let finish = mention[AQ.fields.endLetter] as? Int ?? 0
				let range = NSMakeRange(start, finish - start + 1)
				let userId = mention[AQ.fields.userId] as? Int ?? 0
				
				text.addAttribute(.link, value: "intranet://user#" + userId.description, range: range)
			}
			bodyTxt.attributedText = text
			
		}
	}
	
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		var str = URL.absoluteString
		if str.contains("intranet://user#") {
			str = str.replacingOccurrences(of: "intranet://user#", with: "")
			let userId = Int(str) ?? 0
			if let onUserClicked = savedData["onUserClicked"] as? ((Int)->(Void)) {
				onUserClicked(userId)
			}
			return false;
		}
		
		return true
	}
	
}
