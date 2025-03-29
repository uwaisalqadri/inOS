//
//  AppUtility.swift
//  inOS
//
//  Created by Uwais Alqadri on 30/03/25.
//

import SwiftUI

struct AppUtility {
  
  static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation = .portrait) {
    if let delegate = UIApplication.shared.delegate as? AppDelegate {
      delegate.orientationLock = orientation
      UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
      UINavigationController.attemptRotationToDeviceOrientation()
    }
  }
  
}
