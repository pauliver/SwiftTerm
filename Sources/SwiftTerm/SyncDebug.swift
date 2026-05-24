import Foundation

enum SyncDebug {
    static func log(_ message: @autoclosure () -> String) {
        #if DEBUG && SWIFTTERM_SYNC_DEBUG
        print("[SyncDebug] \(message())")
        #endif
    }
}
