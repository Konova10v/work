//
//  IntroView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class IntroView: BaseView {
    
	override func customizeUI() {
		// эта функция вызывается сразу после создания View
		// если вам нужно скрыть какие-то элементы, как-то настроить внешний вид,
		// то эта функция специально для таких задач
	}
	
    override func render() {
		// эта функция автоматически вызывается каждый раз,
		// когда во ViewController изменяется state

		super.render()   
    }
    
}
