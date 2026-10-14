import AtomicXCore

extension RoomParticipant {

    var displayName: String {
        if !nameCard.isEmpty { return nameCard }
        if !userName.isEmpty { return userName }
        return userID
    }
}
