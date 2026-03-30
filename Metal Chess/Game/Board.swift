import MetalKit

class Board {
    private var tiles: [[Tile]] = []
    
    init(metalDevice: MTLDevice) {
        for y in 0..<8 {
            var tileRow: [Tile] = []
            
            for x in 0..<8 {
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
        let isWhiteFirstLine = y % 2 == 0
        
        let color: vector_float4 = if(isWhiteFirstLine) {
            // Black
            [1, 0, 0, 1]
        } else {
            // White
            [0, 0, 1, 1]
        }
        
        let vertices = [
            Vertex(position: [-0.5, 0.5], color: color),
            Vertex(position: [0.5, 0.5], color: color),
            Vertex(position: [0.5, -0.5], color: color),
            
            Vertex(position: [-0.5, 0.5], color: color),
            Vertex(position: [-0.5, -0.5], color: color),
            Vertex(position: [0.5, -0.5], color: color),
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
