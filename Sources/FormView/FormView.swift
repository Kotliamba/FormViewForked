//
//  FormView.swift
//  
//
//  Created by Maxim Aliev on 27.01.2023.
//

import SwiftUI

public enum ValidationBehaviour {
    case onFieldValueChanged
    case onFieldFocusLost
    case never
}

public enum ErrorHideBehaviour {
    case onValueChanged
    case onFocus
    case onFocusLost
}

public class FormStateHandler: ObservableObject {
    @Published var fieldStates: [FieldState]
    @Published var currentFocusedFieldId: String
    var formValidator: FormValidator
    
    public init() {
        self.fieldStates = .empty
        self.currentFocusedFieldId = .empty
        self.formValidator = FormValidator()
    }
    
    @discardableResult
    public func validate(focusOnFirstFailedField: Bool = false) -> Bool {
        formValidator.validate(focusOnFirstFailedField: focusOnFirstFailedField)
    }
    
    func updateFieldStates(newStates: [FieldState]) {
        fieldStates = newStates
        
        let focusedField = newStates.first { $0.isFocused }
        currentFocusedFieldId = focusedField?.id ?? .empty
       
        // Замыкание onValidateRun вызывается методом validate() FormValidator'a.
        formValidator.onValidateRun = { [weak self] focusOnFirstFailedField in
            guard let self else {
                return false
            }
            
            let resutls = newStates.map { $0.onValidate() }
           
            // Фокус на первом зафейленом филде.
            if let index = resutls.firstIndex(of: false), focusOnFirstFailedField {
                currentFocusedFieldId = fieldStates[index].id
            }
               
            return resutls.allSatisfy { $0 }
        }
    }
    
    func submit() {
        let isSubmitOverrided = fieldStates.first(where: { $0.isFocused })?.isSubmitOverrided == true
        
        if isSubmitOverrided == false {
            currentFocusedFieldId = FocusService.getNextFocusFieldId(
                states: fieldStates,
                currentFocusField: currentFocusedFieldId
            )
        }
    }
}

public struct FormView<Content: View>: View {
    @ObservedObject private var formStateHandler: FormStateHandler
    @ViewBuilder private let content: () -> Content
    
    private let errorHideBehaviour: ErrorHideBehaviour
    private let validationBehaviour: ValidationBehaviour
    
    public init(
        formStateHandler: FormStateHandler,
        validate: ValidationBehaviour = .never,
        hideError: ErrorHideBehaviour = .onValueChanged,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.formStateHandler = formStateHandler
        self.validationBehaviour = validate
        self.errorHideBehaviour = hideError
    }
    
    public var body: some View {
        return content()
            // [weak formStateHandler] необходимо для избежания захвата сильных ссылок между
            // замыканием и @StateObject
            .onPreferenceChange(FieldStatesKey.self) { [weak formStateHandler] newStates in
                formStateHandler?.updateFieldStates(newStates: newStates)
            }
            .onSubmit(of: .text) { [weak formStateHandler] in
                formStateHandler?.submit()
            }
            .environment(\.focusedFieldId, formStateHandler.currentFocusedFieldId)
            .environment(\.errorHideBehaviour, errorHideBehaviour)
            .environment(\.validationBehaviour, validationBehaviour)
    }
}
