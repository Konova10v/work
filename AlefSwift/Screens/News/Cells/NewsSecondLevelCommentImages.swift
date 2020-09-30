//
//  NewsSecondLevelCommentImages.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 10/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsSecondLevelCommentImages: NewsCell, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet private var collectionV: UICollectionView!
	
	var savedData: [String: Any?]?
	var photosAndVideos:[[String: Any?]] { savedData?["photosAndVideos"] as? [[String: Any?]] ?? []}
	
	override func render(data: [String : Any?]) {
		savedData = data
		collectionV.reloadData()
	}
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photosAndVideos.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentImageCell", for: indexPath)
		
		if let cell = cell as? CommentImageCell {
			cell.render(data: photosAndVideos[indexPath.item])
		}
		
		return cell
	}
	


}
