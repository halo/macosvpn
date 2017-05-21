extension Color {
	public struct EightBit: Parameter, ColorType {
		public var color: UInt8
		public var level: Level
		
		public var code: (enable: [UInt8], disable: UInt8?) {
			return (
				enable: [
					(self.level == .foreground ? 38 : 48),
					5,
					self.color
				],
				disable: nil
			)
		}

		public init(
			foreground color: UInt8
		) {
			self.color = color
			self.level = Level.foreground
		}

		public init(
			background color: UInt8
		) {
			self.color = color
			self.level = Level.background
		}

	}
}
