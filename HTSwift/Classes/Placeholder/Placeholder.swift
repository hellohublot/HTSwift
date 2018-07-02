

import Foundation

public enum PlaceholderState: Int {
	case none
	case firstRefresh
	case nothingDisplay
	case errorNetwork = -1000
	case needAuth
	case reserved
}

public protocol PlaceholderProvider: class {
	
	weak var superView: UIView? {
		get set
	}
		
	func setPlaceholderView(_ placeholderView: (UIView & PlaceholderAble), forState state: PlaceholderState)
	
	func placeholderViewFromState(_ state: PlaceholderState) -> (UIView & PlaceholderAble)?
	
}

extension UIView {
	
	public var placeholderState: PlaceholderState {
		get {
			return associatedValueFor(key: #function) as? PlaceholderState ?? .none
		}
		set {
			setAssociatedValue(value: newValue, forKey: #function)
			reloadPlaceholderState(newValue)
		}
	}
	
	public func reloadPlaceholderState(_ state: PlaceholderState) {
		switch state {
		case .nothingDisplay, .errorNetwork, .needAuth:
			if let tableView = self as? UITableView {
				tableView.setSectionModelArray([], proxy: nil)
				tableView.reloadData()
			} else if let collectionView = self as? UICollectionView {
				collectionView.setSectionModelArray([], proxy: nil)
				collectionView.reloadData()
			}
			break
		default:
			break
		}
		placeholderProvider?.superView = self
		while placeholderContentView.subviews.count > 0 {
			let view = placeholderContentView.subviews.last as? (UIView & PlaceholderAble)
			view?.removeFromSuperview()
			view?.placeholderHidden()
		}
		let placeholderView = placeholderProvider?.placeholderViewFromState(state)
		if state != .none, let placeholderView = placeholderView {
			bringSubview(toFront: placeholderContentView)
			placeholderContentView.addSubview(placeholderView)
			placeholderContentView.isHidden = false
			placeholderView.moveToContentView()
			placeholderView.placeholderShow()
		} else {
			placeholderContentView.isHidden = true
		}
	}
	
	public var placeholderProvider: PlaceholderProvider? {
		get {
			return associatedValueFor(key: #function) as? PlaceholderProvider
		}
		set {
			if let scrollView = self as? UIScrollView {
				scrollView.keyboardDismissMode = .onDrag
				if let tableView = scrollView as? UITableView {
					if tableView.tableFooterView == nil {
						tableView.tableFooterView = UIView()
					}
					tableView.estimatedRowHeight = 0
					tableView.estimatedSectionHeaderHeight = 0
					tableView.estimatedSectionFooterHeight = 0
				}
			}
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
}

extension UIView {
	
	var placeholderContentView: UIView {
		get {
			let contentView = associatedValueFor(key: #function) as? UIView ?? {
				let temp = UIView()
				temp.translatesAutoresizingMaskIntoConstraints = false
				temp.isHidden = true
				addSubview(temp)
				var leftEdge: CGFloat = 0
				var topEdge: CGFloat = 0
				if let scrollView = self as? UIScrollView {
					let contentInset = scrollView.contentInset
					leftEdge = contentInset.left - contentInset.right
					topEdge = contentInset.top - contentInset.bottom
				}
				NSLayoutConstraint.activate([
					NSLayoutConstraint(item: temp, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: leftEdge),
					NSLayoutConstraint(item: temp, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: topEdge),
					NSLayoutConstraint(item: temp, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: temp, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
				])
				setAssociatedValue(value: temp, forKey: #function)
				return temp
			}()
			return contentView
		}
	}
}


public protocol PlaceholderAble {
	func moveToContentView()
	func placeholderShow()
	func placeholderHidden()
}

extension PlaceholderAble where Self: UIView {
	
	public func moveToContentView() {
		self.translatesAutoresizingMaskIntoConstraints = false
		let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self.superview, attribute: .width, multiplier: 1, constant: 0)
		let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self.superview, attribute: .height, multiplier: 1, constant: 0)
		width.priority = UILayoutPriority(Float(100))
		height.priority = UILayoutPriority(Float(100))
		NSLayoutConstraint.activate([
			NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.superview, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.superview, attribute: .centerY, multiplier: 1, constant: 0),
			width,
			height
		])
	}
	public func placeholderShow() {
		self.isHidden = false
	}
	public func placeholderHidden() {
		self.isHidden = true
	}
}

