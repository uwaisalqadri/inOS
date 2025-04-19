//
//  InOSWidgetBundle.swift
//  InOSWidget
//
//  Created by Uwais Alqadri on 30/03/25.
//

import WidgetKit
import SwiftUI

@main
struct InOSWidgetBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 17.0, *) {
      InOSWidget()
      InOSWidgetLiveActivity()
    }
    
    if #available(iOS 18.0, *) {
      InOSWidgetControl()
    }
  }
}
