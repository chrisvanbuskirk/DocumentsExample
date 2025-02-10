//
//  AccessoryView.swift
//  DocumentsExample
//
//  Created by Chris Van Buskirk on 2/9/25.
//

import SwiftUI
import UIKit

struct AccessoryView: View {
    @Environment(\.horizontalSizeClass) private var horizontal
    @State private var size: CGSize = CGSize()

    var body: some View {
        ZStack {
            Image(.robot)
                .resizable()
                .offset(x: size.width / 2 - 450, y: size.height / 2 - 300)
                .scaledToFit()
                .frame(width: 200)
                .opacity(horizontal == .compact ? 0 : 1)
            Image(.plant)
                .resizable()
                .offset(x: size.width / 2 + 250, y: size.height / 2 - 250)
                .scaledToFit()
                .frame(width: 200)
                .opacity(horizontal == .compact ? 0 : 1)
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { proxySize in
            size = proxySize
        }
    }
}

// Create a UIView subclass to host the SwiftUI view
class AccessoryUIView: UIView {
    private var hostingController: UIHostingController<AccessoryView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingController()
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false  // Disable user interaction
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingController()
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false  // Disable user interaction
    }

    private func setupHostingController() {
        // Initialize the hosting controller with the SwiftUI view
        hostingController = UIHostingController(rootView: AccessoryView())
        hostingController?.view.backgroundColor = .clear
        hostingController?.view.isUserInteractionEnabled = false  // Disable user interaction
        
        if let hostingView = hostingController?.view {
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(hostingView)
            
            // Constrain the hosting view to the edges of the UIView
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}

#Preview {
    AccessoryView()
}
