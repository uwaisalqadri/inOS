//
//  InOSWidgetLiveActivity.swift
//  InOSWidget
//
//  Created by Uwais Alqadri on 30/03/25.
//

import ActivityKit
import WidgetKit
import SwiftUI
import inCore

struct InOSWidgetLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: InOSWidgetAttributes.self) { context in
      // Lock screen/banner UI goes here
      VStack {
        Text("Hell")
      }
      .activityBackgroundTint(Color.cyan)
      .activitySystemActionForegroundColor(Color.black)
      
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text("Leading")
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text("Trailing")
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("Bottom")
        }
      } compactLeading: {
        Text(" 80.30 Mbps")
          .bold()
        
      } compactTrailing: {
        Image(systemName: "wifi")
          .foregroundColor(.blue)
        
      } minimal: {
        Image(systemName: "wifi")
          .foregroundColor(.blue)
        
      }
      .widgetURL(URL(string: "http://www.apple.com"))
      .keylineTint(Color.red)
    }
  }
}

extension InOSWidgetAttributes {
  fileprivate static var preview: InOSWidgetAttributes {
    InOSWidgetAttributes(name: "Benchmark")
  }
}

extension InOSWidgetAttributes.ContentState {
  fileprivate static var smiley: InOSWidgetAttributes.ContentState {
    InOSWidgetAttributes.ContentState(benchmark: "Benchmark")
  }
  
  fileprivate static var starEyes: InOSWidgetAttributes.ContentState {
    InOSWidgetAttributes.ContentState(benchmark: "Benchmark")
  }
}

#Preview("Notification", as: .dynamicIsland(.compact), using: InOSWidgetAttributes.preview) {
  InOSWidgetLiveActivity()
} contentStates: {
  InOSWidgetAttributes.ContentState.smiley
  InOSWidgetAttributes.ContentState.starEyes
}
