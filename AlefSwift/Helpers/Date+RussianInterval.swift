//
//  String+Plural.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер on 17/09/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

extension Date {
	func russianInterval() -> String {
		let months = ["", "января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"]
		let ti = Date().timeIntervalSince(self)
		if ti < 60 {
			return "меньше минуты назад"
		}
		
		if ti < 3600 {
			let minutes = Int(floor(ti / 60))
			return minutes.description + " " + minutes.russianPlural(form1: "минута", form2: "минуты", form5: "минут") + " назад"
		}
		
		let calendar = Calendar.init(identifier: .gregorian)
		let dtComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
		let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
		
		if dtComponents.year == nowComponents.year && dtComponents.month == nowComponents.month && dtComponents.day == nowComponents.day {
			let hours = Int(floor(ti / 3600))
			return hours.description + " " + hours.russianPlural(form1: "час", form2: "часа", form5: "часов") + " назад"
		}
		
		if dtComponents.year == nowComponents.year && dtComponents.month == nowComponents.month && dtComponents.day == (nowComponents.day ?? 0) - 1 {
			 return "вчера"
		}
		
		if dtComponents.year == nowComponents.year && dtComponents.month == nowComponents.month && dtComponents.day == (nowComponents.day ?? 0) - 2 {
			return "позавчера"
		}
		
		if dtComponents.year == nowComponents.year && dtComponents.month == nowComponents.month && dtComponents.day == (nowComponents.day ?? 0) + 1 {
			return "завтра"
		}
		
		if dtComponents.year == nowComponents.year && dtComponents.month == nowComponents.month && dtComponents.day == (nowComponents.day ?? 0) + 2 {
			return "послезавтра"
		}
		
		if dtComponents.year == nowComponents.year {
			return (dtComponents.day ?? 1).description + " " + months[dtComponents.month ?? 1]
		}
		
		return (dtComponents.day ?? 1).description + " " + months[dtComponents.month ?? 1] + " " + (dtComponents.year ?? 2020).description		
	}
}
