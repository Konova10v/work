//
//  NewsPostImages.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsPostImages: NewsCell {
	@IBOutlet private var firstImg: UIImageView!
	@IBOutlet private var secondImg: UIImageView!
	@IBOutlet private var thirdImg: UIImageView!
	@IBOutlet private var additionalImagesOverlayV: UIView!
	@IBOutlet private var additionalImagesCountLbl: UILabel!
	@IBOutlet private var moreImagesView: UIView!
	@IBOutlet var firstBtn: UIButton!
	@IBOutlet var secondBtn: UIButton!
	@IBOutlet var thirdBtn: UIButton!
	
	override func render(data: [String: Any?]) {
		if let photosAndVideos = data["photosAndVideos"] as? [[String: Any?]] {
			let numberOfImages = photosAndVideos.count
			if numberOfImages == 1 {
				moreImagesView.isHidden = true
				secondImg.isHidden = true
				thirdImg.isHidden = true
				additionalImagesOverlayV.isHidden = true
				additionalImagesCountLbl.text = ""
				preview(attachment: photosAndVideos[0], inImageView: firstImg)
				firstBtn.accessibilityLabel = photosAndVideos[0][AQ.fields.unique_id] as? String ?? ""
			} else if numberOfImages == 2 {
				moreImagesView.isHidden = false
				secondImg.isHidden = false
				thirdImg.isHidden = true
				additionalImagesOverlayV.isHidden = true
				additionalImagesCountLbl.text = ""
				preview(attachment: photosAndVideos[0], inImageView: firstImg)
				preview(attachment: photosAndVideos[1], inImageView: secondImg)
				firstBtn.accessibilityLabel = photosAndVideos[0][AQ.fields.unique_id] as? String ?? ""
				secondBtn.accessibilityLabel = photosAndVideos[1][AQ.fields.unique_id] as? String ?? ""
			} else if numberOfImages == 3 {
				moreImagesView.isHidden = false
				secondImg.isHidden = false
				thirdImg.isHidden = false
				additionalImagesOverlayV.isHidden = true
				additionalImagesCountLbl.text = ""
				preview(attachment: photosAndVideos[0], inImageView: firstImg)
				preview(attachment: photosAndVideos[1], inImageView: secondImg)
				preview(attachment: photosAndVideos[2], inImageView: thirdImg)
				firstBtn.accessibilityLabel = photosAndVideos[0][AQ.fields.unique_id] as? String ?? ""
				secondBtn.accessibilityLabel = photosAndVideos[1][AQ.fields.unique_id] as? String ?? ""
				thirdBtn.accessibilityLabel = photosAndVideos[2][AQ.fields.unique_id] as? String ?? ""
			} else {
				moreImagesView.isHidden = false
				secondImg.isHidden = false
				thirdImg.isHidden = false
				additionalImagesOverlayV.isHidden = false
				additionalImagesCountLbl.text = String(numberOfImages - 3) + "+"
				preview(attachment: photosAndVideos[0], inImageView: firstImg)
				preview(attachment: photosAndVideos[1], inImageView: secondImg)
				preview(attachment: photosAndVideos[2], inImageView: thirdImg)
				firstBtn.accessibilityLabel = photosAndVideos[0][AQ.fields.unique_id] as? String ?? ""
				secondBtn.accessibilityLabel = photosAndVideos[1][AQ.fields.unique_id] as? String ?? ""
				thirdBtn.accessibilityLabel = photosAndVideos[2][AQ.fields.unique_id] as? String ?? ""
			}
		}
	}
	
	func preview(attachment: [String: Any?], inImageView imgV: UIImageView) {
		let type = attachment[AQ.fields.type] as? String ?? ""
		
		if type == "photo" {
			if let url = attachment[AQ.fields.fileUrl] as? String {
				imgV.sd_setImage(with: URL(string: url), completed: nil)
			}
		}
		
		if type == "video" {
			if let url = attachment[AQ.fields.previewUrl] as? String {
				imgV.sd_setImage(with: URL(string: url), completed: nil)
			}
		}
	}

}
