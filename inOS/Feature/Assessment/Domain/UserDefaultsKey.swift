//
//  UserDefaultsKey.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import Foundation

extension String {
  static func persistence(key: PersistenceKey) -> String {
    return key.rawValue
  }
}

enum PersistenceKey: String {
  case passedAssessments
  case isDarkMode
}
