import AppKit
import SwiftUI

enum AppFonts {
    static func body(size: CGFloat) -> Font {
        Font(makeFont(size: size))
    }

    static func makeFont(size: CGFloat) -> NSFont {
        let descriptor = NSFontDescriptor(fontAttributes: [
            .name: "Songti SC",
            .cascadeList: [
                NSFontDescriptor(fontAttributes: [.name: "Palatino"])
            ]
        ])

        return NSFont(descriptor: descriptor, size: size)
            ?? NSFont(name: "Songti SC", size: size)
            ?? NSFont(name: "Palatino", size: size)
            ?? .systemFont(ofSize: size)
    }
}
