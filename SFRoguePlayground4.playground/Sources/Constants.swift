import UIKit

public enum Constants {
    public struct Constraints {
        public static let tileSize = 4                 // The rendered tile size, ensure this is an evem number
        public static let minimumExtent = 3            // The minimum number of rows or columns
        public static let maximumExtent = 9            // The maximum number of rows or columns
        public static let minimumPositionOffset = 10   // Minimum random offset for positioning a room
        public static let maximumPositionOffset = 40   // Maximum random offset for positioning a room
        public static let doorSpace = CGFloat(Constraints.tileSize * 3) // Need to allow space for the door plus the 2 walls (if this is a corridor)
        public static let halfTileSize = Constraints.tileSize / 2       // Half the size for positional calculations
        public static let corridorSize = Constants.Constraints.tileSize * 3
        
    }

    public enum DoorWall {
        case right
        case left
        case top
        case bottom
    }
}
