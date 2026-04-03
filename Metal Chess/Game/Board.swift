import MetalKit

private let BOARD_SIZE = 8
let TILE_SIZE: Float = 2 / Float(BOARD_SIZE)

class Board {
    private let vertexBuffer: MTLBuffer
    private let vertexCount = BOARD_SIZE * BOARD_SIZE * 6
    private let whitePieces: [Piece] = [
        Piece(x: 0, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 1, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 2, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 3, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 4, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 5, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 6, y: 1, color: [1, 0, 0, 1]),
        Piece(x: 7, y: 1, color: [1, 0, 0, 1]),
    ]
    
    private let blackPieces: [Piece] = [
        Piece(x: 0, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 1, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 2, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 3, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 4, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 5, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 6, y: 6, color: [1, 1, 0, 1]),
        Piece(x: 7, y: 6, color: [1, 1, 0, 1]),
    ]
    
    init(metalDevice: MTLDevice) {
        var vertices: [Vertex] = []
        vertices.reserveCapacity(vertexCount)
        
        for y in 0..<BOARD_SIZE {
            for x in 0..<BOARD_SIZE {
                Board.createTileVertices(vertices: &vertices, x: x, y: y, tileSize: TILE_SIZE)
            }
        }
        
        self.vertexBuffer = metalDevice.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared,
        )!
    }
    
    func draw(metalDevice: MTLDevice, renderEncoder: MTLRenderCommandEncoder?) {
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
        
        for piece in whitePieces {
            piece.draw(metalDevice: metalDevice, renderEncoder: renderEncoder)
        }
        
        for piece in blackPieces {
            piece.draw(metalDevice: metalDevice, renderEncoder: renderEncoder)
        }
    }
    
    private static func createTileVertices(vertices: inout [Vertex], x: Int, y: Int, tileSize: Float) {
        let color = Board.getTileColor(x: x, y: y)
        
        let positionX = -1 + (tileSize * Float(x))
        let positionY = -1 + (tileSize * Float(y))
        
        let bottomLeftVertex = Vertex(position: [positionX, positionY], color: color)
        let bottomRightVertex = Vertex(position: [positionX + tileSize, positionY], color: color)
        let topRightVertex = Vertex(position: [positionX + tileSize, positionY + tileSize], color: color)
        let topLeftVertex = Vertex(position: [positionX, positionY + tileSize], color: color)
        
        vertices.append(contentsOf: [
            topLeftVertex,
            topRightVertex,
            bottomRightVertex,
            
            topLeftVertex,
            bottomLeftVertex,
            bottomRightVertex,
        ])
    }
    
    private static func getTileColor(x: Int, y: Int) -> vector_float4 {
        return if (x + y) % 2 == 0 {
            [0, 0, 0, 1]
        } else {
            [1, 1, 1, 1]
        }
    }
}
