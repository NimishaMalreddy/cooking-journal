import SwiftUI
import CoreText

extension UIFont {
    static func registerFonts() {
        ["Poppins-Medium", "InstrumentSans-Regular", "InstrumentSans-Bold"].forEach { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
