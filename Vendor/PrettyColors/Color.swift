
public struct Color {}

public protocol ColorType: Parameter {
	var level: Level { get }
}

/// Foreground/Background
public enum Level {
	case foreground
	case background
	
	public mutating func toggle() {
		if self == .foreground {
			self = .background
		} else {
			self = .foreground
		}
	}
	
}
