//
//  AppDelegate.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 25/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit
import Parse


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        //Init with Parse back4App Backend
        let configuration = ParseClientConfiguration {
            $0.applicationId = parseServerAppID
            $0.clientKey = parseServerClientKey
            $0.server = parseServerURL
        }
        Parse.initialize(with: configuration)
        
        //Skip Login (custom)
        let currentUser = PFUser.current()
        print("appdelegate currentUser: \(currentUser)")
        if (currentUser != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "landingPageNavCon") as! UINavigationController
            self.window?.rootViewController = initialViewController
        }
        
        //Check if current user is anonymous
        isAuthenticatedUser = false
        userObjectID = ""
        if let test = currentUser?.isAuthenticated {
            if test {
                isAuthenticatedUser = true //set value in API
                if let userID = currentUser?.objectId {
                    userObjectID = userID
                    print("\(userObjectID) is authenticated: \(test)")
                    requestFavoriteLocationsForUser()
                    requestFavoriteEventsForUser()
                }
            }
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        /*
         check with the new time/date here
         I mean, when user enters app again, then check if the saved date is still good - when the app for instance is openend again in the morning after partying, so at like 10am there shouldn't be the events from the last day evening. dateToWorkWith and CalendarView and all the Tabs should be adjusted and updated
         
        */
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

