//
//  Previews.swift
//  inOSTests
//
//  Created by Aleph-WQ05D on 29/11/24.
//

import SwiftUI

#Preview {
  BenchmarkView()
}

#Preview {
  FunctionalityRow(item: .batteryStatus, isPassed: false)
    .frame(width: 200)
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
  DeadpixelFunctionalityView()
}

#Preview {
  ScreenFunctionalityView()
}