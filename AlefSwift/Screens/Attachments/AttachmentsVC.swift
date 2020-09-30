//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

class AttachmentsVC: BaseVC {

	
	override var v: AttachmentsView! { return self.view as? AttachmentsView }
	
	var attachments: [[String: Any?]]? {
		state[AQ.fields.postContentAttachments] as? [[String: Any?]]
	}
	
	
    override func viewDidLoad() {
		super.viewDidLoad();
		
		v.onScrollViewDidStartScrolling = {[weak self] in
			self?.stopAllVideos();
		}
    }
	
	func setAttachments(_ attachments: [[String: Any?]]) {
		DispatchQueue.main.async {
			self.state = [
				AQ.fields.postContentAttachments: attachments.filter { $0[AQ.fields.type] as? String ?? "" != "document" }
			];
			self.loadAttachments()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.v.setZoomScale()
		v.showCollectionView()
		
		if self.state[AQ.fields.postContentAttachments] == nil {
			state = [
				"postContentAttachments": [
					[
						"id": 9,
						"name": "001.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/001.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/001.png",
						"type": "video"
					],
					[
						"id": 2,
						"name": "002.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/002.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/002.png",
						"type": "video"
					],
					[
						"id": 123,
						"name": "003.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/003.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/003.png",
						"type": "video"
					],
					[
						"id": 234,
						"name": "004.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/004.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/004.jpeg",
						"type": "video"
					],
					[
						"id": 3454,
						"name": "005.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/005.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/005.jpg",
						"type": "video"
					],
					[
						"id": 452,
						"name": "one.jpg",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/1.jpg",
						"type": "photo"
					],
					[
						"id": 123,
						"name": "two.jpg",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/2.jpg",
						"type": "photo"
					],
					[
						"id": 26,
						"name": "one.pdf",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/1.pdf",
						"type": "document"
					],
					[
						"id": 12222,
						"name": "two.pdf",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/2.pdf",
						"type": "document"
					]
					].filter { $0[AQ.fields.type] as? String ?? "" != "document" }
			];
		}
	}
		
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated);
		stopAllVideos();
	}
	
	func stopAllVideos() {
		var newAttachments:[[String: Any?]] = []
		self.attachments?.forEach({ (attachment) in
			var mutableAttachment = attachment;
			mutableAttachment["shouldPlay"] = false
			newAttachments.append(mutableAttachment);
		})
		var newState:[String: Any?] = self.state
		newState = [AQ.fields.postContentAttachments : newAttachments]
		self.state = newState
	}
	
	func loadPhoto(_ photo: [String: Any?]) {
		if let url = photo[AQ.fields.fileUrl] as? String{
			SDWebImageManager.shared.loadImage(with: URL(string: url), options: .retryFailed, progress: nil) { (img, data, error, cache, success, url) in
				if(success) {
					if let img = img {
						self.change(property: "image", to: img, inAttachment: photo[AQ.fields.id] as! Int)
					}
				}
			}
		}
	}
	
	func change(property: String, to value: Any, inAttachment id: Int) {
		var newAttachments:[[String: Any?]] = []
		self.attachments?.forEach({ (source) in
			if let source_id = source[AQ.fields.id] as? Int {
				if source_id == id {
					var mutableVideo = source;
					mutableVideo[property] = value
					newAttachments.append(mutableVideo);
				} else {
					newAttachments.append(source);
				}
			}
		})
		var newState:[String: Any?] = state
		newState[AQ.fields.postContentAttachments] = newAttachments
		self.state = newState
	}
		
	func loadVideo(_ video: [String: Any?]) {
		if let url = video[AQ.fields.previewUrl] as? String{
			SDWebImageManager.shared.loadImage(with: URL(string: url), options: .retryFailed, progress: nil) { (img, data, error, cache, success, url) in
				if(success) {
					if let img = img {
						self.change(property: "preview", to: img, inAttachment: video[AQ.fields.id] as! Int)
					}
				}
			}
		}
		
		
		
		if let url = URL(string: video[AQ.fields.fileUrl] as? String ?? "") {
			let asset = AVAsset(url: url)
			let playerItem = AVPlayerItem(asset: asset)
			let player = AVQueuePlayer(playerItem: playerItem)
			let playerLayer = AVPlayerLayer(player: player)
			let playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
			
			change(property: "asset", to: asset, inAttachment: video[AQ.fields.id] as! Int)
			change(property: "playerItem", to: playerItem, inAttachment: video[AQ.fields.id] as! Int)
			change(property: "player", to: player, inAttachment: video[AQ.fields.id] as! Int)
			change(property: "playerLayer", to: playerLayer, inAttachment: video[AQ.fields.id] as! Int)
			change(property: "playerLooper", to: playerLooper, inAttachment: video[AQ.fields.id] as! Int)			
		}
	}
		
	
	func loadAttachments () {
		attachments?.forEach({ (attachment) in
			if attachment[AQ.fields.type] as? String ?? ""  == "photo" {
				loadPhoto(attachment)
			} else if attachment[AQ.fields.type] as? String ?? "" == "video" {
				loadVideo(attachment)
			}
		})
	}
	
	override func viewDidLayoutSubviews() {
		v.setZoomScale()
	}
	
	@IBAction func shareBtnPressed(_ sender: UIButton) {
		let id = sender.tag;
		let active = attachments?.first {(($0["id"] as? Int) ?? 0) == id};
		if active?[AQ.fields.type] as? String ?? "" == "photo" {
			if let image = active?["image"] as? UIImage {
				let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
				present(vc, animated: true)
			}
		} else {
			if let fileUrl = active?[AQ.fields.fileUrl] as? String {
				let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: [])
				present(vc, animated: true)
			}
		}
	}
	
	@IBAction func playBtnPressed(_ sender: UIButton) {
		let id = sender.tag
		let active = attachments?.first {(($0["id"] as? Int) ?? 0) == id}
		if let active = active {
			let currentState = active["shouldPlay"] as? Bool ?? false
			change(property: "shouldPlay", to: !currentState, inAttachment: active[AQ.fields.id] as! Int)
		}
		
		
	}
	
	
	@IBAction func closeBtnPressed(_ sender: Any) {
		returnFromVC()
	}
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		self.v.calculateCurrentPage()		
		coordinator.animate(alongsideTransition: { (context) in
			
		}) { (context) in
			self.v.realignAfterOrientationChange()
		}
	}
	
	@IBAction func volumeBtnPressed(_ sender: UIButton) {
		let id = sender.tag;
		let active = attachments?.first {(($0["id"] as? Int) ?? 0) == id};
		let muted = active?["muted"] as? Bool ?? true
		change(property: "muted", to: !muted, inAttachment: id)
	}		
	
}

