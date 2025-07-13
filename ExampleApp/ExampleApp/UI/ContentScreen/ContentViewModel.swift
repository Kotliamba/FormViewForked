//
//  ContentViewModel.swift
//  Example
//
//  Created by Nikolai Timonin on 28.07.2023.
//

import SwiftUI
import FormView

class ContentViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var pass: String = ""
    @Published var confirmPass: String = ""
    
    let stateHandler: FormStateHandler = FormStateHandler()
    
    private let coordinator: ContentCoordinator
    
    init(coordinator: ContentCoordinator) {
        self.coordinator = coordinator
        print("init ContentViewModel")
    }
    
    private func validate() {
        stateHandler.validate()
    }
    
    deinit {
        print("deinit ContentViewModel")
    }
}
