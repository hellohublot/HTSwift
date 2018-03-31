

import UIKit

public typealias ControlHandler = () -> Void

public protocol RefreshControl: class {
	
	var block: ControlHandler? {
		get set
	}
	var refresh: Bool? {
		get
	}
	
	func endRefresh()
	
}

public protocol RefreshFooterControl: RefreshControl {
	func endRefreshWithNoMoreData()
}

public protocol RefreshProvider: class {
	
	var headerControl: RefreshControl? {
		get
	}
	var footerControl: RefreshFooterControl? {
		get
	}
	
}

extension UIScrollView {
	
	public typealias RefreshingHandler = (_ pageIndex: Int, _ pageCount: Int) -> Void
	
	public var refreshProvider: RefreshProvider? {
		get {
			return associatedValueFor(key: #function) as? RefreshProvider
		}
		set {
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
	public var pageIndex: NSInteger {
		get {
			return associatedValueFor(key: #function) as? NSInteger ?? 0
		}
		set {
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
	public var pageCount: NSInteger {
		get {
			return associatedValueFor(key: #function) as? NSInteger ?? 10
		}
		set {
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
	public func setRefreshingBlock(_ provider: RefreshProvider?, _ refreshingBlock: @escaping RefreshingHandler) {
		refreshProvider = provider
		let headerRefreshing: ControlHandler = {[weak self] in
			self?.pageIndex = 0
			refreshingBlock(self?.pageIndex ?? 0 + 1, self?.pageCount ?? 10)
		}
		refreshProvider?.headerControl?.block = headerRefreshing
		let footerRefreshing: ControlHandler = {[weak self] in
			self?.pageIndex = max(1, self?.pageIndex ?? 0)
			refreshingBlock(self?.pageIndex ?? 0 + 1, self?.pageCount ?? 10)
		}
		refreshProvider?.footerControl?.block = footerRefreshing
	}
	
	public func respondHeaderRefresh() {
		if let headerRefreshing = refreshProvider?.headerControl?.block {
			placeholderState = .firstRefresh
			headerRefreshing()
		}
	}
	
	public func endRefreshWith(modelCount: NSInteger) {
		endRefreshWith(modelCount: modelCount, onlyOnePage: false)
	}
	
	public func endRefreshWith(modelCount: NSInteger, onlyOnePage: Bool) {
		let isHeaderRefreshing = (refreshProvider?.headerControl?.refresh ?? true) || placeholderState == .firstRefresh
		let isFooterRefreshing = (refreshProvider?.footerControl?.refresh ?? false)
		var willNoMoreData = false
		var willState = placeholderState
		if modelCount < 0 {
			if isHeaderRefreshing {
				willState = PlaceholderState(rawValue: modelCount) ?? .errorNetwork
				willNoMoreData = true
			}
		} else if (modelCount == 0) {
			if isHeaderRefreshing {
				willState = .nothingDisplay
				willNoMoreData = true
			} else if isFooterRefreshing {
				willNoMoreData = true
			}
		} else {
			if isHeaderRefreshing {
				pageIndex = 1
			} else if isFooterRefreshing {
				pageIndex += 1
			}
			willState = .none
			if modelCount != pageCount || onlyOnePage {
				willNoMoreData = true
			}
		}
		refreshProvider?.headerControl?.endRefresh()
		resetFooterWith(noMoreData: willNoMoreData)
		placeholderState = willState
	}
	
	func resetFooterWith(noMoreData: Bool) {
		if noMoreData {
			refreshProvider?.footerControl?.endRefreshWithNoMoreData()
		} else {
			refreshProvider?.footerControl?.endRefresh()
		}
	}
	
}
