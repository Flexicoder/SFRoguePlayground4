import UIKit

struct Door {
    // A connection from a room to another, the connecting room will have an "opposite" door
    var connectingRoomNumber: Int   // The number of the room this door connects to
    var joiningPoint: CGPoint       // The position the door appears in the room
    var wall: Constants.DoorWall    // Which wall the door appears on
}
