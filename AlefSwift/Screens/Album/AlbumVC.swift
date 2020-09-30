//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

enum AlbumVCMode {
	case my
	case their
}

class AlbumVC: BaseVC {
	private var mode: AlbumVCMode = .their
    override var v: AlbumView! { return self.view as? AlbumView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		v.onItemPressed = {[weak self] (item) in
			if let self = self {
				if let vc = UIStoryboard(name: "Attachments", bundle: nil).instantiateInitialViewController() {
					self.navigationController?.pushViewController(vc, animated: true)
				}
			}
		}
		
		v.onItemLongPressed = {[weak self] (item) in
			if let self = self {
				if self.mode == .my {
					var newState = self.state
					newState["editing"] = true
					self.state = newState
				}
			}
		}
    }
	
	func setScreenModeToMy() {
		mode = .my
	}
	
	func setScreenModeToTheir() {
		mode = .their
	}
	
	func loadFromServer() {
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			
			var newState:[String: Any?] = [
				"postContentAttachments": [
					[
						"id": 123,
						"name": "two.jpg",
						"fileUrl": "https://fotogora.ru/img/blog/or/2019/12/3/15986.jpg",
						"type": "photo"
					],
					[
						"id": 1,
						"name": "one.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/1.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/thmb2.jpeg",
						"type": "video"
					],
					[
						"id": 123,
						"name": "two.jpg",
						"fileUrl": "https://fotogora.ru/img/blog/or/2019/12/3/15986.jpg",
						"type": "photo"
					],					
					[
						"id": 2,
						"name": "two.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/2.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/thmb1.jpg",
						"type": "video"
					],[
						"id": 1,
						"name": "one.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/1.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/thmb2.jpeg",
						"type": "video"
					],
					  
					  [
						"id": 2,
						"name": "two.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/2.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/thmb1.jpg",
						"type": "video"
					],[
						"id": 1,
						"name": "one.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/1.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/thmb2.jpeg",
						"type": "video"
					],
					  
					  [
						"id": 2,
						"name": "two.mp4",
						"fileUrl": "https://ry.alef.im/intranet/files/posted/2.mp4",
						"previewUrl": "https://ry.alef.im/intranet/files/posted/thmb1.jpg",
						"type": "video"
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
					].filter {
						$0[AQ.fields.type] as? String ?? "" != "document"
				}
			];
			
			newState["mode"] = self.mode
			self.state = newState
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadFromServer();
	}
      
}

