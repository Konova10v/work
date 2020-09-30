//
//  NotificationCell.swift
//  AlefSwift
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet private var avatarImg: UIImageView!
    @IBOutlet private var nameLbl: UILabel!
    @IBOutlet private var dateLbl: UILabel!
    @IBOutlet private var typeNotificationLbl: UILabel!
    @IBOutlet private var notificationBtn: UIButton!
    
    func render(data: [String: Any?]) {
        avatarImg.sd_setImage(with: URL(string: data[AQ.fields.avatarUrl] as? String ?? ""), completed: nil)
        nameLbl.text = data[AQ.fields.title] as? String
        dateLbl.text = Date(timeIntervalSince1970: Double(data[AQ.fields.createdTimeStamp]  as? Int ?? 0)).russianInterval()
        typeNotificationLbl.text = data[AQ.fields.subtitle] as? String
        notificationBtn.tag = data[AQ.fields.id] as? Int ?? 1
    }
}
