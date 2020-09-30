//
//  HtmlArticleView.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import WebKit

class HtmlArticleView: BaseView {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet private var pastPageBtn: UIButton!
    
    override func customizeUI() {
        pastPageBtn.isHidden = true
	}
	
    override func render() {
        if (state["history"] as! [String]).count <= 1 {
            pastPageBtn.isHidden = true
        } else {
            pastPageBtn.isHidden = false
        }
        
        let request = URLRequest(url: URL(string: (state["history"] as! [String]).last ?? "")!)
        webView.load(request)
		super.render()   
    }
    
}
