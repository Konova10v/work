//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CreateAlbumVC: BaseVC {
    override var v: CreateAlbumView! { return self.view as? CreateAlbumView }
    
    override func viewDidLoad() {
		super.viewDidLoad();
		state = [
            "albumName": "",
            "wasEdited": false
        ]
    }
    
    @IBAction func albumNameEditingChange(_ sender: UITextField) {
        state["wasEdited"] = true
        state["albumName"] = sender.text
    }
      
	@IBAction func saveBtnPressed(_ sender: Any) {
		self.showLoadingIndicator()
        AQ.addAlbum(name: state["albumName"] as? String ?? "", failure: { (error) in
            AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
                self.saveBtnPressed(sender)
            }
        }) { (result) in
            self.hideLoadingIndicator()
            AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
                self.returnFromVC()
            }) {
                self.saveBtnPressed(sender)
            }
        }
	}
}

