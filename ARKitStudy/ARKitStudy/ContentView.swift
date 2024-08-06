//
//  ContentView.swift
//  ARKitStudy
//
//  Created by Enes on 7/3/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var arModel = ARModel()
    
    var body: some View {
        ARViewContainer()
        .edgesIgnoringSafeArea(.all)
        .environment(arModel)
            .overlay(alignment: .bottom) {
                HStack {
                    Button {
                        arModel.tapLeftButton()
                    } label: {
                        Image(.tankLeft)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .padding(.bottom, 100)
                            .padding(.trailing, 30)
                    }
                    Button {
                        arModel.tapForwardButton()
                    } label: {
                        Image(.tankForward)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .padding(.bottom, 100)
                            .padding(.trailing, 30)
                    }
                    Button {
                        arModel.tapRightButton()
                    } label: {
                        Image(.tankRight)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .padding(.bottom, 100)
                            .padding(.trailing, 30)
                    }
                }
            }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Environment(ARModel.self) private var arModel
    
    func makeUIView(context: Context) -> ARView {
        arModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

@Observable
final class ARModel {
    let arView = ARView(frame: .zero)
    var tankModel: TinyToyTank._TinyToyTank?
    let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.1, 0.1)))
    
    init() {
        Task {
            await setup()
        }
    }
    
    @MainActor
    func setup() {
        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        
        
        anchor.children.append(model)
        // Add the horizontal plane anchor to the scene

        arView.scene.anchors.append(anchor)
        if let tankModel = try? TinyToyTank.load_TinyToyTank() {
            self.tankModel = tankModel
            arView.scene.anchors.append(tankModel)
        }
    }
    
    // 카메라 보는쪽 반대방향이 + 방향
    @MainActor
    func tapRightButton() {
        tankModel?.notifications.tankRight.post()
    }
    
    @MainActor
    func tapLeftButton() {
        tankModel?.notifications.tankLeft.post()
    }
    
    @MainActor
    func tapForwardButton() {
        tankModel?.notifications.tankForward.post()
    }
    
    func move() {
        let beforePos = anchor.position
        
        // 애니메이션 이동
        let transform = Transform(translation: [beforePos.x + 0.5, beforePos.y + 0.5, beforePos.z + 0.5])
        anchor.move(to: transform, relativeTo: nil, duration: 1)
        
        // 그냥이동
        let movePos: Float = 0.01
        anchor.position = [beforePos.x + movePos, beforePos.y + movePos, beforePos.z + movePos]
    }
}

#Preview {
    ContentView()
}
