/*
 * Copyright (C) 2014-2019 halo https://github.com/halo/macosvpn
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

public enum Colorize {
  // See https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg

  public static func boldUnderlined(_ text: String) -> String {
    return Color.Wrap(styles: .bold, .underlined).wrap(text)
  }

  public static func green(_ text: String) -> String {
    return Color.Wrap(foreground: .green).wrap(text)
  }

  public static func red(_ text: String) -> String {
    return Color.Wrap(foreground: .red).wrap(text)
  }

  public static func blue(_ text: String) -> String {
    return Color.Wrap(foreground: .blue).wrap(text)
  }

  public static func pink(_ text: String) -> String {
    return Color.Wrap(foreground: 199).wrap(text)
  }

  public static func brown(_ text: String) -> String {
    return Color.Wrap(foreground: 130).wrap(text)
  }
}
