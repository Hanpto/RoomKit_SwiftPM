import Foundation

public enum RoomRandomUtils {
    public static func roomID() -> String {
        String(UInt32.random(in: 100_000...999_999))
    }
}
