//
//  FormField.swift
//  
//
//  Created by Maxim Aliev on 29.01.2023.
//

import SwiftUI

public struct FormField<Value: Hashable, Rule: ValidationRule, Content: View>: View where Value == Rule.Value {
    @Binding private var value: Value
    @ViewBuilder private let content: () -> Content
    
    @Binding private var failedValidationRules: [Rule]
    
    // Fields Focus
    @FocusState private var isFocused: Bool
    @State private var id: String = UUID().uuidString
    @Environment(\.focusedFieldId) var currentFocusedFieldId
    private let isSubmitOverrided: Bool
    
    // ValidateInput
    private let validator: FieldValidator<Rule>
    @Environment(\.errorHideBehaviour) var errorHideBehaviour
    @Environment(\.validationBehaviour) var validationBehaviour
    
    public init(
        value: Binding<Value>,
        rules: [Rule] = [],
        failedValidationRules: Binding<[Rule]>,
        isSubmitOverrided: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._value = value
        self._failedValidationRules = failedValidationRules
        self.content = content
        self.isSubmitOverrided = isSubmitOverrided
        self.validator = FieldValidator(rules: rules)
    }
    
    public var body: some View {
        content()
        // Fields Focus
            .onChange(of: currentFocusedFieldId) { newValue in
                DispatchQueue.main.async {
                    isFocused = newValue.trimmingCharacters(in: .whitespaces) == id
                }
            }
            .preference(
                key: FieldStatesKey.self,
                value: [
                    // Замыкание для каждого филда вызывается FormValidator'ом из FormView для валидации по требованию
                    FieldState(id: id, isFocused: isFocused, isSubmitOverrided: isSubmitOverrided) {
                        let failedRules = validator.validate(value: value)
                        failedValidationRules = failedRules
                        
                        return failedRules.isEmpty
                    }
                ]
            )
            .focused($isFocused)
        
        // Fields Validation
            .onChange(of: value) { newValue in
                if errorHideBehaviour == .onValueChanged {
                    failedValidationRules = .empty
                }
                
                if validationBehaviour == .onFieldValueChanged {
                    failedValidationRules = validator.validate(value: newValue)
                }
            }
            .onChange(of: isFocused) { newValue in
                if errorHideBehaviour == .onFocusLost && newValue == false {
                    failedValidationRules = .empty
                } else if errorHideBehaviour == .onFocus && newValue == true {
                    failedValidationRules = .empty
                }
                
                if validationBehaviour == .onFieldFocusLost && newValue == false {
                    failedValidationRules = validator.validate(value: value)
                }
            }
    }
}
