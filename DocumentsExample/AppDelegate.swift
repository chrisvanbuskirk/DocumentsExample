//
//  AppDelegate.swift
//
//  Created by Chris Van Buskirk on 2/9/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // We are intercepting the new file menu item to show the template picker
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        // Remove the default New menu item
        builder.remove(menu: .newScene)
        
        // Add our custom New menu item
        let newCommand = UIKeyCommand(
            title: "New",
            action: #selector(newDocument(_:)),
            input: "N",
            modifierFlags: .command)
        
        let newMenu = UIMenu(
            title: "New",
            image: nil,
            identifier: UIMenu.Identifier("com.touchedmedia.documents"),
            options: [],
            children: [newCommand])
        
        builder.insertChild(newMenu, atStartOfMenu: .file)
    }

    @objc func newDocument(_ sender: Any) {
        // Request a new window scene
        let activity = NSUserActivity(activityType: "com.touchedmedia.documents")
        activity.userInfo = ["isNewDocument": true]
            
        UIApplication.shared.requestSceneSessionActivation(
            nil,
            userActivity: activity,
            options: nil
        ) { error in
            print("Failed to open new window: \(error)")
        }
    }
}

