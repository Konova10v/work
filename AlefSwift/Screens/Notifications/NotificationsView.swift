//
//  NotificationsView.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NotificationsView: BaseView, UITableViewDataSource {
    
    @IBOutlet weak var tableV: UITableView!
    @IBOutlet private var clearNotificationsBtn: UIButton!
    
    var notifications : [[String: Any?]] { state["notifications"] as? [[String: Any?]] ?? [] }
	override func customizeUI() {

	}
	
    override func render() {
        tableV.reloadData()
        clearNotificationsBtn.isEnabled = !notifications.isEmpty
        clearNotificationsBtn.isUserInteractionEnabled = clearNotificationsBtn.isEnabled
        clearNotificationsBtn.backgroundColor = clearNotificationsBtn.isEnabled ? #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1) : #colorLiteral(red: 0.7254901961, green: 0.7254901961, blue: 0.7254901961, alpha: 1)

		super.render()   
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.render(data: notifications[indexPath.row])
        return cell
    }
}
