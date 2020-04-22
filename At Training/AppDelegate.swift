//
//  AppDelegate.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/8/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        print("The app is Launched")
        print("-------------Values from Last Saved From Safety Settings--------------------")
        print("\n")
        print("|             Min Pitch :        \(db.integer(forKey: K.minPitchSS))        ")
        print("|             Max Pitch :        \(db.integer(forKey: K.maxPitchSS))        ")
        print("|             Min Roll  :        \(db.integer(forKey: K.minRollSS))         ")
        print("|             Max Roll  :        \(db.integer(forKey: K.maxPitchSS))        ")
        print("|             Rate of D :        \(db.integer(forKey: K.rodSS))             ")
        print("|             Altitude  :        \(db.integer(forKey: K.altitudeSS))        ")
        
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
    


}

