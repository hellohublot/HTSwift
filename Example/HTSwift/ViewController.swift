//
//  ViewController.swift
//  HTSwift
//
//  Created by hellohublot on 12/11/2017.
//  Copyright (c) 2017 hellohublot. All rights reserved.
//

import UIKit
import HTSwift

class ViewController: UIViewController {
	
	lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10
		layout.itemSize = CGSize(width: 100, height: 100)
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.register(HTHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HTHeader.identifier)
		collectionView.register(HTHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: HTHeader.identifier)
		return collectionView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initDataSource()
		initInterface()
	}
	
	func initDataSource () {
		collectionView.setSectionModelArray([ReuseSectionModel(["1", "2", "3", "4"]), ReuseSectionModel(["1", "2", "3", "4"]), ReuseSectionModel(["1", "2", "3", "4"])], proxy: self)
		collectionView.reloadData()
	}
	
	func initInterface() {
		view.addSubview(collectionView)
	}

}

extension ViewController: CollectionViewThrough, UICollectionViewDelegateFlowLayout {
	
	func cellClass<T>(_ reuseView: T, for indexPath: IndexPath) -> ReuseCell.Type where T : ReuseAbleView {
		return HTItem.self
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return reuseViewNumberOfSections(in: collectionView)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return reuseView(collectionView, numberOfRowsInSection: section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return reuseView(collectionView, cellForRowAt: indexPath) as! UICollectionViewCell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: 300, height: 100)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		return CGSize(width: 300, height: 50)
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let identifier = HTHeader.identifier
		let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
		let sectionModel = collectionView.sectionModelArray()[indexPath.section]
		(cell as! ReuseCell).setModel(sectionModel, for: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let detailController = DetailController()
		navigationController?.pushViewController(detailController, animated: true)
		collectionView.deselectItem(at: indexPath, animated: true)
	}
	
}

