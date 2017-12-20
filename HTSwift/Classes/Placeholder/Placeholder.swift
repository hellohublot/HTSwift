

import Foundation

extension UIView: HTSwiftCompatible, AssociatedAble {}

public enum PlaceholderState: Int {
	case none
	case firstRefresh
	case nothingDisplay
	case errorNetwork = -1000
	case needAuth
}

public protocol PlaceholderProvider: class {
	
	func setPlaceholderView(_ placeholderView: (UIView & PlaceholderAble), forState state: PlaceholderState)
	
	func placeholderViewFromState(_ state: PlaceholderState) -> (UIView & PlaceholderAble)?
	
}

extension HTBox where Base: UIView {
	
	public var placeholderState: PlaceholderState {
		get {
			return valueFor(key: #function) as? PlaceholderState ?? .none
		}
		set {
			setValue(value: newValue, forKey: #function)
			reloadPlaceholderState(newValue)
		}
	}
	
	public func reloadPlaceholderState(_ state: PlaceholderState) {
		while placeholderContentView.subviews.count > 0 {
			let view = placeholderContentView.subviews.last as? (UIView & PlaceholderAble)
			view?.removeFromSuperview()
			view?.placeholderHidden()
		}
		let placeholderView = placeholderProvider?.placeholderViewFromState(state)
		if state != .none, let _ = placeholderView {
			base.bringSubview(toFront: placeholderContentView)
			placeholderContentView.addSubview(placeholderView!)
			placeholderContentView.isHidden = false
			placeholderView?.moveToContentView()
			placeholderView?.placeholderShow()
		} else {
			placeholderContentView.isHidden = true
		}
	}
	
	public var placeholderProvider: PlaceholderProvider? {
		get {
			return valueFor(key: #function) as? PlaceholderProvider
		}
		set {
			setValue(value: newValue, forKey: #function)
		}
	}
	
}

extension HTBox where Base: UIView {
	var placeholderContentView: UIView {
		get {
			let contentView = valueFor(key: #function) as? UIView ?? {
				let temp = UIView()
				temp.translatesAutoresizingMaskIntoConstraints = false
				temp.isHidden = true
				base.addSubview(temp)
				var leftEdge: CGFloat = 0
				var topEdge: CGFloat = 0
				if base is UIScrollView {
					let scrollView = base as! UIScrollView
					let contentInset = scrollView.contentInset
					leftEdge = contentInset.left - contentInset.right
					topEdge = contentInset.top - contentInset.bottom
				}
				NSLayoutConstraint.activate([
					NSLayoutConstraint(item: temp, attribute: .centerX, relatedBy: .equal, toItem: base, attribute: .centerX, multiplier: 1, constant: leftEdge),
					NSLayoutConstraint(item: temp, attribute: .centerY, relatedBy: .equal, toItem: base, attribute: .centerY, multiplier: 1, constant: topEdge),
					NSLayoutConstraint(item: temp, attribute: .height, relatedBy: .equal, toItem: base, attribute: .height, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: temp, attribute: .width, relatedBy: .equal, toItem: base, attribute: .width, multiplier: 1, constant: 0)
				])
				setValue(value: temp, forKey: #function)
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

