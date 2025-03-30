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
    InOSWidget()
    InOSWidgetControl()
    InOSWidgetLiveActivity()
  }
}
