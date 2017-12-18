

import Foundation





public protocol ReuseSectionArray {
	var modelArray: [Any] {
		get
	}
}

public protocol ReuseCell {
	func setModel(_ model: Any?, for IndexPath: IndexPath)
}

public extension ReuseCell {
	static var identifier: String {
		return "\(self)"
	}
	static var any: AnyClass? {
		return self as? AnyClass
	}
}

public struct ReuseSectionModel: ReuseSectionArray {
	public init(_ cellModelArray: [Any]) {
		modelArray = cellModelArray
	}
	public var modelArray: [Any]
}











public protocol ReuseAbleView {
	associatedtype ThroughType
	func setProxy(proxy: ThroughType?)
}

private var reuseAbleViewProxyKey: Int = 0
public extension ReuseAbleView {
	var proxy: ThroughType? {
		get {
			return objc_getAssociatedObject(self, &reuseAbleViewProxyKey) as? ThroughType
		}
		set {
			objc_setAssociatedObject(self, &reuseAbleViewProxyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			setProxy(proxy: newValue)
			let proxy = newValue as? ReuseThrough
			let sectionCount = proxy?.reuseViewNumberOfSections(in: self) ?? 0
			for section in 0...sectionCount {
				let cellClsss = proxy?.cellClass(self, for: IndexPath(row: 0, section: section))
				proxy?.registerCell(self, cellClass: cellClsss!, forIdentifier: cellClsss!.identifier)
			}
		}
	}
}

extension UITableView: ReuseAbleView {
	public typealias ThroughType = TableViewThrough
	public func setProxy(proxy: ThroughType?) {
		self.delegate = proxy
		self.dataSource = proxy
	}
}

extension UICollectionView: ReuseAbleView {
	public typealias ThroughType = CollectionViewThrough
	public func setProxy(proxy: ThroughType?) {
		self.delegate = proxy
		self.dataSource = proxy
	}
}








public protocol ReuseThrough: class {
	
	func cellClass<T: ReuseAbleView>(_ reuseView: T, for indexPath: IndexPath) -> ReuseCell.Type
	
	func registerCell<T: ReuseAbleView>(_ reuseView: T, cellClass: ReuseCell.Type, forIdentifier identifier: String)
	
	func dequeueReusableCell<T: ReuseAbleView>(_ reuseView: T, withIdentifier identifier: String, for indexPath: IndexPath) -> ReuseCell
	
	func reuseViewNumberOfSections<T: ReuseAbleView>(in reuseView: T) -> Int
	func reuseView<T: ReuseAbleView>(_ reuseView: T, numberOfRowsInSection section: Int) -> Int
	func reuseView<T: ReuseAbleView>(_ reuseView: T, cellForRowAt indexPath: IndexPath) -> ReuseCell
}

private var reuseThroughCellKey: Int = 0
private var reuseThroughSectionKey: Int = 0

public extension ReuseThrough {
	
	public var cellModelArray: [Any] {
		get {
			return objc_getAssociatedObject(self, &reuseThroughCellKey) as? [Any] ?? []
		}
		set {
			objc_setAssociatedObject(self, &reuseThroughCellKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			sectionModelArray = [ReuseSectionModel(newValue)]
		}
	}
	public var sectionModelArray: [ReuseSectionArray] {
		get {
			return objc_getAssociatedObject(self, &reuseThroughSectionKey) as? [ReuseSectionArray] ?? []
		}
		set {
			objc_setAssociatedObject(self, &reuseThroughSectionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	public func reuseViewNumberOfSections<T: ReuseAbleView>(in reuseView: T) -> Int {
		return sectionModelArray.count
	}
	
	public func reuseView<T: ReuseAbleView>(_ reuseView: T, numberOfRowsInSection section: Int) -> Int {
		let sectionModel = sectionModelArray[section]
		return sectionModel.modelArray.count
	}
	
	public func reuseView<T: ReuseAbleView>(_ reuseView: T, cellForRowAt indexPath: IndexPath) -> ReuseCell {
		let identifier = cellClass(reuseView, for: indexPath).identifier
		let cell = dequeueReusableCell(reuseView, withIdentifier: identifier, for: indexPath)
		let sectionModel = sectionModelArray[indexPath.section]
		let model = sectionModel.modelArray[indexPath.row]
		cell.setModel(model, for: indexPath)
		return cell
	}
	
}

public protocol TableViewThrough: ReuseThrough, UITableViewDelegate, UITableViewDataSource {
	
}

public protocol CollectionViewThrough: ReuseThrough, UICollectionViewDelegate, UICollectionViewDataSource {
	
}

public extension TableViewThrough {
	
	func tableView<T: ReuseAbleView>(_ reuseView: T) -> UITableView {
		return reuseView as! UITableView
	}
	
	func registerCell<T: ReuseAbleView>(_ reuseView: T, cellClass: ReuseCell.Type, forIdentifier identifier: String) {
		tableView(reuseView).register(cellClass.any, forCellReuseIdentifier: identifier)
	}
	
	func dequeueReusableCell<T: ReuseAbleView>(_ reuseView: T, withIdentifier identifier: String, for indexPath: IndexPath) -> ReuseCell {
		return tableView(reuseView).dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ReuseCell
	}
	
}

public extension CollectionViewThrough {
	
	func collectionView<T: ReuseAbleView>(_ reuseView: T) -> UICollectionView {
		return reuseView as! UICollectionView
	}
	
	func registerCell<T: ReuseAbleView>(_ reuseView: T, cellClass: ReuseCell.Type, forIdentifier identifier: String) {
		collectionView(reuseView).register(cellClass.any, forCellWithReuseIdentifier: identifier)
	}
	
	func dequeueReusableCell<T: ReuseAbleView>(_ reuseView: T, withIdentifier identifier: String, for indexPath: IndexPath) -> ReuseCell {
		return collectionView(reuseView).dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ReuseCell
	}
	
}

