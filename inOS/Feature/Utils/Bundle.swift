//
//  Bundle.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI

extension Bundle {
  public var icon: UIImage? {
    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
       let lastIcon = iconFiles.last {
      return UIImage(named: lastIcon)
    }
    return nil
  }
}
