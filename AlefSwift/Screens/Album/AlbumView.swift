//
//  AlbumView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class AlbumView: BaseView, UICollectionViewDataSource {
    
	@IBOutlet var deleteAlbumBtn: UIButton!
	@IBOutlet var editCommitPanel: UIView!
	@IBOutlet var collectionV: UICollectionView!
	
	var onItemPressed: (([String: Any?])->())?
	var onItemLongPressed: (([String: Any?])->())?
	
	var mode: AlbumVCMode { state["mode"] as? AlbumVCMode ?? .their }
	var editing: Bool { state["editing"] as? Bool ?? false }
	var items: [[String: Any?]] { state[AQ.fields.postContentAttachments] as? [[String: Any?]] ?? [] }
	
	override func customizeUI() {
	
	}
	
    override func render() {
		editCommitPanel.isHidden = !editing
		deleteAlbumBtn.isHidden = mode == .their
		collectionV.reloadData()
		super.render()   
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var cnt = items.count;
		if mode == .my {
			cnt += 1
		}
		return cnt
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		var row = indexPath.row
		if mode == .my {
			row -= 1
		}
		
		if mode == .my && indexPath.row == 0 {
			return collectionView.dequeueReusableCell(withReuseIdentifier: "TakePictureCell", for: indexPath);
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumItemCell", for: indexPath) as! AlbumItemCell;
			var item: [String: Any?] = items[row]
			item["editing"] = editing
			cell.render(item: item)
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector (itemTapped(gesture:)))
			let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(itemLongTapped(gesture:)))
			tapGesture.numberOfTapsRequired = 1
			cell.addGestureRecognizer(tapGesture)
			cell.addGestureRecognizer(longGesture)
			cell.tag = item["id"] as? Int ?? 0
			return cell
		}
	}
	
	@objc func itemTapped(gesture: UITapGestureRecognizer) {
		if let id = gesture.view?.tag {
			if let item = items.first(where: { (item) -> Bool in
				item["id"] as? Int ?? 0 == id
			}) {
				if let onItemPressed = onItemPressed {
					onItemPressed(item)
				}
			}
		}
		
	}
	
	@objc func itemLongTapped(gesture: UILongPressGestureRecognizer) {
		if let id = gesture.view?.tag {
			if let item = items.first(where: { (item) -> Bool in
				item["id"] as? Int ?? 0 == id
			}) {
				if let onItemLongPressed = onItemLongPressed {
					onItemLongPressed(item)
				}
			}
		}
	}
}
