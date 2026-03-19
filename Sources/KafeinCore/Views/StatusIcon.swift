import SwiftUI

public struct StatusIcon {
    public static func name(isActive: Bool) -> String {
        isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
    }
}
