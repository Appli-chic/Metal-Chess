import MetalKit

private let BOARD_SIZE = 8

class Board {
    private var tiles: [[Tile]] = []
    
    init(metalDevice: MTLDevice) {
        for y in 0..<BOARD_SIZE+1 {
            var tileRow: [Tile] = []
            
            for x in 0..<BOARD_SIZE+1 {
                tileRow.append(Tile(metalDevice: metalDevice, x: x, y: y))
            }
            
            tiles.append(tileRow)
        }
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder?) {
        for row in tiles {
            for tile in row {
                tile.draw(renderEncoder: renderEncoder)
            }
        }
    }
}

class Tile {
    private let vertexBuffer: MTLBuffer
    
    init(metalDevice: MTLDevice, x: Int, y: Int) {
        let black: vector_float4 = [0, 0, 0, 1]
        let white: vector_float4 = [1, 1, 1, 1]
        
        let isRowEven = x % 2 == 0 && y % 2 == 0
        let isColumnOdd = x % 2 != 0 && y % 2 != 0
        let color: vector_float4 = if(isRowEven || isColumnOdd) {
            black
        } else {
            white
        }
        
        let tileSize: Float = 2 / Float(BOARD_SIZE)
        let positionX = -1 + (tileSize * Float(x))
        let positionY = -1 + (tileSize * Float(y))
        
        let bottomLeftVertex = Vertex(position: [positionX, positionY], color: color)
        let bottomRightVertex = Vertex(position: [positionX + tileSize, positionY], color: color)
        let topRightVertex = Vertex(position: [positionX + tileSize, positionY + tileSize], color: color)
        let topLeftVertex = Vertex(position: [positionX, positionY + tileSize], color: color)
        
        let vertices = [
            topLeftVertex,
            topRightVertex,
            bottomRightVertex,
            
            topLeftVertex,
            bottomLeftVertex,
            bottomRightVertex,
        ]
        
        self.vertexBuffer = metalDevice.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: [],
        )!
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder?) {
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
