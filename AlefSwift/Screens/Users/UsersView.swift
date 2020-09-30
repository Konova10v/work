//
//  UsersView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class UsersView: BaseView, UITableViewDataSource {
	private var showTab = false
	
	private var setHeightTask: DispatchWorkItem?
	private var tableHeightConstraintForEmbededMode: NSLayoutConstraint?
	@IBOutlet private var tableV: UITableView!
	@IBOutlet private var navHeightConstraint: NSLayoutConstraint!
	@IBOutlet private var titleLbl: UILabel!
	
	override func customizeUI() {
		
	}
	
    override func render() {
		super.render();
		switch state["mode"] as? UserVCModes ?? .staff{
		case .groupMembers:
			titleLbl.text = state["group_name"] as? String ?? "Группа"
			showTab = false
			navHeightConstraint.priority = .defaultLow
		case .likers:
			titleLbl.text = "Понравилось"
			showTab = false
			navHeightConstraint.priority = .defaultLow
		case .followers:
			titleLbl.text = "Подписки и подписчики"
			showTab = true
			navHeightConstraint.priority = .defaultLow
		case .staff:
			titleLbl.text = "Сотрудники TUI"
			showTab = false
			navHeightConstraint.priority = .defaultLow
		case .search:
			titleLbl.text = ""
			showTab = false
			navHeightConstraint.priority = .defaultHigh
		}
		tableV.reloadData()
		layoutIfNeeded()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt = 5;
		if showTab {
			cnt += 1
		}
				
				
		return cnt;
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		scheduleHeightUpdateAfterReload()
		
		if showTab {
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "TabSpecialCell", for: indexPath);
				
				return cell
			} else {
				//			let currentRow = indexPath.row - 1
				//			print ("User: " + currentRow.description)
				return tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath);
			}
		} else {
			return tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath);
		}
    }
	
	func scheduleHeightUpdateAfterReload() {
		if let task = setHeightTask {
			task.cancel();
		}
		setHeightTask = DispatchWorkItem {
			var height = self.tableV.contentSize.height
			if height < 100 {
				height = 100
			}
			self.tableHeightConstraintForEmbededMode?.constant = height
		}
		DispatchQueue.main.asyncAfter(deadline: .now(), execute: setHeightTask!)
	}
	
	func prepareForEmbedding() {
		translatesAutoresizingMaskIntoConstraints = false
		tableV.reloadData()
		tableV.isScrollEnabled = false
		var height = tableV.contentSize.height
		if height < 100 {
			height = 100
		}
		tableHeightConstraintForEmbededMode = tableV.heightAnchor.constraint(equalToConstant: height)
		tableHeightConstraintForEmbededMode?.isActive = true
		scheduleHeightUpdateAfterReload()
	}
}
