//
//  AttachmentVideoCell.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 05/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import AVFoundation

class AttachmentVideoCell: UICollectionViewCell {
	@IBOutlet var videoPlayer: UIView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	@IBOutlet var volumeBtn: UIButton!
	@IBOutlet var playBtn: UIButton!
	@IBOutlet var bigPlayBtn: UIButton!
	@IBOutlet var previewImg: UIImageView!
	

		
	@IBOutlet var shareBtn: UIButton!
	
	private var state: [String: Any?]?
		
	func reattachSublayer () {
		if let playerLayer = state?["playerLayer"] as? AVPlayerLayer {
			layoutIfNeeded()
			
			
			playerLayer.frame = self.videoPlayer.bounds
			playerLayer.videoGravity = .resizeAspect
			
			if let sublayers = self.videoPlayer.layer.sublayers {
				for s in sublayers {
					if let s = s as? AVPlayerLayer {
						s.removeFromSuperlayer();
					}
				}
			}
			self.videoPlayer.layer.addSublayer(playerLayer)
		}

	}
	
	func render(video: [String: Any?]) {
		state = video;
		if let player = video["player"] as? AVPlayer {
			if (video["shouldPlay"] as? Bool ?? false) {
				reattachSublayer()
				player.play()
				videoPlayer.isHidden = false
				playBtn.isHighlighted = true
				previewImg.isHidden = true
				activityIndicator.isHidden = true
				volumeBtn.isHidden = false;
				if (video["muted"] as? Bool ?? true) {
					player.volume = 0.0
					volumeBtn.alpha = 0.5
				} else {
					player.volume = 1.0
					volumeBtn.alpha = 1.0
				}
			} else {
				player.pause()
				playBtn.isHighlighted = false
				volumeBtn.isHidden = true;
				videoPlayer.isHidden = true;
				if let preview = video["preview"] as? UIImage {
					previewImg.image = preview
					previewImg.isHidden = false
					activityIndicator.isHidden = true
				} else {
					previewImg.isHidden = true
					activityIndicator.isHidden = false
					activityIndicator.startAnimating()
				}
			}
		}
		
				
		
					
		
		bigPlayBtn.tag = (video["id"] as? Int) ?? 0
		playBtn.tag = (video["id"] as? Int) ?? 0
		shareBtn.tag = (video["id"] as? Int) ?? 0
		volumeBtn.tag = (video["id"] as? Int) ?? 0
		
		
	}
		
}
