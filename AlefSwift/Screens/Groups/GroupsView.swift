//
//  GroupsView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class GroupsView: BaseView, UITableViewDataSource {
	private var showFilter = true
	
	private var setHeightTask: DispatchWorkItem?
	private var tableHeightConstraintForEmbededMode: NSLayoutConstraint?
	@IBOutlet private var tableV: UITableView!
	@IBOutlet private var navHeightConstraint: NSLayoutConstraint!
    
	override func customizeUI() {
	}
	
    override func render() {
		
		super.render();
		switch state["mode"] as? GroupsVCModes ?? .groups{
		case .groups:
			navHeightConstraint.priority = .defaultLow
			showFilter = true
		case .search:
			navHeightConstraint.priority = .defaultHigh
			showFilter = false
		}
		tableV.reloadData()
		layoutIfNeeded()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var cnt = 5;
		
		if showFilter {
			cnt += 1
		}
		
		return cnt;
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		scheduleHeightUpdateAfterReload()
		
		if showFilter {
			if indexPath.row == 0 {
				return tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath);
			} else {
				//			let currentRow = indexPath.row - 1
				//			print ("Group: " + currentRow.description)
				return tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath);
			}
		} else {
			return tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath);
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
