//
//  ContentView.swift
//  Example
//
//  Created by Maxim Aliev on 28.01.2023.
//

import SwiftUI
import FormView

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        FormView(
            formStateHandler: viewModel.stateHandler,
            validate: .never,
            hideError: .onValueChanged
        ) { proxy in
            FormField(
                value: $viewModel.name,
                rules: [
                    TextValidationRule.noSpecialCharacters(message: "No spec chars"),
                    .notEmpty(message: "Name empty"),
                    .myRule
                ],
                failedValidationRules: .constant([TextValidationRule]())
            ) {
                TextInputField(title: "Name", text: $viewModel.name)
            }
            FormField(
                value: $viewModel.age,
                rules: [
                    TextValidationRule.digitsOnly(message: "Digits only"),
                    .maxLength(count: 2, message: "Max length 2")
                ],
                failedValidationRules: .constant([TextValidationRule]())
            ) {
                TextInputField(title: "Age", text: $viewModel.age)
            }
            FormField(
                value: $viewModel.pass,
                rules: [
                    TextValidationRule.atLeastOneDigit(message: "One digit"),
                    .atLeastOneLetter(message: "One letter"),
                    .notEmpty(message: "Pass not empty")
                ],
                failedValidationRules: .constant([TextValidationRule]())
            ) {
                SecureInputField(title: "Password", text: $viewModel.pass, failedRules: [])
            }
            FormField(
                value: $viewModel.confirmPass,
                rules: [
                    TextValidationRule.equalTo(value: viewModel.pass, message: "Not equal to pass"),
                    .notEmpty(message: "Confirm pass not empty")
                ],
                failedValidationRules: .constant([TextValidationRule]())
            ) {
                SecureInputField(title: "Confirm Password", text: $viewModel.confirmPass, failedRules: [])
            }
            Button("Validate") {
                print("Form is valid: \(proxy.validate())")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 40)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            Color(red: 245 / 255.0, green: 246 / 255.0, blue: 250 / 255.0)
                .ignoresSafeArea()
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(coordinator: ContentCoordinator()))
    }
}
