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
      widgetBody(context)
        .activityBackgroundTint(Color.black)
        .activitySystemActionForegroundColor(Color.blue)
      
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.bottom) {
          widgetBody(context)
        }
      } compactLeading: {
        Image(systemName: "wifi")
          .foregroundColor(.blue)
      } compactTrailing: {
        Text("\(context.state.benchmark)")
          .bold()
          .frame(width: 100)
      } minimal: {
        Image(systemName: "wifi")
          .foregroundColor(.blue)
      }
    }
  }
  
  @ViewBuilder
  func widgetBody(_ context: ActivityViewContext<InOSWidgetAttributes>) -> some View {
    HStack {
      Image(systemName: "wifi")
        .foregroundColor(.blue)
      Text("\(context.state.benchmark)")
        .font(.system(size: 20, weight: .heavy))
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
