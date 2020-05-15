//
//  Room.swift
//
//
//  Created by Paul Ledger on 22/04/2020.
//

import Foundation
import SpriteKit
import GameplayKit

public class Room: NSObject {
    var node: SKShapeNode   // Used to hold the "floor" of the room
    var number: Int         // Used to identify the room
    var cols: Int           // Number of columns the room is made up of
    var rows: Int           // Number of rows the room is made up of
    var doors = [Door]()    // Holds the doors the room has

    private let randomSource = GKRandomSource.sharedRandom()

    public init(number: Int) {
        self.number = number

        // Create a random number of columns and rows, based on restrictions.
        // Multiply the random number by 2 always ensures that we get an "even" sized room

        self.cols = Int.random(in: Constants.Constraints.minimumExtent..<Constants.Constraints.maximumExtent) * 2
        let width = Int(cols * Constants.Constraints.tileSize)
        self.rows = Int.random(in: Constants.Constraints.minimumExtent..<Constants.Constraints.maximumExtent) * 2
        let height = Int(rows * Constants.Constraints.tileSize)

        // Create a basic node using the size and fill it in so we can see it
        self.node = SKShapeNode(rectOf: CGSize(width: width, height: height))
        self.node.lineWidth = 0
        self.node.fillColor = .red
        self.node.name = "room\(self.number)"

        // A random position for the room
        let x = Int(Int.random(in: Constants.Constraints.minimumPositionOffset..<Constants.Constraints.maximumPositionOffset) * Constants.Constraints.tileSize)
        let y = Int(Int.random(in: Constants.Constraints.minimumPositionOffset..<Constants.Constraints.maximumPositionOffset) * Constants.Constraints.tileSize)

        self.node.position = CGPoint(x: x, y: y)

        // Create a basic node using the size reduced by 2 tile sizes in each direction
        let floor =  SKShapeNode(rectOf: CGSize(width: width - (Constants.Constraints.tileSize * 2), height: height - (Constants.Constraints.tileSize * 2)))
        floor.lineWidth = 0
        floor.fillColor = .black
        self.node.addChild(floor)
    }

    public init(number: Int, rect: CGRect) {
        self.number = number

        self.cols = Int(rect.width) / Constants.Constraints.tileSize
        self.rows = Int(rect.height) / Constants.Constraints.tileSize

        self.node = SKShapeNode(rectOf: rect.size)
        self.node.lineWidth = 0
        self.node.name = "room\(self.number)"

        self.node.position = CGPoint(x: rect.midX, y: rect.midY)
        // Create a basic node using the size reduced by 2 tile sizes in each direction
        let floor =  SKShapeNode(rectOf: CGSize(width: Int(rect.width) - (Constants.Constraints.tileSize * 2),
                                                height: Int(rect.height) - (Constants.Constraints.tileSize * 2)))
        floor.lineWidth = 0
        floor.fillColor = .yellow
        self.node.addChild(floor)
    }


    public func render(scene: SKScene) {
        drawDoors()
        scene.addChild(self.node)
    }

    func drawDoors() {
        for door in self.doors {

            // Create a square that represents the door
            let doorShape =  SKShapeNode(rectOf: CGSize(width: Constants.Constraints.tileSize, height: Constants.Constraints.tileSize))
            doorShape.lineWidth = 0
            doorShape.fillColor = .blue

            // Now calculate the X/Y position
            let x = (Int(door.joiningPoint.x) * Constants.Constraints.tileSize) - (Int(width) / 2) + Constants.Constraints.halfTileSize
            let y = (Int(door.joiningPoint.y) * Constants.Constraints.tileSize) - (Int(height) / 2) + Constants.Constraints.halfTileSize

            doorShape.position = CGPoint(x: x, y: y)

            self.node.addChild(doorShape)
        }
    }


    public var frame: CGRect {
        self.node.frame
    }

    public var noDoors: Bool {
        return doors.count == 0
    }

    var height: CGFloat {
        self.node.frame.height
    }

    var width: CGFloat {
        self.node.frame.width
    }

    var leftEdge: Int {
        return Int(self.node.frame.minX)
    }

    var rightEdge: Int {
        return Int(self.node.frame.maxX)
    }

    var bottomEdge: Int {
        return Int(self.node.frame.minY)
    }

    var topEdge: Int {
        return Int(self.node.frame.maxY)
    }

    public func moveTo(x: CGFloat = CGFloat.greatestFiniteMagnitude,
                       y: CGFloat = CGFloat.greatestFiniteMagnitude ) {
        // Using 'fixed' default values means we only need to
        // supply the values that need to change.
        // If the default value is detected then the existing value is used

        self.node.position = CGPoint(x: ( x == CGFloat.greatestFiniteMagnitude ? self.node.position.x : x ),
                                     y: ( y == CGFloat.greatestFiniteMagnitude ? self.node.position.y : y ))
    }

    public func removeOverlap(rooms: [Room]) -> Int {
        // Used to highlight that intersections were found
        var intersectionCount = 0

        // Pulling out values from the frame, for simplicity
        let thisFrame = self.frame
        let thisRoomBottom = thisFrame.minY
        let thisRoomTop = thisFrame.maxY
        let thisRoomLeft = thisFrame.minX
        let thisRoomRight = thisFrame.maxX

        for otherRoom in rooms {

            if thisFrame.intersects(otherRoom.frame) {
                // Check the frames and if they intersect the otherRoom needs to move

                intersectionCount += 1

                // In order to keep the "randomness" of the rooms,
                // we calculate new X and Y positions based on this rooms position.
                // Using the nextBool function we can get varying layouts

                // The height and width are halved because the anchor point is in the centre of the room

                let newY = randomSource.nextBool()
                    ? thisRoomBottom - (otherRoom.height / 2)
                    : thisRoomTop + (otherRoom.height / 2)

                let newX =  randomSource.nextBool()
                    ? thisRoomLeft - (otherRoom.width / 2)
                    : thisRoomRight + (otherRoom.width / 2)

                //Randomly pick which way to move the room
                if randomSource.nextBool() {
                    otherRoom.moveTo(y: newY)
                } else {
                    otherRoom.moveTo(x: newX)
                }

                if self.frame.intersects(otherRoom.frame) {
                    // they are still intersecting so change both values
                    otherRoom.moveTo(x: newX, y: newY)
                }
            }
        }

        return intersectionCount
    }

    public func sameEdge(toRoom: Room) -> Bool {
        if self.doors.filter( { $0.connectingRoomNumber == toRoom.number }).count > 0 {
            //we already have this connection and therefore we don't need to add another door
            return false
        }

        return self.leftEdge == toRoom.rightEdge ||
            self.rightEdge == toRoom.leftEdge ||
            self.topEdge == toRoom.bottomEdge ||
            self.bottomEdge == toRoom.topEdge
    }

    public func buttingConnection(toRoom: Room) {
        if self.doors.filter( { $0.connectingRoomNumber == toRoom.number }).count > 0 {
            //we already have this connection
            return
        }

        if self.leftEdge == toRoom.rightEdge, sameVerticalSpace(toRoom) {
            createConnectingDoor(toRoom: toRoom, basedOnWall: .left)
            return
        } else if self.rightEdge == toRoom.leftEdge, sameVerticalSpace(toRoom) {
            createConnectingDoor(toRoom: toRoom, basedOnWall: .right)
            return
        } else if self.topEdge == toRoom.bottomEdge, sameHorizontalSpace(toRoom) {
            createConnectingDoor(toRoom: toRoom, basedOnWall: .top)
           return
       } else if self.bottomEdge == toRoom.topEdge, sameHorizontalSpace(toRoom) {
           createConnectingDoor(toRoom: toRoom, basedOnWall: .bottom)
           return
        }
    }

    func sameVerticalSpace(_ toRoom: Room) -> Bool {
       // check for complete cover first
       if self.bottomEdge <= toRoom.bottomEdge, self.topEdge >= toRoom.topEdge {
           return true
       }

        //Is there enough space for the door
        return self.frame.intersection(toRoom.frame).height >= Constants.Constraints.doorSpace
   }

   func sameHorizontalSpace(_ toRoom: Room) -> Bool {

       //check for complete cover first
       if self.leftEdge <= toRoom.leftEdge && self.rightEdge >= toRoom.rightEdge {
           return true
       }

       return self.frame.intersection(toRoom.frame).width >= Constants.Constraints.doorSpace
   }

   func createConnectingDoor(toRoom: Room, basedOnWall: Constants.DoorWall) {
       // Used to determine what edges we are comparing
       let sideDoor = (basedOnWall == .left || basedOnWall == .right)
       // Gives an intersection so that we know how much space we have for the door
       let intersection = self.frame.intersection(toRoom.frame)

       // Calculate the edges, adjusting by a tileSize to allow for the walls
       let maxEdge = Int(sideDoor ? intersection.maxY : intersection.maxX) - Constants.Constraints.tileSize
       let minEdge = Int(sideDoor ? intersection.minY : intersection.minX) + Constants.Constraints.tileSize

       // This gives a count of how many places the dooe could actually be placed
       let availablePositions = (maxEdge - minEdge) / Constants.Constraints.tileSize

       // Now pick a random position so that not all rooms appear in the same place
       let offset = Int.random(in: 0..<availablePositions)

       var myJoiningPoint = CGPoint.zero
       var toRoomJoiningPoint = CGPoint.zero

       // Calculate the tileSize offset of the door for both this room and the room we are connecting to
       let doorbaseOffset = (minEdge - (sideDoor ? self.bottomEdge : self.leftEdge)) / Constants.Constraints.tileSize
       let toRoomOffset = (minEdge - (sideDoor ? toRoom.bottomEdge : toRoom.leftEdge)) / Constants.Constraints.tileSize

       var oppositeWall: Constants.DoorWall = .right
       // Calculate the X/Y points for the door in each room.
       if sideDoor {
           myJoiningPoint.y = CGFloat(doorbaseOffset + offset)
           myJoiningPoint.x = (basedOnWall == .left) ? 0 : CGFloat(cols - 1)
           toRoomJoiningPoint.y = CGFloat(toRoomOffset + offset)
           toRoomJoiningPoint.x = (basedOnWall == .left) ? CGFloat(toRoom.cols - 1) : 0
           oppositeWall = (basedOnWall == .left) ? .right : .left
       } else {
           myJoiningPoint.x = CGFloat(doorbaseOffset + offset)
           myJoiningPoint.y = (basedOnWall == .bottom) ? 0 : CGFloat(rows-1)
           toRoomJoiningPoint.x = CGFloat(toRoomOffset + offset)
           toRoomJoiningPoint.y = (basedOnWall == .bottom) ? CGFloat(toRoom.rows-1 ) : 0
           oppositeWall = (basedOnWall == .bottom) ? .top : .bottom
       }

       // Create a door for this room and for the room its connecting to
       self.doors.append(Door(connectingRoomNumber: toRoom.number,
                              joiningPoint: myJoiningPoint,
                              wall: basedOnWall))
       toRoom.doors.append(Door(connectingRoomNumber: self.number,
                                joiningPoint: toRoomJoiningPoint,
                                wall: oppositeWall))
   }

    public func generateCorridor(_ levelArea: CGRect, _ rooms: [Room]) -> Room? {
        // The unique number of the room if it gets created
        let roomNumber = rooms.count

        // Try and create a horizontal corridor
        if let corridor = generateHorizontalCorridor(levelArea, rooms, roomNumber) {
            return corridor
        }

        // We've not created a horizontal one, so try and create a vertical one
        if let corridor = generateVerticalCorridor(levelArea, rooms, roomNumber) {
            return corridor
        }

        return nil
    }
    func generateHorizontalCorridor(_ levelArea: CGRect, _ rooms: [Room], _ roomNumber: Int) -> Room? {
        // Calculate the imaginary rectangle that extends the width of the level
        // Place it at the bottom edge of the room
        var horizontalExtension =  CGRect( x: Int(levelArea.minX),
                                           y: Int(frame.minY) ,
                                           width:  Int(levelArea.width),
                                           height: Constants.Constraints.corridorSize)
        repeat {
            // Move the rectangle up a tile (first time this allows for missing the wall
            horizontalExtension = horizontalExtension.offsetBy(dx: 0, dy: Constants.Constraints.floatTileSize)

            // Find any rooms that intersect this area, that are to the left of this room
            // and sort them so that the nearest one is the first in the results
            let intersectingLeftRooms = rooms.filter(
                    { $0.frame.intersects(horizontalExtension) &&
                        $0.leftEdge < leftEdge
                        }
                    ).sorted { $0.leftEdge > $1.leftEdge }

            // If we have a room, see if we can create the corridor, if it is return it
            if let possibleRoom = intersectingLeftRooms.first,
                let corridor = createHorizontalCorridor(horizontalExtension, possibleRoom, .left, roomNumber) {
                return corridor
            }

            // Find any rooms that intersect this area, that are to the right of this room
            // and sort them so that the nearest one is the first in the results
            let intersectingRightRooms = rooms.filter(
                    { $0.frame.intersects(horizontalExtension) &&
                        $0.rightEdge > rightEdge
                    }
                ).sorted { $0.rightEdge < $1.rightEdge }
            // If we have a room, see if we can create the corridor, if it is return it
            if let possibleRoom = intersectingRightRooms.first,
                let corridor = createHorizontalCorridor(horizontalExtension, possibleRoom, .right, roomNumber)  {
                return corridor
            }

            // We've not created a corridor, if we have space to move the imaginary
            // rectangle up then loop back round and try again

        } while Int(horizontalExtension.maxY) < topEdge

        return nil
    }

    func createHorizontalCorridor(_ horizontalExtension: CGRect, _ possibleRoom: Room, _ direction: Constants.DoorWall, _ roomNumber: Int) -> Room? {
        // Calculate the intersection with the room and check that the area can actually fit a corridor
        let intersection = possibleRoom.frame.intersection(horizontalExtension)
        if Int(intersection.height) == Constants.Constraints.corridorSize, Int(intersection.width) >= Constants.Constraints.tileSize {
            // Calculate the dimensions based on the direction the corridor is going
            let corridorRect = direction == .left
                ? CGRect(x: possibleRoom.rightEdge,
                         y: Int(horizontalExtension.minY),
                         width: abs(leftEdge - possibleRoom.rightEdge),
                         height: Constants.Constraints.corridorSize)
                : CGRect(x: rightEdge,
                         y: Int(horizontalExtension.minY),
                         width: abs(possibleRoom.leftEdge - rightEdge),
                         height: Constants.Constraints.corridorSize)

            // Create the room
            let corridorRoom = Room(number: roomNumber, rect: corridorRect)

            // Add the doors
            corridorRoom.createConnectingDoor(toRoom: self, basedOnWall:  direction == .left ? .right : .left)
            corridorRoom.createConnectingDoor(toRoom: possibleRoom, basedOnWall: direction == .left ? .left : .right)
            return corridorRoom
        }

        return nil
    }

    func generateVerticalCorridor(_ levelArea: CGRect, _ rooms: [Room], _ roomNumber: Int) -> Room? {
        var verticalExtension =  CGRect( x: Int(frame.minX),
                                         y: Int(levelArea.minY),
                                         width:  Constants.Constraints.corridorSize,
                                         height: Int(levelArea.height))
        repeat {
            verticalExtension = verticalExtension.offsetBy(dx: Constants.Constraints.floatTileSize, dy: 0)

            let intersectingTopRooms = rooms.filter(
                    { $0.frame.intersects(verticalExtension) &&
                            $0.topEdge > topEdge
                        }
                    ).sorted { $0.topEdge < $1.topEdge }
            if let possibleRoom = intersectingTopRooms.first,
                let corridor = createVerticalCorridor(verticalExtension, possibleRoom, .top, roomNumber) {
                return corridor
            }

            let intersectingBottomRooms = rooms.filter(
                    { $0.frame.intersects(verticalExtension) &&
                            $0.topEdge < topEdge
                        }
                    ).sorted { $0.topEdge > $1.topEdge }
            if let possibleRoom = intersectingBottomRooms.first,
                let corridor = createVerticalCorridor(verticalExtension, possibleRoom, .bottom, roomNumber) {
                return corridor
            }

        } while Int(verticalExtension.maxX) < rightEdge

        return nil
    }


    func createVerticalCorridor(_ verticalExtension: CGRect, _ possibleRoom: Room, _ direction: Constants.DoorWall, _ roomNumber: Int) -> Room? {
        let intersection = possibleRoom.frame.intersection(verticalExtension)
        if Int(intersection.width) == Constants.Constraints.corridorSize, Int(intersection.height) >= Constants.Constraints.tileSize {
            let corridorRect = direction == .top
                ? CGRect(x: Int(verticalExtension.minX),
                         y: topEdge,
                         width: Constants.Constraints.corridorSize ,
                         height: abs(possibleRoom.bottomEdge - topEdge))
                : CGRect(x: Int(verticalExtension.minX),
                         y: possibleRoom.topEdge,
                         width: Constants.Constraints.corridorSize,
                         height: abs(bottomEdge - possibleRoom.topEdge))

            let corridorRoom = Room(number: roomNumber, rect: corridorRect)

            corridorRoom.createConnectingDoor(toRoom: self, basedOnWall:  direction == .top ? .bottom : .top)
            corridorRoom.createConnectingDoor(toRoom: possibleRoom, basedOnWall: direction == .top ? .top : .bottom)
            return corridorRoom

        }

        return nil
    }
}
