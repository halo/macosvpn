import PrettyColors

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
