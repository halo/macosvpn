protocol StringProtocol {
  var asString: String { get }
}

extension StringProtocol {
  var asString: String { return self as! String }
}

extension String: StringProtocol { }

extension Optional where Wrapped : StringProtocol {

  var safeValue: String {
    if case let .some(value) = self {
      return value.asString
    }
    return "(null)"
  }
}
