//
//  AssessmentPresentation.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore
import Foundation
import SwiftUI

struct AssessmentPresentation {
  var isPresenting: Bool
  var assessment: Assessment? = nil
  
  static var none = AssessmentPresentation(isPresenting: false)
}
