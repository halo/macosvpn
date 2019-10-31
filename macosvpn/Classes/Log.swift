/*
 * Copyright (C) 2012-2018 halo https://io.github.com/halo/macosvpn
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Logging
//import Foundation

public struct Log {
  // See https://github.com/apple/swift-log
  private static let logger = Logger(label: "io.github.halo.macosvpn")

  public static func debug(_ message: String) {
    logger.debug("\(message)")
  }

  public static func info(_ message: String) {
    logger.info("\(message)")
  }
  
  public static func warn(_ message: String) {
    logger.warning("\(message)")
  }
  
  public static func error(_ message: String) {
    logger.error("\(message)")
  }
}
