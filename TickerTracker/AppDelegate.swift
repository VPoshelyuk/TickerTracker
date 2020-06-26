//
//  AppDelegate.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTaks()
        return true
    }
    
    //MARK: Register BackGround Tasks
    private func registerBackgroundTaks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.viachaslaupashaliuk.apprefresh", using: nil) { task in
            //This task is cast with processing request (BGProcessingTask)
//            self.scheduleLocalNotification()
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
          NetworkManager.session.invalidateAndCancel()
        }
        let userDefaults = UserDefaults.standard
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            let userStonks = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: "watchedStocks")!) as! [userInfo]
            NetworkManager().fetchStocksData(userStonks)
//            NotificationCenter.default.post(name: .appRefreshed,
//            object: self,
//            userInfo: ["stonk": "stonk"])
        }
        task.setTaskCompleted(success: true)
        scheduleBackgroundUpdate()
    }
    
    func scheduleBackgroundUpdate() {
        let appRefresh = BGAppRefreshTaskRequest(identifier: "com.viachaslaupashaliuk.apprefresh")
        appRefresh.earliestBeginDate = Date(timeIntervalSinceNow: 10)
        do {
          try BGTaskScheduler.shared.submit(appRefresh)
        } catch {
          print("Unable to submit task: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
  static let appRefreshed = Notification.Name("com.andyibanez.apprefresh")
}
//
////MARK:- BGTask Helper
//extension AppDelegate {
//
//    func cancelAllPandingBGTask() {
//        BGTaskScheduler.shared.cancelAllTaskRequests()
//    }
//
//
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.SO.apprefresh")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 30) // App Refresh after 30 seconds.
//        //Note :: EarliestBeginDate should not be set to too far into the future.
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Could not schedule app refresh: \(error)")
//        }
//    }
//
//    func handleAppRefreshTask(task: BGAppRefreshTask) {
//        //Todo Work
//        /*
//         //AppRefresh Process
//         */
//        task.expirationHandler = {
//            //This Block call by System
//            //Canle your all tak's & queues
//        }
//        scheduleLocalNotification()
//        //
//        task.setTaskCompleted(success: true)
//    }
//}
//
////MARK:- Notification Helper
//extension AppDelegate {
//
//    func registerLocalNotification() {
//        let notificationCenter = UNUserNotificationCenter.current()
//        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
//
//        notificationCenter.requestAuthorization(options: options) {
//            (didAllow, error) in
//            if !didAllow {
//                print("User has declined notifications")
//            }
//        }
//    }
//
//    func scheduleLocalNotification() {
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.getNotificationSettings { (settings) in
//            if settings.authorizationStatus == .authorized {
//                self.fireNotification()
//            }
//        }
//    }
//
//    func fireNotification() {
//        // Create Notification Content
//        let notificationContent = UNMutableNotificationContent()
//
//        // Configure Notification Content
//        notificationContent.title = "Bg"
//        notificationContent.body = "BG Notifications."
//
//        // Add Trigger
//        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
//
//        // Create Notification Request
//        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
//
//        // Add Request to User Notification Center
//        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
//            if let error = error {
//                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
//            }
//        }
//    }
//
//}
