
public struct Color {}

public protocol ColorType: Parameter {
	var level: Level { get }
}

/// Foreground/Background
public enum Level {
	case Foreground
	case Background
	
	public mutating func toggle() {
		if self == .Foreground {
			self = .Background
		} else {
			self = .Foreground
		}
	}
	
}
