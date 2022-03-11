//
//  AppDelegate.swift
//  Firebase Chat
//
//  Created by Admin on 15/12/21.
//

import UIKit
import Firebase
import FirebaseMessaging
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    // alwan comment: core data
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {

                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // alwan comment: firebase & firestore
        FirebaseApp.configure()
        
        // alwan comment: push notification
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { success, error in
            if let error = error {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
            }
            else {
                guard success else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: Failed registering APNS registry")
                    return
                }
                
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - success registering APNS registry")
            }
        })
        
        application.registerForRemoteNotifications()
        
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

extension AppDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: fcmToken not found")
            return
        }
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        
        print("File: \(#file) - Function: \(#function) - Line: \(#line) - Received fcmToken: \(fcmToken)")
    }
    
    // alwan comment: push notification active in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("File: \(#file) - Function: \(#function) - Line: \(#line) - userNotificationCenter willPresent notification called")
        completionHandler([.alert, .sound])
    }
}
