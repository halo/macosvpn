//
//  Moderator.swift
//
//  Created by Kåre Morstøl.
//  Copyright (c) 2016 NotTooBad Software. All rights reserved.
//

// Should ideally and eventually be compatible with http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html ,
// with the addition of "--longname". For more, see http://blog.nottoobadsoftware.com/uncategorized/cross-platform-command-line-arguments-syntax/ .

public typealias UsageText = (title: String, description: String)?

public struct Argument <Value> {
	public let usage: UsageText
	public let parse: ([String]) throws -> (value: Value, remainder: [String])

	public init (usage: UsageText = nil, p: @escaping ([String]) throws -> (value: Value, remainder: [String])) {
		self.parse = p
		self.usage = usage
	}

	public init (usage: UsageText = nil, value: Value) {
		self.parse = { args in (value, args) }
		self.usage = usage
	}
}

extension Argument {
	public func map <Outvalue> (_ f: @escaping (Value) throws -> Outvalue) -> Argument<Outvalue> {
		return Argument<Outvalue>(usage: self.usage) { args in
			let result = try self.parse(args)
			return (value: try f(result.value), remainder: result.remainder)
		}
	}
}

public struct ArgumentError: Error, CustomStringConvertible {
	public let errormessage: String
	public internal(set) var usagetext: String? = nil

	public init (errormessage: String, usagetext: String? = nil) {
		self.errormessage = errormessage
		self.usagetext = usagetext
	}

	public var description: String { return errormessage + (usagetext.map { "\n" + $0 } ?? "") }
}

extension Argument {
	static func isOption (index: Array<String>.Index, args: [String]) -> Bool {
    if let i = args.firstIndex(of: "--"), i < index { return false }
		let argument = args[index]
		if argument.first == "-",
			let second = argument.dropFirst().first, !("0"..."9").contains(second) {
			return true
		}
		return false
	}

	static func option(names: [String], description: String? = nil) -> Argument<Bool> {
		for illegalcharacter in [" ","-","="] {
			precondition(!names.contains(where: {$0.contains(illegalcharacter)}), "Option names cannot contain '\(illegalcharacter)'")
		}
		for digit in 0...9 {
			precondition(!names.contains(where: {$0.hasPrefix(String(digit))}), "Option names cannot begin with a number.")
		}
		precondition(!names.contains("W"), "Option '-W' is reserved for system use.")

		let names = names.map { ($0.count==1 ? "-" : "--") + $0 }
		let usage = description.map { (names.joined(separator: ","), $0) }
		return Argument<Bool>(usage: usage) { args in
			var args = args
      guard let index = args.firstIndex(where: names.contains), isOption(index: index, args: args) else {
				return (false, args)
			}
			args.remove(at: index)
			return (true, args)
		}
	}

	public static func option(_ names: String..., description: String? = nil) -> Argument<Bool> {
		return option(names: names, description: description)
	}

	/// Parses arguments like '--opt=value' into '--opt value'.
	internal static func joinedOptionAndArgumentParser() -> Argument<Void> {
		return Argument<Void>() { args in
			return ((), args.enumerated().flatMap { (index, arg) in
				isOption(index: index, args: args) ?
					arg.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true).map(String.init) :
					[arg]
			})
		}
	}
}


extension Array where Element: Equatable {
	public func indexOfFirstDifference (_ other: Array<Element>) -> Index? {
		for i in self.indices {
			if i >= other.endIndex || self[i] != other[i] { return i }
		}
		return nil
	}
}

extension Argument {
	public static func optionWithValue
		(_ names: String..., name valuename: String? = nil, description: String? = nil)
		-> Argument<String?> {

			let option = Argument.option(names: names, description: description)
			let usage = option.usage.map { usage in
				return (usage.title + " <\(valuename ?? "arg")>", usage.description)
			}

			return Argument<String?>(usage: usage) { args in
				var optionresult = try option.parse(args)
				guard optionresult.value else {
					return (nil, args)
				}
				guard let firstchange = optionresult.remainder.indexOfFirstDifference(args) else {
					throw ArgumentError(errormessage: "Expected value for '\(args.last!)'.",
						usagetext: format(usagetext: usage))
				}
				guard !isOption(index: firstchange, args: optionresult.remainder) else {
					throw ArgumentError(
						errormessage: "Expected value for '\(args[firstchange])', got option '\(optionresult.remainder[firstchange])'.",
						usagetext: format(usagetext: usage))
				}
				let value = optionresult.remainder.remove(at: firstchange)
				return (value, optionresult.remainder)
			}
	}

	/// Parses the next argument, if it is not an option.
	///
	/// - Parameters:
	///   - name: The placeholder in the help text.
	///   - description: The description of this argument.
	/// - Returns: The next argument, or nil if there are no more arguments or the next argument is an option.
	public static func singleArgument (name: String, description: String? = nil) -> Argument<String?> {
		return Argument<String?>(usage: description.map { ("<"+name+">", $0) }) { args in
			let index = args.first == "--" ? args.index(after: args.startIndex) : args.startIndex
			guard index != args.endIndex, !isOption(index: index, args: args) else { return (nil, args) }
			var args = args
			return (args.remove(at: index), args)
		}
	}
}


public protocol OptionalType {
	associatedtype Wrapped
	func toOptional() -> Wrapped?
}

extension Optional: OptionalType {
	public func toOptional() -> Optional {
		return self
	}
}

extension Argument where Value: OptionalType {
	public func `default`(_ defaultvalue: Value.Wrapped) -> Argument<Value.Wrapped> {
		let newusage = self.usage.map { ($0.title, $0.description + " Default = '\(defaultvalue)'.") }
		return Argument<Value.Wrapped>(usage: newusage) { args in
			let result = try self.parse(args)
			return (result.value.toOptional() ?? defaultvalue, result.remainder)
		}
	}

	/// Makes this optional argument required. An error is thrown during argument parsing if it is missing.
	///
	/// - Parameter errormessage: The error message to display if the argument is missing.
	///   If no error message is provided one will be automatically generated.
	/// - Returns: A new argument parser with a non-optional value.
	public func required(errormessage: String? = nil) -> Argument<Value.Wrapped> {
		return Argument<Value.Wrapped>(usage: self.usage) { args in
			let result = try self.parse(args)
			guard let value = result.value.toOptional() else {
				let errormessage = errormessage ?? "Missing argument" + (self.usage == nil ? "." : ":")
				throw ArgumentError(errormessage: errormessage, usagetext: format(usagetext: self.usage))
			}
			return (value, result.remainder)
		}
	}

	/// Looks for multiple occurrences of an argument,
	/// by repeating an optional parser until it returns nil.
	///
	/// - Returns: An array of the values the parser returned.
	public func `repeat`() -> Argument<[Value.Wrapped]> {
		return Argument<[Value.Wrapped]>(usage: self.usage) { args in
			var args = args
			var values = Array<Value.Wrapped>()
			while true {
				let result = try self.parse(args)
				guard let value = result.value.toOptional() else {
					return (values, result.remainder)
				}
				values.append(value)
				args = result.remainder
 			}
		}
	}
}

extension Argument where Value == Bool {
	/// Counts the number of times an option argument occurs.
	public func count() -> Argument<Int> {
		return Argument<Int>(usage: self.usage) { args in
			let result = try self.map { $0 ? true : nil }.repeat().parse(args)
			return (result.value.count, result.remainder)
		}
	}
}
