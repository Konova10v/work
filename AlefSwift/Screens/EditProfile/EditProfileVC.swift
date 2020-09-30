//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class EditProfileVC: BaseVC, UITextFieldDelegate, UITextViewDelegate {
    override var v: EditProfileView! { return self.view as? EditProfileView }
    
    private var profileData: [String: Any]? {
        get {
            if let profile = state["myProfile"] as? [String:Any] {
                return profile
            }
            return nil
        }
        set {
            state["myProfile"] = newValue
        }
    }
    
    private var socialUrl: [[String: Any?]]? {
        get {
            if let social = profileData?[AQ.fields.socialUrls] as? [[String: Any]]? {
                return social
            }
            return nil
        }
        set {
            profileData?[AQ.fields.socialUrls] = newValue
        }
    }
    
    func getMyProfile() {
        self.showLoadingIndicator()
        
        AQ.getMyProfile { (error) in
            AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
                self.getMyProfile()
            }
        } success: { (result) in
            self.hideLoadingIndicator()
            AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
                self.state["myProfile"] = result[AQ.fields.user] as? [String: Any?] ?? []
            }) {
                self.getMyProfile()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        getMyProfile()
        state = [
            "myProfile": [:]
        ]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.accessibilityIdentifier == "phoneNumber" {
            let allowedCharacters = "+1234567890"
            let allowedCharcterSet = CharacterSet(charactersIn: allowedCharacters)
            let typedCharcterSet = CharacterSet(charactersIn: string)
            return allowedCharcterSet.isSuperset(of: typedCharcterSet)
        }
        return true
    }
    
    @IBAction func phoneNumberEditingChange(_ sender: UITextField) {
        profileData?[AQ.fields.mobilePhone] = sender.text
    }
    
    @IBAction func locationEditingChange(_ sender: UITextField) {
        profileData?[AQ.fields.location] = sender.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        profileData?[AQ.fields.howCanHelp] = textView.text
    }
    
    @IBAction func facebookEditingChange(_ sender: UITextField) {
        if let row = self.socialUrl?.firstIndex(where: {$0[AQ.fields.socialTypeTxt] as! String == "fb"}) {
            socialUrl?[row].updateValue(sender.text ?? "", forKey: "url")
        }
    }
    
    @IBAction func vkEditingChange(_ sender: UITextField) {
        if let row = self.socialUrl?.firstIndex(where: {$0[AQ.fields.socialTypeTxt] as! String == "vk"}) {
            socialUrl?[row].updateValue(sender.text ?? "", forKey: "url")
        }
    }
    
    @IBAction func twitterEditingChange(_ sender: UITextField) {
        if let row = self.socialUrl?.firstIndex(where: {$0[AQ.fields.socialTypeTxt] as! String == "twitter"}) {
            socialUrl?[row].updateValue(sender.text ?? "", forKey: "url")
        }
    }
    
    @IBAction func instagramEditingChange(_ sender: UITextField) {
        if let row = self.socialUrl?.firstIndex(where: {$0[AQ.fields.socialTypeTxt] as! String == "instagram"}) {
            socialUrl?[row].updateValue(sender.text ?? "", forKey: "url")
        }
    }
      
    @IBAction func saveBtnPressed(_ sender: Any) {
        var facebook: String = ""
        var vk: String = ""
        var twitter: String = ""
        var instagram: String = ""
        
        socialUrl?.forEach{
            if $0[AQ.fields.socialTypeTxt] as! String == "fb" {
                facebook = $0[AQ.fields.url] as! String
            } else if $0[AQ.fields.socialTypeTxt] as! String == "vk" {
                vk = $0[AQ.fields.url] as! String
            } else if $0[AQ.fields.socialTypeTxt] as! String == "twitter" {
                twitter = $0[AQ.fields.url] as! String
            } else if $0[AQ.fields.socialTypeTxt] as! String == "instagram" {
                instagram = $0[AQ.fields.url] as! String
            }
        }
        
        self.showLoadingIndicator()
        AQ.editProfile(mobile_phone: profileData?[AQ.fields.mobilePhone] as? String ?? "", location: profileData?[AQ.fields.location] as? String ?? "", how_can_help: profileData?[AQ.fields.howCanHelp] as? String ?? "", fb_url: facebook, vk_url: vk, twitter_url: twitter, instagram_url: instagram, failure: { (error) in
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
