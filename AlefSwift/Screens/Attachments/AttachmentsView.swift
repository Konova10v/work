//
//  AttachmentsView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import SDWebImage

class AttachmentsView: BaseView, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	@IBOutlet private var collectionView:UICollectionView?
	
	var onScrollViewDidStartScrolling: (()->Void)?
	var attachments: [[String: Any?]]? {
		state[AQ.fields.postContentAttachments] as? [[String: Any?]]
	}
	var currentPage = 0;
	
	override func customizeUI() {
		collectionView?.alpha = 0.0
	}
	
	func showCollectionView() {
		UIView.animate(withDuration: 0.2) {
			self.collectionView?.alpha = 1.0
		}
	}
	
	override func render() {
		collectionView?.reloadData()
		super.render()
	}
	
	func setZoomScale() {
		NotificationCenter.default.post(name: .init("attachmentsSetZoomScale"), object: nil);
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return attachments?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let attachment = attachments![indexPath.item];
		var cell:UICollectionViewCell;
		if attachment[AQ.fields.type] as? String ?? "" == "photo" {
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
			if let cell = cell as? AttachmentPhotoCell {
				cell.render(photo: attachment);
			}
		} else {
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath)
			if let cell = cell as? AttachmentVideoCell {
				cell.render(video: attachment);
			}
		}
		return cell;
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {		
		return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height);
	}
	
	func calculateCurrentPage() {		
		let parent = collectionView?.contentOffset.x ?? 0
		let child = collectionView?.frame.size.width ?? 1
		currentPage = Int(floor(parent / child));
		if currentPage < 0 {
			currentPage = 0;
		}
		
		if let attachments = attachments {
			if currentPage >= attachments.count {
				currentPage = attachments.count - 1;
			}
		}
	}
	
	func realignAfterOrientationChange () {
		let width = Int(collectionView?.frame.size.width ?? 0)
		collectionView?.setContentOffset(CGPoint(x: currentPage * width, y: 0), animated: false)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			if let visible = self.collectionView?.visibleCells {				
				for cell in visible {
					if let cell = cell as? AttachmentVideoCell {
						cell.reattachSublayer()
					}
				}
			}
		}
		
		self.setZoomScale();
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		if let onScrollViewDidStartScrolling = onScrollViewDidStartScrolling {
			onScrollViewDidStartScrolling();
		}
	}
	
}
