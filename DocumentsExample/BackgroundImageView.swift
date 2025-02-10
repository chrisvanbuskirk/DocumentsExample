import SwiftUI
import UIKit

// MARK: - SwiftUI View
struct BackgroundImageView: View {
    var body: some View {
        
        ZStack {
            Image("pinkJungle")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

// MARK: - UIImage Converter
extension View {
    func asUIImage(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // Add to a temporary window to ensure proper rendering
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        // Configure the controller's view
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        
        // Force a layout pass
        window.layoutIfNeeded()
        
        // Render to image
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
        
        // Clean up
        window.resignKey()
        
        return image
    }
}
