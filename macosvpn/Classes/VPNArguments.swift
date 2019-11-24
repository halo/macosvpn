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

  public var serviceConfigArguments: [ArraySlice<String>] {
    if type(of: self).cmd == .help { return [] }

    var result: [ArraySlice<String>] = []
    var startAt = 0
    
    for (index, argument) in arguments.enumerated() {
      let atEnd = index == arguments.count - 1
      
      if argument == "--l2tp" || argument == "--cisco" || atEnd {
        
        let from = startAt == 0 ? result.compactMap({ $0.count }).reduce(0, +) : startAt
        var till = atEnd ? arguments.count - 1 : index - 1
        if till < 0 { till = 0 }
        let slice = arguments[from...till]
        
        
        if startAt > 0 { result.append(slice) }
        startAt = index
      }
    }
    return result
  }

}
