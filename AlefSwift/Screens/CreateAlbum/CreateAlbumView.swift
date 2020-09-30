//
//  CreateAlbumView.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CreateAlbumView: BaseView {
    
    @IBOutlet private var albumNameTxt: UITextField!
    @IBOutlet private var createAlbumBtn: UIButton!
    
	override func customizeUI() {
        albumNameTxt.becomeFirstResponder()
	}
	
    override func render() {
        if state["wasEdited"] as? Bool ?? false {
            albumNameTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Введите название альбома", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        createAlbumBtn.isEnabled =
            (state["albumName"] as? String ?? "" != "")
        createAlbumBtn.isUserInteractionEnabled = createAlbumBtn.isEnabled
        createAlbumBtn.backgroundColor = createAlbumBtn.isEnabled ? #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1) : #colorLiteral(red: 0.7254901961, green: 0.7254901961, blue: 0.7254901961, alpha: 1)
		super.render()   
    }
    
}
