//
//  String+Plural.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 17/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

extension Int {
	func russianPlural(form1: String, form2: String, form5: String) -> String {
		let n = abs(self) % 100;
		let n1 = n % 10;
		if (n > 10 && n < 20) {
			return form5;
		}
		
		if (n1 > 1 && n1 < 5) {
			return form2;
		}
		
		if (n1 == 1) {
			return form1;
		}
		return form5;
	}

}
