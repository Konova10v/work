//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Кирилл Коновалов.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import WebKit

class HtmlArticleVC: BaseVC, WKNavigationDelegate {
    override var v: HtmlArticleView! { return self.view as? HtmlArticleView }
    var urlArray: [String] = []
    
    override func viewDidLoad() {
		super.viewDidLoad();
        v.webView.navigationDelegate = self
		state = [
            "history": urlArray
        ]
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                UIApplication.shared.canOpenURL(url) {
                urlArray.append(url.description)
                state["history"] = urlArray
                decisionHandler(.allow)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    @IBAction func previousPageBtnPressed(_ sender: UIButton) {
        urlArray.removeLast()
        state["history"] = urlArray
    }
}
