//
//  SecureInputView.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 19/10/2023.
//

import SwiftUI

struct SecureInputView: View {
    
    @Binding private var text: String
    @Binding private var disabled: Bool
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>, disabled: Binding<Bool>) {
        self.title = title
        self._text = text
        self._disabled = disabled
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                        .disabled(!disabled)
                } else {
                    TextField(title, text: $text)
                        .disabled(!disabled)
                }
            }.padding(.trailing, 50)

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
