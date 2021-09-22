import SceneKit

// MARK: - An axes grid for debugging
/// show the world origin
/// from https://gist.github.com/cenkbilgen/ba5da0b80f10dc69c10ee59d4ccbbda6
public class Origin: SCNNode {
    
    /// see: https://developer.apple.com/documentation/arkit/arsessionconfiguration/worldalignment/gravityandheading
    /// if ar session configured with gravity and heading, then +x is east, +y is up, +z is south
    
    private enum Axis {
        case x, y, z

        var normal: SIMD3<Float> {
            switch self {
            case .x: return SIMD3(1, 0, 0)
            case .y: return SIMD3(0, 1, 0)
            case .z: return SIMD3(0, 0, 1)
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    public init(length: CGFloat = 0.1, radiusRatio ratio: CGFloat = 0.04, color: (x: UIColor, y: UIColor, z: UIColor, origin: UIColor) = (.blue, .green, .red, .cyan), addPlane: Bool) {
        
        /// x-axis
        let xAxis = SCNCylinder(radius: length*ratio, height: length)
        xAxis.firstMaterial?.diffuse.contents = color.x
        let xAxisNode = SCNNode(geometry: xAxis)
        /// by default the middle of the cylinder will be at the origin aligned to the y-axis
        /// need to spin around to align with respective axes and shift position so they start at the origin
        xAxisNode.simdWorldOrientation = simd_quatf.init(angle: .pi/2, axis: Axis.z.normal)
        xAxisNode.simdWorldPosition = simd_float1(length)/2 * Axis.x.normal
        
        /// x-axis mirror
        let xAxisMirror = SCNCylinder(radius: length*ratio, height: length)
        xAxisMirror.firstMaterial?.diffuse.contents = color.x.withAlphaComponent(0.4)
        let xAxisMirrorNode = SCNNode(geometry: xAxisMirror)
        xAxisMirrorNode.simdWorldOrientation = simd_quatf.init(angle: .pi/2, axis: Axis.z.normal)
        xAxisMirrorNode.simdWorldPosition = -simd_float1(length)/2 * Axis.x.normal
        
        /// y-axis
        let yAxis = SCNCylinder(radius: length*ratio, height: length)
        yAxis.firstMaterial?.diffuse.contents = color.y
        let yAxisNode = SCNNode(geometry: yAxis)
        yAxisNode.simdWorldPosition = simd_float1(length)/2 * Axis.y.normal /// just shift
        
        let yAxisMirror = SCNCylinder(radius: length*ratio, height: length)
        yAxisMirror.firstMaterial?.diffuse.contents = color.y.withAlphaComponent(0.4)
        let yAxisMirrorNode = SCNNode(geometry: yAxisMirror)
        yAxisMirrorNode.simdWorldPosition = -simd_float1(length)/2 * Axis.y.normal
        
        
        /// z-axis
        let zAxis = SCNCylinder(radius: length*ratio, height: length)
        zAxis.firstMaterial?.diffuse.contents = color.z
        let zAxisNode = SCNNode(geometry: zAxis)
        zAxisNode.simdWorldOrientation = simd_quatf(angle: -.pi/2, axis: Axis.x.normal)
        zAxisNode.simdWorldPosition = simd_float1(length)/2 * Axis.z.normal
        
        let zAxisMirror = SCNCylinder(radius: length*ratio, height: length)
        zAxisMirror.firstMaterial?.diffuse.contents = color.z.withAlphaComponent(0.4)
        let zAxisMirrorNode = SCNNode(geometry: zAxisMirror)
        zAxisMirrorNode.simdWorldOrientation = simd_quatf(angle: -.pi/2, axis: Axis.x.normal)
        zAxisMirrorNode.simdWorldPosition = -simd_float1(length)/2 * Axis.z.normal
        
        /// dot at origin
        let origin = SCNSphere(radius: length*ratio*2)
        origin.firstMaterial?.diffuse.contents = color.origin
        origin.firstMaterial?.transparency = 0.5
        let originNode = SCNNode(geometry: origin)
        
        super.init()
        
        self.addChildNode(originNode)
        self.addChildNode(xAxisNode)
        self.addChildNode(yAxisNode)
        self.addChildNode(zAxisNode)
        
        self.addChildNode(xAxisMirrorNode)
        self.addChildNode(yAxisMirrorNode)
        self.addChildNode(zAxisMirrorNode)
        
        if addPlane {
            let planeGeo = SCNPlane(width: length * 2, height: length * 2)
            
            let imageMaterial = SCNMaterial()
            imageMaterial.diffuse.contents = UIImage(named: "Grid")
            imageMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(32, 32, 0)
            imageMaterial.isDoubleSided = true
            
            planeGeo.firstMaterial = imageMaterial
            
            let plane = SCNNode(geometry: planeGeo)
            plane.name = "PlaneNode"
            
            plane.geometry?.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
            plane.geometry?.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
            plane.simdWorldOrientation = simd_quatf.init(angle: -.pi/2, axis: Axis.x.normal)
            self.addChildNode(plane)
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
