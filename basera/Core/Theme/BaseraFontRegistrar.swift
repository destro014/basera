import CoreText
import Foundation
import UIKit

enum BaseraFontRegistrar {
    private static var didRegister = false

    private static let bundledFonts = [
        "Rubik-Regular.ttf",
        "Rubik-Medium.ttf",
        "Rubik-SemiBold.ttf"
    ]

    static func registerIfNeeded() {
        guard didRegister == false else { return }
        didRegister = true

        bundledFonts.forEach { register(fontFileName: $0) }

        #if DEBUG
        let rubikFontNames = UIFont.familyNames
            .flatMap { UIFont.fontNames(forFamilyName: $0) }
            .filter { $0.localizedCaseInsensitiveContains("Rubik") }
            .sorted()
        print("BaseraFontRegistrar: registered Rubik faces -> \(rubikFontNames)")
        #endif
    }

    private static func register(fontFileName: String) {
        guard let (name, ext) = split(fileName: fontFileName)
        else {
            #if DEBUG
            print("BaseraFontRegistrar: missing font file \(fontFileName)")
            #endif
            return
        }

        let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Fonts")
            ?? Bundle.main.url(forResource: name, withExtension: ext)

        guard let url else {
            #if DEBUG
            print("BaseraFontRegistrar: missing font in bundle \(fontFileName)")
            #endif
            return
        }

        var error: Unmanaged<CFError>?
        let isRegistered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)

        if isRegistered == false {
            #if DEBUG
            let cfError: CFError? = error?.takeRetainedValue()
            let message = (cfError.map { CFErrorCopyDescription($0) as String } ?? "").lowercased()

            // Ignore duplicate registration noise on app relaunch.
            if message.contains("already") == false {
                print("BaseraFontRegistrar: failed to register \(fontFileName) - \(String(describing: cfError))")
            }
            #endif
        }
    }

    private static func split(fileName: String) -> (String, String)? {
        let url = URL(fileURLWithPath: fileName)
        let name = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        guard name.isEmpty == false, ext.isEmpty == false else { return nil }
        return (name, ext)
    }
}
