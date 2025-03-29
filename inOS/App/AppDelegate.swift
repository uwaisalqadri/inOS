//
//  AppDelegate.swift
//  inOS
//
//  Created by Uwais Alqadri on 30/03/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
  var hostApp: UIApplication?

  var window: UIWindow?
  var orientationLock: UIInterfaceOrientationMask = .portrait

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    hostApp = application
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()

    return true
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return orientationLock
  }
}
