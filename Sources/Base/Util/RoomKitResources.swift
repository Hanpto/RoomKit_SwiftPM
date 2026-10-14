import UIKit

private final class RoomKitBundleToken {}

public enum RoomKitResources {

    public static let bundle: Bundle = {
        let containingBundle = Bundle(for: RoomKitBundleToken.self)
        let candidates = [containingBundle, .main]
        for candidate in candidates {
            if let url = candidate.url(forResource: "TUIRoomKitBundle", withExtension: "bundle"),
               let resourceBundle = Bundle(url: url) {
                return resourceBundle
            }
        }
        return containingBundle
    }()

    public static func image(named name: String) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    public static func localizedString(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: key, table: nil)
    }

    public static func localizedFormat(_ key: String, _ arguments: CVarArg...) -> String {
        String(
            format: localizedString(key),
            locale: Locale.current,
            arguments: arguments
        )
    }
}
