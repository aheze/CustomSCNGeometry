import UIKit
import SceneKit
import PlaygroundSupport

// create a scene view with an empty scene
var sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
var scene = SCNScene()
sceneView.scene = scene
sceneView.backgroundColor = UIColor(white: 1, alpha: 1.0)
sceneView.allowsCameraControl = true
PlaygroundPage.current.liveView = sceneView

let directionalLightNode: SCNNode = {
    let n = SCNNode()
    n.light = SCNLight()
    n.light!.type = SCNLight.LightType.directional
    n.light!.color = UIColor(white: 0.75, alpha: 1.0)
    return n
}()

directionalLightNode.simdPosition = simd_float3(0,5,0) // Above the scene
directionalLightNode.simdOrientation = simd_quatf(angle: -90 * Float.pi / 180.0, axis: simd_float3(1,0,0)) // pointing down
scene.rootNode.addChildNode(directionalLightNode)

// a camera
var cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.simdPosition = simd_float3(0,0,5)
scene.rootNode.addChildNode(cameraNode)

// MARK: - Debugging
scene.rootNode.addChildNode(Origin(length: 2, radiusRatio: 0.006, color: (x: .red, y: .green, z: .blue, origin: .black), addPlane: false))
sceneView.autoenablesDefaultLighting = true /// better lighting

// MARK: - Nodes
// Example creating SCNGeometry using vertex data
struct Vertex {
    let x: Float
    let y: Float
    let z: Float
    let r: Float
    let g: Float
    let b: Float
}

/// step 1
let vertices: [Vertex] = [
    Vertex(x: 0.0, y: 0.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0),
    Vertex(x: 1.0, y: 0.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0),
    Vertex(x: 1.0, y: 0.0, z: -0.5, r: 0.0, g: 0.0, b: 1.0),
    Vertex(x: 0.0, y: 1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0),
]
let verticesConverted = vertices.map { SCNVector3($0.x, $0.y, $0.z) }
let positionSource = SCNGeometrySource(vertices: verticesConverted)

/// step 2
let indices: [UInt16] = [
    0, 1, 3,
    1, 2, 3,
    2, 0, 3,
    3, 0, 2,
    0, 2, 1
]
let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)

/// step 3
let geometry = SCNGeometry(sources: [positionSource], elements: [element])

/// add some color
let material = SCNMaterial()
material.diffuse.contents = UIColor.orange
material.lightingModel = .physicallyBased
geometry.materials = [material]

/// add the node
let node = SCNNode(geometry: geometry)
scene.rootNode.addChildNode(node)



