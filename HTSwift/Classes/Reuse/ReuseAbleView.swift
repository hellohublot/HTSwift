

import Foundation





public protocol ReuseSectionArray {
	var modelArray: [Any] {
		get
	}
}

public protocol ReuseCell {
	func setModel(_ model: Any?, for indexPath: IndexPath)
	static func modelSize(_ model: NSObject?, _ superSize: CGSize) -> CGSize
}

public extension ReuseCell {
	static var identifier: String {
		return "\(self)"
	}
	static var any: AnyClass? {
		return self as? AnyClass
	}
}

public extension ReuseCell {
	
	private static func cacheKey() -> String {
		return identifier
	}
	
	private static func cacheSize(_ model: NSObject?) -> CGSize? {
		return model?.associatedValueFor(key: cacheKey()) as? CGSize
	}
	private static func setCacheSize(_ model: NSObject?, _ size: CGSize) {
		model?.setAssociatedValue(value: NSValue.init(cgSize: size), forKey: cacheKey())
	}
	public static func cacheModelSize(_ model: NSObject?, _ superSize: CGSize) -> CGSize {
		if let size = cacheSize(model) {
			return size
		}
		let size = modelSize(model, superSize)
		setCacheSize(model, size)
		return size
	}
	public static func modelSize(_ model: NSObject?, _ superSize: CGSize) -> CGSize {
		return CGSize.zero
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
	func setProxy(_ proxy: ThroughType?)
}

private var reuseThroughSectionKey: Int = 0

public extension ReuseAbleView {
	
	public func cellModelArray() -> [Any] {
		return sectionModelArray().last?.modelArray ?? []
	}
	
	public func sectionModelArray() -> [ReuseSectionArray] {
		return objc_getAssociatedObject(self, &reuseThroughSectionKey) as? [ReuseSectionArray] ?? []
	}
	
	public func setCellModelArray(_ modelArray: [Any], proxy: ThroughType?) {
		setSectionModelArray([ReuseSectionModel(modelArray)], proxy: proxy)
	}
	
	public func setSectionModelArray(_ modelArray: [ReuseSectionArray], proxy: ThroughType?) {
		let reuse = proxy as? ReuseThrough
		objc_setAssociatedObject(self, &reuseThroughSectionKey, modelArray, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		let sectionCount = reuse?.reuseViewNumberOfSections(in: self) ?? 0
		for section in 0..<sectionCount {
			let rowCount = reuse?.reuseView(self, numberOfRowsInSection: section) ?? 0
			for row in 0..<rowCount {
				if let cellClsss = reuse?.cellClass(self, for: IndexPath(row: row, section: section)) {
					reuse?.registerCell(self, cellClass: cellClsss, forIdentifier: cellClsss.identifier)
				}
			}
		}
		setProxy(proxy)
	}
	
}

extension UITableView: ReuseAbleView {
	public typealias ThroughType = TableViewThrough
	public func setProxy(_ proxy: ThroughType?) {
		self.delegate = proxy
		self.dataSource = proxy
	}
}

extension UICollectionView: ReuseAbleView {
	public typealias ThroughType = CollectionViewThrough
	public func setProxy(_ proxy: ThroughType?) {
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

public extension ReuseThrough {
	
	public func reuseViewNumberOfSections<T: ReuseAbleView>(in reuseView: T) -> Int {
		return reuseView.sectionModelArray().count
	}
	
	public func reuseView<T: ReuseAbleView>(_ reuseView: T, numberOfRowsInSection section: Int) -> Int {
		let sectionModel = reuseView.sectionModelArray()[section]
		return sectionModel.modelArray.count
	}
	
	public func reuseView<T: ReuseAbleView>(_ reuseView: T, cellForRowAt indexPath: IndexPath) -> ReuseCell {
		let identifier = cellClass(reuseView, for: indexPath).identifier
		let cell = dequeueReusableCell(reuseView, withIdentifier: identifier, for: indexPath)
		let sectionModel = reuseView.sectionModelArray()[indexPath.section]
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
