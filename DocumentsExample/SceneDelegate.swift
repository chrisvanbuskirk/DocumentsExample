//
//  SceneDelegate.swift
//
//  Created by Chris Van Buskirk on 2/9/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if this is a document window
        if let activity = connectionOptions.userActivities.first {
            if activity.userInfo?["isNewDocument"] as? Bool == true {
                // Handle new document
                let navigationController = UINavigationController(rootViewController: TemplatePickerViewController())
                window?.rootViewController = navigationController
            } else if let documentURL = activity.userInfo?["documentURL"] as? URL {
                // Handle existing document
                let document: UIDocument
                if documentURL.pathExtension == "exampletext" {
                    document = TextDocument(fileURL: documentURL)
                } else if documentURL.pathExtension == "sampledoc" {
                    document = RichDocument(fileURL: documentURL)
                } else {
                    return
                }
                
                let documentViewController = CustomDocumentViewController()
                documentViewController.document = document
                let navigationController = UINavigationController(rootViewController: documentViewController)
                window?.rootViewController = navigationController
            }
        } else {
            // This is the initial window
            let documentViewController = CustomDocumentViewController()
            let navigationController = UINavigationController(rootViewController: documentViewController)
            window?.rootViewController = navigationController
        }
        
        window?.makeKeyAndVisible()
    }
    
    // Open Recents
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        // Request a new window scene for the document
        let activity = NSUserActivity(activityType: "com.touchedmedia.documents")
        activity.userInfo = ["documentURL": url]
            
        UIApplication.shared.requestSceneSessionActivation(
            nil,
            userActivity: activity,
            options: nil
        ) { error in
            print("Failed to open window: \(error)")
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

