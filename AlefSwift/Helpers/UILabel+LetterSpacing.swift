//
//  UILabel+LetterSpacing.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 13/07/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
	
	@IBInspectable
	var letterSpacing: CGFloat {
		set {
			let attributedString: NSMutableAttributedString!
			if let currentAttrString = attributedText {
				attributedString = NSMutableAttributedString(attributedString: currentAttrString)
			}
			else {
				attributedString = NSMutableAttributedString(string: text ?? "")
				text = nil
			}
			
			attributedString.addAttribute(NSAttributedString.Key.kern,
										  value: newValue,
										  range: NSRange(location: 0, length: attributedString.length))
			
			attributedText = attributedString
		}
		
		get {
			if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
				return currentLetterSpace
			}
			else {
				return 0
			}
		}
	}
}