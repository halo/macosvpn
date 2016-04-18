/// Based on: ECMA-048 — 8.3.117
public enum StyleParameter: UInt8, Parameter {
	// Reference: Terminal Support Table: https://github.com/jdhealy/PrettyColors/wiki/Terminal-Support
	case Bold              = 01 // bold or increased intensity
	case Faint             = 02 // faint, decreased intensity or second colour
	case Italic            = 03 // italicized
	case Underlined        = 04 // singly underlined
	case BlinkSlow         = 05 // slowly blinking (less then 150 per minute)
	case Blink             = 06 // rapidly blinking (150 per minute or more)
	case Negative          = 07 // negative image — a.k.a. Inverse
	case Concealed         = 08 // concealed characters
	case CrossedOut        = 09 // (characters still legible but marked as to be deleted)
	case Font1             = 11
	case Font2             = 12
	case Font3             = 13
	case Font4             = 14
	case Font5             = 15
	case Font6             = 16
	case Font7             = 17
	case Font8             = 18
	case Font9             = 19
	case Fraktur           = 20 // Gothic
	case UnderlinedDouble  = 21 // doubly underlined
	case Normal            = 22 // normal colour or normal intensity (neither bold nor faint)
	case Positive          = 27 // positive image
	case Revealed          = 28 // revealed characters
	case Framed            = 51
	case Encircled         = 52
	case Overlined         = 53

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
