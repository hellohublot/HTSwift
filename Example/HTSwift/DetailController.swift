//
//  DetailController.swift
//  HTSwift_Example
//
//  Created by hublot on 2017/12/19.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import HTSwift

class DetailController: UIViewController {
	
	lazy var tableView: UITableView = {
		var tableView = UITableView(frame: view.bounds)
		tableView.register(HTCell.self, forCellReuseIdentifier: "1")
		return tableView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initDataSource()
		initInterface()
	}
	
	func initDataSource () {
		tableView.setCellModelArray(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"], proxy: self)
		tableView.reloadData()
	}
	
	func initInterface() {
		view.addSubview(tableView)
	}
	
}

extension DetailController: TableViewThrough {
	
	func cellClass<T>(_ reuseView: T, for indexPath: IndexPath) -> ReuseCell.Type where T : ReuseAbleView {
		return HTCell.self
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return reuseViewNumberOfSections(in: tableView)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reuseView(tableView, numberOfRowsInSection: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return reuseView(tableView, cellForRowAt: indexPath) as! UITableViewCell
	}
	
}
