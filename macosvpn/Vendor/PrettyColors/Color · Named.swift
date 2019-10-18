extension Color {
	public struct Named: Parameter, ColorType {
		public enum Color: UInt8 {
			case black = 30
			case red
			case green
			case yellow
			case blue
			case magenta
			case cyan
			case white
		}
		
		public enum Brightness {
			case bright
			case nonBright
			
			public var additive: UInt8 { return self == .bright ? 60 : 0 }
			
			public mutating func toggle() {
				switch self {
				case .bright: self = .nonBright
				case .nonBright: self = .bright
				}
			}
			
		}
		
		public var color: Color
		public var brightness = Brightness.nonBright
		public var level = Level.foreground
		
		public var code: (enable: [UInt8], disable: UInt8?) {
			return (
				enable: [
					self.color.rawValue +
						self.brightness.additive +
						(self.level == .foreground ? 0 : 10)
				],
				disable: nil
			)
		}
		
		public init(
			foreground color: Color,
			brightness: Brightness = .nonBright
		) {
			self.color = color
			self.brightness = brightness
			self.level = Level.foreground
		}
		
		public init(
			background color: Color,
			brightness: Brightness = .nonBright
		) {
			self.color = color
			self.brightness = brightness
			self.level = Level.background
		}
		
	}
}
