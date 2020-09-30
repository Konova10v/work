//
//  EditProfileView.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class EditProfileView: BaseView, UITextFieldDelegate {
    
    @IBOutlet private var howCanHelpTxt: UITextView!
    @IBOutlet private var phoneNumberTxt: UITextField!
    @IBOutlet private var locationTxt: UITextField!
    @IBOutlet private var facebookTxt: UITextField!
    @IBOutlet private var vkTxt: UITextField!
    @IBOutlet private var twitterTxt: UITextField!
    @IBOutlet private var instagramTxt: UITextField!
    @IBOutlet private var editProfileBtn: UIButton!
    
    override func customizeUI() {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            phoneNumberTxt.keyboardType = .numberPad
        }
    }
    
    override func render() {
        super.render()
        guard let profile = state["myProfile"] as? [String: Any?] else { return }

        howCanHelpTxt.text = profile[AQ.fields.howCanHelp] as? String ?? ""
        phoneNumberTxt.text = profile[AQ.fields.mobilePhone] as? String ?? ""
        locationTxt.text = profile[AQ.fields.location] as? String ?? ""

        guard let social = profile[AQ.fields.socialUrls] as? [[String: Any?]] else { return }
        for item in social {
            if item[AQ.fields.socialTypeTxt] as? String ?? "" == "fb" {
                facebookTxt.text = item[AQ.fields.url] as? String ?? ""
            } else if item[AQ.fields.socialTypeTxt] as? String ?? "" == "twitter" {
                twitterTxt.text = item[AQ.fields.url] as? String ?? ""
            } else if item[AQ.fields.socialTypeTxt] as? String ?? "" == "vk" {
                vkTxt.text = item[AQ.fields.url] as? String ?? ""
            } else if item[AQ.fields.socialTypeTxt] as? String ?? "" == "instagram" {
                instagramTxt.text = item[AQ.fields.url] as? String ?? ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationTxt {
            facebookTxt.becomeFirstResponder()
        } else if textField == facebookTxt {
            vkTxt.becomeFirstResponder()
        } else if textField == vkTxt {
            twitterTxt.becomeFirstResponder()
        } else if textField == twitterTxt {
            instagramTxt.becomeFirstResponder()
        } else {
            instagramTxt.resignFirstResponder()
        }
        return true
    }
}
