/// Based on: ECMA-048 — 8.3.117
public enum StyleParameter: UInt8, Parameter {
	// Reference: Terminal Support Table: https://github.com/jdhealy/PrettyColors/wiki/Terminal-Support
	case bold              = 01 // bold or increased intensity
	case faint             = 02 // faint, decreased intensity or second colour
	case italic            = 03 // italicized
	case underlined        = 04 // singly underlined
	case blinkSlow         = 05 // slowly blinking (less then 150 per minute)
	case blink             = 06 // rapidly blinking (150 per minute or more)
	case negative          = 07 // negative image — a.k.a. Inverse
	case concealed         = 08 // concealed characters
	case crossedOut        = 09 // (characters still legible but marked as to be deleted)
	case font1             = 11
	case font2             = 12
	case font3             = 13
	case font4             = 14
	case font5             = 15
	case font6             = 16
	case font7             = 17
	case font8             = 18
	case font9             = 19
	case fraktur           = 20 // Gothic
	case underlinedDouble  = 21 // doubly underlined
	case normal            = 22 // normal colour or normal intensity (neither bold nor faint)
	case positive          = 27 // positive image
	case revealed          = 28 // revealed characters
	case framed            = 51
	case encircled         = 52
	case overlined         = 53

	public struct Reset {
		/// Some parameters have corresponding resets, 
		/// but all parameters are reset by `defaultRendition`
		public static let dictionary: [UInt8: UInt8] = [
			03: 23, 04: 24, 05: 25, 06: 25, 11: 10,
			12: 10, 13: 10, 14: 10, 15: 10, 16: 10,
			17: 10, 18: 10, 19: 10, 20: 23, 51: 54,
			52: 54, 53: 55
		]
		
		/// “cancels the effect of any preceding occurrence of SGR in the data stream”
		public static let defaultRendition: UInt8 = 0
	}
	
	public var code: (enable: [UInt8], disable: UInt8?) {
		return ( [self.rawValue], Reset.dictionary[self.rawValue] )
	}
}
