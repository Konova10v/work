//
//  NewsPostBody.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsPostBody: NewsCell, UITextViewDelegate {

	@IBOutlet private var avatarImg: UIImageView!
	@IBOutlet private var nameLbl: UILabel!
	@IBOutlet var userNameBtn: UIButton!
	@IBOutlet private var postTargetView: UIView!
	@IBOutlet private var postTargetNameLbl: UILabel!
	@IBOutlet private var postTargetGroupBtn: UIButton!
	@IBOutlet private var postTargetUserBtn: UIButton!
	@IBOutlet private var timeSinceLbl: UILabel!
	@IBOutlet private var bodyTxt: UITextView!
	@IBOutlet private var editBtn: UIButton!
	@IBOutlet private var deleteBtn: UIButton!
	@IBOutlet private var moreBtn: UIButton!
	@IBOutlet var bodyTxtHeightC: NSLayoutConstraint!
	private var savedData: [String: Any?] = [:]
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func render(data: [String : Any?]) {
		savedData = data
		if let post = data["post"] as? [String: Any] {
			let isOwn = (post["isOwn"] as? Int ?? 0) == 1
			let mode = post["mode"] as? NewsVCMode
			let owner = post[AQ.fields.owner] as? [String: Any] ?? [:]
			let from = post[AQ.fields.from] as? [String: Any] ?? [:]
			let postContent = post[AQ.fields.postContent] as? [String: Any?] ?? [:]
			let mentions = postContent[AQ.fields.mentions] as? [[String: Any?]] ?? []
			
			let id = post[AQ.fields.id] as? Int ?? -1
			timeSinceLbl.text = Date(timeIntervalSince1970: Double(post[AQ.fields.createdTimeStamp] as? Int ?? 0)).russianInterval()
			
			nameLbl.text = from[AQ.fields.name] as? String ?? ""
			userNameBtn.tag = from[AQ.fields.id] as? Int ?? 0
			
			if isOwn {
				deleteBtn.isHidden = false
				editBtn.isHidden = false
			} else {
				deleteBtn.isHidden = true
				editBtn.isHidden = true
			}
			
			let text = NSMutableAttributedString(string: postContent[AQ.fields.text] as? String ?? "")
			
			for mention in mentions {
				let start = mention[AQ.fields.startLetter] as? Int ?? 0
				let finish = mention[AQ.fields.endLetter] as? Int ?? 0
				let range = NSMakeRange(start, finish - start + 1)
				let userId = mention[AQ.fields.userId] as? Int ?? 0

				text.addAttribute(.link, value: "intranet://user#" + userId.description, range: range)
			}
			bodyTxt.attributedText = text
						
			if post["textExpanded"] as? Bool ?? false {
				moreBtn.setTitle("свернуть", for: .normal)
				bodyTxtHeightC.priority = .defaultLow
			} else {
				moreBtn.setTitle("ещё", for: .normal)
				bodyTxtHeightC.priority = .defaultHigh
			}
			
			if let avatar = from[AQ.fields.avatarUrl] as? String {
				avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
			}
			
			if mode == .group {
				postTargetView.isHidden = true
			} else {
				if let groupId = owner[AQ.fields.groupId] as? Int {
					postTargetView.isHidden = false
					postTargetGroupBtn.tag = groupId
					postTargetGroupBtn.isHidden = false
					postTargetUserBtn.isHidden = true
					postTargetNameLbl.text = owner[AQ.fields.name] as? String ?? ""
				} else if let userId = owner[AQ.fields.id] as? Int {
					postTargetView.isHidden = false
					postTargetUserBtn.tag = userId
					postTargetGroupBtn.isHidden = true
					postTargetUserBtn.isHidden = false
					postTargetNameLbl.text = owner[AQ.fields.name] as? String ?? ""
				} else {
					postTargetView.isHidden = true
				}
			}

			editBtn.tag = id
			deleteBtn.tag = id
			moreBtn.tag = id
			
			setNeedsLayout()
			layoutIfNeeded()
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
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		bodyTxt.sizeToFit()
		if bodyTxt.contentSize.height < 70 {
			moreBtn.isHidden = true
		} else {
			moreBtn.isHidden = false
		}
	}
		
}
