import PlaygroundSupport
import SpriteKit

class GameScene: SKScene {

    // Array that will be used to hold all of the created rooms, for future use
    private var rooms = [Room]()
    private var totalRooms = 20

    override func didMove(to view: SKView) {
        // Now we have a view to render too, create how many rooms we need for the map
        for number in 0..<totalRooms {
            let room = Room(number: number)
            self.rooms.append(room)
        }

        var arrangedCount = 0
        repeat {
            arrangedCount = arrangeRooms()
        } while arrangedCount > 0

        findConnections()
        findCorridors()

        for room in rooms {
            room.render(scene: self)
        }
    }

    func arrangeRooms() -> Int {
        var overlappingCount = 0

        // Loop through all the rooms, with the exception of the last one
        for count in 0..<rooms.count-1 {

            let thisRoom = rooms[count]

            // Now remove the overlaps for this room and the rooms placed after it in the array
            overlappingCount += thisRoom.removeOverlap(rooms: Array(rooms[count+1..<rooms.count]) )
        }
        return overlappingCount
    }

    func findConnections() {
        // Loop through the rooms, except the last one as there are no rooms further
        // down the array and we would of processed any connections already
        for count in 0..<rooms.count-1 {
            let thisRoom = rooms[count]
            // Looking at rooms further in the array, find ones that have touching edges
            let touchingRooms = Array(rooms[count+1..<rooms.count])
                .filter( { thisRoom.sameEdge(toRoom: $0)})

            for touchingRoom in touchingRooms {
                // Now for the ones with touching edges, see if we can actually make a connection
                thisRoom.buttingConnection(toRoom: touchingRoom)
            }
        }
    }

    func findCorridors() {
        // Calculate the whole area the rooms are contained in
        var levelArea = CGRect.zero
        for room in rooms {
            levelArea = room.frame.union(levelArea)
        }

        // Find the rooms that don't have an doors,
        // obviously not all levels will contain rooms with no doors
        let roomsWithoutDoors = rooms.filter( { $0.noDoors } )
        for room in roomsWithoutDoors {
            // Attempt to create a corridor and add it to the array of rooms
            if let corridor = room.generateCorridor(levelArea, rooms) {
                rooms.append(corridor)
            }
        }
    }


}

// Sets up the scene for us to render to
func createScene() -> SKView {
    let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 768, height: 1024))

    let scene = GameScene(size: sceneView.frame.size)
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

    // Present the scene
    sceneView.presentScene(scene)
    return sceneView
}

PlaygroundSupport.PlaygroundPage.current.liveView = createScene()
