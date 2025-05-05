//
//  Previews.swift
//  inOSTests
//
//  Created by Uwais Alqadri on 29/11/24.
//

import SwiftUI
import inCore

#Preview {
  MetricView()
}

#Preview {
  IntroductionView { }
}

#Preview {
  Text("TIME")
    .textFieldAlert(
      isPresented: .constant(true),
      title: "How many times?",
      text: .constant("8"),
      placeholder: "Enter your number",
      onSubmit: { string in
        print(string)
      },
      onRepeat: {
        print("retry")
      }
    )
}

#Preview {
  DeadpixelAssessmentView()
}

#Preview {
  ScreenAssessmentView()
}
