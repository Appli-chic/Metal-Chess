import MetalKit

class Board {
    private var tiles: [[Tile]] = []
    
    init(metalDevice: MTLDevice) {
        for y in 0..<9 {
            var tileRow: [Tile] = []
            
            for x in 0..<9 {
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
        
        let color: vector_float4 = if(x % 2 == 0) {
            if(y % 2 == 0) {
                black
            } else {
                white
            }
        } else {
            if(y % 2 == 0) {
                white
            } else {
                black
            }
        }
        
        let tileSize: Float = 2 / 8
        let floatX = Float(x)
        let floatY = Float(y)
        let positionX = -1 + (tileSize * floatX)
        let positionY = 1 - (tileSize * floatY)
        
        let topLeftVertex = Vertex(position: [positionX, positionY], color: color)
        let topRightVertex = Vertex(position: [positionX + tileSize, positionY], color: color)
        let bottomRightVertex = Vertex(position: [positionX + tileSize, positionY + tileSize], color: color)
        let bottomLeftVertex = Vertex(position: [positionX, positionY + tileSize], color: color)
        
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
