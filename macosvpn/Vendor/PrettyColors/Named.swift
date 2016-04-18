extension Color {
	public struct Named: Parameter, ColorType {
		public enum Color: UInt8 {
			case Black = 30
			case Red
			case Green
			case Yellow
			case Blue
			case Magenta
			case Cyan
			case White
		}
		
		public enum Brightness {
			case Bright
			case NonBright
			
			public var additive: UInt8 { return self == .Bright ? 60 : 0 }
			
			public mutating func toggle() {
				switch self {
				case .Bright: self = .NonBright
				case .NonBright: self = .Bright
				}
			}
			
		}
		
		public var color: Color
		public var brightness = Brightness.NonBright
		public var level = Level.Foreground
		
		public var code: (enable: [UInt8], disable: UInt8?) {
			return (
				enable: [
					self.color.rawValue +
						self.brightness.additive +
						(self.level == .Foreground ? 0 : 10)
				],
				disable: nil
			)
		}
		
		public init(
			foreground color: Color,
			brightness: Brightness = .NonBright
		) {
			self.color = color
			self.brightness = brightness
			self.level = Level.Foreground
		}
		
		public init(
			background color: Color,
			brightness: Brightness = .NonBright
		) {
			self.color = color
			self.brightness = brightness
			self.level = Level.Background
		}
		
	}
}
