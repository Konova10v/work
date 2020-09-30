//
//  CreateEditPostView.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit

class CreateEditPostView: BaseView, UICollectionViewDataSource, UITableViewDataSource {
    
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2;
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath);
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath);
    }
}
