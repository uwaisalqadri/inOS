//
//  TextFieldAlert.swift
//  inOS
//
//  Created by Aleph-WQ05D on 04/11/24.
//

import SwiftUI

extension View {
  public func textFieldAlert(
    isPresented: Binding<Bool>,
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    action: @escaping (String) -> Void
  ) -> some View {
    self.modifier(TextFieldAlert(isPresented: isPresented, title: title, text: text, placeholder: placeholder, action: action))
  }
}

struct TextFieldAlert: ViewModifier {
  @Binding var isPresented: Bool
  let title: String
  @Binding var text: String
  let placeholder: String
  let action: (String) -> Void

  func body(content: Content) -> some View {
    ZStack(alignment: .center) {
      content.disabled(isPresented)

      if isPresented {
        VStack {
          Text(title)
            .font(.headline)
            .padding()

          TextField(placeholder, text: $text)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .padding()

          Divider()

          HStack {
            Spacer()
            Button {
              withAnimation {
                isPresented.toggle()
              }
            } label: {
              Text("Cancel")
            }

            Spacer()
            Divider()
            Spacer()

            Button() {
              action(text)
              withAnimation {
                isPresented.toggle()
              }
            } label: {
              Text("Done")
            }
            Spacer()
          }
        }
        .background(Blur())
        .frame(width: 300, height: 200)
        .cornerRadius(20)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(lineWidth: 0.5)
            .foregroundColor(.init(.lightGray).opacity(0.5))
        )
      }
    }
    .animation(.easeInOut, value: isPresented)
    .onChange(of: isPresented) { _ in
      text = ""
    }
  }
}
