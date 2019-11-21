/*
Copyright (c) 2014-2016 halo. https://github.com/halo/macosvpn

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import Moderator

open class VPNArguments: NSObject {
  
  //public override init(arguments: [String] = []) {
  //  <#code#>
  //}
  
  //public init (arguments: [String] = []) {
  //  self.arguments = arguments
  //  super.init()
  //  self.parse()
  //}
 
  //public static func helpRequested() -> Bool { return self.instance.helpRequested.value }
  public static var helpRequested: Bool {
    self.instance.parse()
    return self.instance.helpRequested.value
  }

  public static var l2tps: [String] {
    self.instance.parse()
    return self.instance.l2tps.value
  }

  public static var ciscos: [String] {
    self.instance.parse()
    return self.instance.ciscos.value
  }

  public static var usernames: [String] {
    self.instance.parse()
    return self.instance.usernames.value
  }

  private var parsed: Bool = false

  public static func forceRequested() -> Bool { return false }
  public static func versionRequested() -> Bool { return false }
  public static func command() -> UInt8 { return 0 }
  public static func serviceConfigs() -> Array<VPNServiceConfig>? { return [] }
  public static func serviceNames() -> Array<String>? { return [] }

  struct Options {
    enum Command: String {
      case create
      case delete
      case help
    }
    var command: Command = .help
  }

  public static var instance = VPNArguments()
 // public static var arguments =

  public var helpRequested: FutureValue<Bool> = FutureValue<Bool>()
  public var l2tps: FutureValue<[String]> = FutureValue<[String]>()
  public var ciscos: FutureValue<[String]> = FutureValue<[String]>()
  public var usernames: FutureValue<[String]> = FutureValue<[String]>()
  
  public var arguments: [String] {
    get {
      return _arguments
    }
    set {
      parsed = false
      _arguments = newValue
    }
  }
  private var _arguments = Array(CommandLine.arguments.dropFirst())

  
  
  public var serviceConfigArguments: [ArraySlice<String>] {
    var result: [ArraySlice<String>] = []
    var startAt = 0
    
    for (index, argument) in arguments.enumerated() {
      let atEnd = index == arguments.count - 1
      
      if argument == "--l2tp" || argument == "--cisco" || atEnd {
        
        let from = startAt == 0 ? result.compactMap({$0.count}).reduce(0, +) : startAt
        var till = atEnd ? arguments.count - 1 : index - 1
        if till < 0 { till = 0 }
        let slice = arguments[from...till]
        
        
        if startAt > 0 { result.append(slice) }
        startAt = index
      }
    }
    return result
  }

  public func parse() {
    if (parsed) { return };
    
    let m = Moderator()
    
    helpRequested = m.add(.option("h", "help"))
    
   // for slice in serviceConfigArguments {
            
      //l2tps = m.add(Argument<String>.optionWithValue("l2tp").repeat())
      //ciscos = m.add(Argument<String>.optionWithValue("cisco").repeat())
      //usernames = m.add(Argument<String>.optionWithValue("username").repeat())
      
      //let single = m.add(Argument<String?>.singleArgument(name: "argumentname"))
      
      
      //let options = m.add(Argument<String?>.optionWithValue("b").repeat())
      //let multiple = m.add(Argument<String?>.singleArgument(name: "multiple").repeat())
      
      do {
        try m.parse(self.arguments)
        parsed = true
      } catch {
        print(error)
        exit(Int32(error._code))
      }
    }
    //Log.debug(options.description)
    //return options.description
  //}
  
  
  //private lazy var helpFlag: OptionArgument<Bool> = {
  //   newParser.add(option: "--help", kind: Bool.self, usage: "Show Help")
  // }()

  //private lazy var binder: ArgumentBinder<Options> = {
  //  //Array(ProcessInfo.processInfo.arguments.dropFirst())
  //  ArgumentBinder<Options>()
  //}()
//
  //private lazy var parser: ArgumentParser = {
  //  let parser = ArgumentParser(usage: "", overview: "")
//
  //  _ = parser.add(subparser: "create", overview: "")
  //  _ = parser.add(subparser: "delete", overview: "")
//
  //  self.binder.bind(
  //    parser: parser,
  //    to: { $0.command = Options.Command(rawValue: $1)! }
  //  )
  //
  //  return parser
  //}()
//
  //private lazy var options: Options = {
  //  do {
  //    let result = try self.parser.parse(type(of: self).arguments)
  //    var options = Options()
  //    try self.binder.fill(parseResult: result, into: &options)
  //    return options
  //
  //  } catch ArgumentParserError.expectedValue(let value) {
  //      print("Missing value for argument \(value).")
//
  //  } catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
  //      print("Missing arguments: \(stringArray.joined()).")
//
  //  } catch {
  //      print(error.localizedDescription)
  //  }
  //  return Options()
  //}()
}
