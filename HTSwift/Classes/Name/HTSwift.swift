

import Foundation

public final class HTBox<Base> {
	public let base: Base
	public init(_ base: Base) {
		self.base = base
	}
}

public protocol HTSwiftCompatible {
	associatedtype CompatibleType
	var h: CompatibleType { get }
}

public extension HTSwiftCompatible {
	public var h: HTBox<Self> {
		get { return HTBox(self) }
	}
}
