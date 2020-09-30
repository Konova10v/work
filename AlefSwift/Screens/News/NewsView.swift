//
//  NewsView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NewsView: BaseView, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet var tableV: UITableView!
	private var tableHeightConstraintForEmbededMode: NSLayoutConstraint?
	var onControllerEmbeded: ((ProfileVC)->(Void))?
	var onNavBarRendered: ((UIView)->(Void))?
	var onUserClicked: ((Int)->(Void))?
	private var setHeightTask: DispatchWorkItem?
	
	var posts : [[String: Any?]] { state[AQ.fields.items] as? [[String: Any?]] ?? [] }
	
	var flatCells: [[String: Any?]]?
	override func customizeUI() {
		
	}
	
    override func render() {
		populateFlatCells()
		tableV.reloadData();		
		super.render()
    }
	
	func populateFlatCells() {
		flatCells = [];
		
		let mode = state["mode"] as? NewsVCMode ?? .homepage
		
		switch mode {
		case .group:
			flatCells!.append(["reuseIdentifier": "NewsNavBar"]);
			flatCells!.append(["reuseIdentifier": "NewsGroupInfo"]);
			flatCells!.append(["reuseIdentifier": "NewsCreate"]);
			flatCells!.append(["reuseIdentifier": "NewsFilter", "filter": state["filter"] as? [String: Any?] ?? [:]]);
		case .homepage:
			flatCells!.append(["reuseIdentifier": "NewsNavBar"]);
			flatCells!.append(["reuseIdentifier": "NewsCreate"]);
			flatCells!.append(["reuseIdentifier": "NewsFilter", "filter": state["filter"] as? [String: Any?] ?? [:]]);
		case .myProfile:
			flatCells!.append(["reuseIdentifier": "NewsProfile", "user_id": 0]);
		case .profile:
			flatCells!.append(["reuseIdentifier": "NewsProfile", "user_id": state["user_id"] ?? 0]);
		case .search:
			break
		}
		
		
		for post in posts
		{
			flatCells!.append(["reuseIdentifier": "NewsPostBody", "post": post, "mode": mode, "onUserClicked": onUserClicked]);
			if let postContent = post[AQ.fields.postContent] as? [String: Any?] {
				if let attachments = postContent[AQ.fields.postContentAttachments] as? [[String: Any?]] {
					for attachment in attachments {
						if attachment[AQ.fields.type] as? String ?? "" == "document" {
							flatCells!.append(["reuseIdentifier": "NewsPostDocument", "attachment": attachment]);
						}
					}
					
					let photosAndVideos = attachments.filter {$0[AQ.fields.type] as? String ?? "" == "photo" || $0[AQ.fields.type] as? String ?? "" == "video"}
					if photosAndVideos.count > 0 {
						flatCells!.append(["reuseIdentifier": "NewsPostImages", "photosAndVideos": photosAndVideos, "mode": mode]);
					}
					
					if let link = postContent[AQ.fields.openGraphItem] as? [String: Any?] {
						flatCells!.append(["reuseIdentifier": "NewsPostLink", "link": link, "mode": mode]);
					}
				}
			}

			flatCells!.append(["reuseIdentifier": "NewsPostCounters", "post": post, "mode": mode]);
			
			if let commentsContainer = post[AQ.fields.comments] as? [String: Any?] {
				if let comments = commentsContainer[AQ.fields.items] as? [[String: Any?]] {
					for comment in comments {
						flatCells!.append(["reuseIdentifier": "NewsFirstLevelCommentBody", "comment": comment, "mode": mode, "onUserClicked": onUserClicked]);
						if let postContent = comment[AQ.fields.postContent] as? [String: Any?] {
							if let attachments = postContent[AQ.fields.postContentAttachments] as? [[String: Any?]] {
								for attachment in attachments {
									if attachment[AQ.fields.type] as? String ?? "" == "document" {
										flatCells!.append(["reuseIdentifier": "NewsFirstLevelCommentDocument", "attachment": attachment, "mode": mode]);
									}
								}
								
								let photosAndVideos = attachments.filter {$0[AQ.fields.type] as? String ?? "" == "photo" || $0[AQ.fields.type] as? String ?? "" == "video"}
								if photosAndVideos.count > 0 {
									flatCells!.append(["reuseIdentifier": "NewsFirstLevelCommentImages", "photosAndVideos": photosAndVideos, "mode": mode]);
								}
							}
						}
						flatCells!.append(["reuseIdentifier": "NewsFirstLevelCommentCounters", "comment": comment, "mode": mode]);
						let responces = populateFlatCellsForSubcomments(forComment: comment)
						flatCells!.append(contentsOf: responces)
					}
				}
			}
		}
	}
	
	func populateFlatCellsForSubcomments(forComment comment: [String: Any?]) -> [[String: Any?]] {
		var flatCells: [[String: Any?]] = []
		
		if let comments = comment[AQ.fields.comments] as? [[String: Any?]] {
			for comment in comments {
				flatCells.append(["reuseIdentifier": "NewsSecondLevelCommentBody", "comment": comment, "onUserClicked": onUserClicked]);
				if let postContent = comment[AQ.fields.postContent] as? [String: Any?] {
					if let attachments = postContent[AQ.fields.postContentAttachments] as? [[String: Any?]] {
						for attachment in attachments {
							if attachment[AQ.fields.type] as? String ?? "" == "document" {
								flatCells.append(["reuseIdentifier": "NewsSecondLevelCommentDocument", "attachment": attachment]);
							}
						}
						
						let photosAndVideos = attachments.filter {$0[AQ.fields.type] as? String ?? "" == "photo" || $0[AQ.fields.type] as? String ?? "" == "video"}
						if photosAndVideos.count > 0 {
							flatCells.append(["reuseIdentifier": "NewsSecondLevelCommentImages", "photosAndVideos": photosAndVideos]);
						}
					}
				}
				flatCells.append(["reuseIdentifier": "NewsSecondLevelCommentCounters", "comment": comment]);
			}
		}
		return flatCells
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let cnt = flatCells?.count ?? 0
		return cnt
	}
		
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		scheduleHeightUpdateAfterReload()
		guard
			let data = flatCells?[indexPath.row],
			let reuseID = data["reuseIdentifier"] as? String
		else {
			return UITableViewCell()
		}
		
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! NewsCell
		
		if let nav = cell as? NewsNavBar {
			if let onNavBarRendered = onNavBarRendered {
				onNavBarRendered(nav.leftBtn)
			}
		}
		
		if let profile = cell as? NewsProfile {
			profile.onControllerEmbeded = onControllerEmbeded
		}
		
		cell.render(data: data)
		
		let bgColorView = UIView()
		bgColorView.backgroundColor = .white
		cell.selectedBackgroundView = bgColorView
		
		return cell
	}
	
	func scheduleHeightUpdateAfterReload() {
		if let task = setHeightTask {
			task.cancel();
		}
		setHeightTask = DispatchWorkItem {
			var height = self.tableV.contentSize.height
			if height < 1000 {
				height = 1000
			}
			self.tableHeightConstraintForEmbededMode?.constant = height
			self.layoutIfNeeded()
		}
		DispatchQueue.main.asyncAfter(deadline: .now(), execute: setHeightTask!)
	}
	
	func prepareForEmbedding() {
		translatesAutoresizingMaskIntoConstraints = false
		tableV.reloadData()
		tableV.isScrollEnabled = false
		var height = tableV.contentSize.height
		if height < 1000 {
			height = 1000
		}
		tableHeightConstraintForEmbededMode = tableV.heightAnchor.constraint(equalToConstant: height)
		tableHeightConstraintForEmbededMode?.isActive = true
		scheduleHeightUpdateAfterReload()
	}
    
}
