//
//  AttachmentPhotoCell.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 04/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class AttachmentPhotoCell: UICollectionViewCell {
	@IBOutlet var scrollView:ImageScrollView?
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var shareBtn: UIButton!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		NotificationCenter.default.addObserver(self, selector: #selector(setZoomScale), name: .init(rawValue: "attachmentsSetZoomScale"), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func render(photo: [String: Any?]) {
		if let img = photo["image"] as? UIImage {
			self.imageView.image = img
			self.scrollView?.setImageView(imgView: imageView)
			activityIndicator.isHidden = true
			shareBtn.isHidden = false
		} else {
			activityIndicator.isHidden = false
			activityIndicator.startAnimating()
			shareBtn.isHidden = true;
		}
		shareBtn.tag = (photo["id"] as? Int) ?? 0
		
		if let scrollView = scrollView {
			scrollView.setZoomScale()
		}
	}
	
	
	@objc func setZoomScale() {
		if let scrollView = scrollView {
			scrollView.setZoomScale()
		}
	}
}
