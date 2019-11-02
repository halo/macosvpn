#if !swift(>=4.0)
extension String {
	func dropFirst(_ n: Int = 1) -> String.CharacterView {
		return self.characters.dropFirst(n)
	}

	var first: Character? {
		return self.characters.first
	}

	var count: Int {
		return self.characters.count
	}
	
	func split(separator: Character, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [String.CharacterView] {
		return self.characters.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) 
	}
}

extension Sequence {
	func compactMap<ElementOfResult>(_ transform: (Iterator.Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
		return try flatMap(transform)
	}
}
#endif

