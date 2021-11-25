//
//  RootCore.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture
import Dispatch
import Picker

public struct RootState: Equatable {
  public var isGui = true
  public var showTimes = false
  public var showPings = false
  public var showReplies = false
  public var showButtons = false
  public var showPicker = false
  public var pickerState: PickerState?
  
  public init() {}
}

public enum RootAction: Equatable {
  case isGuiClicked
  case showTimesClicked
  case showPingsClicked
  case showRepliesClicked
  case showButtonsClicked
  case startButtonClicked
  case pickerAction(PickerAction)
  case pickerClosed
}

public struct RootEnvironment {
  public init(queue: @escaping () -> AnySchedulerOf<DispatchQueue> = { .immediate }) {
    
    self.queue = queue
  }
  
  var queue: () -> AnySchedulerOf<DispatchQueue> = { .main }
}

// swiftlint:disable trailing_closure
let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  pickerReducer
    .optional()
    .pullback(
    state: \.pickerState,
    action: /RootAction.pickerAction,
    environment: { _ in PickerEnvironment() }
  ),
  Reducer { state, action, environment in
    switch action {
      
    case .isGuiClicked:
      state.isGui.toggle()
      return .none
      
    case .showTimesClicked:
      state.showTimes.toggle()
      return .none
      
    case .showPingsClicked:
      state.showPings.toggle()
      return .none
      
    case .showRepliesClicked:
      state.showReplies.toggle()
      return .none
      
    case .showButtonsClicked:
      state.showButtons.toggle()
      return .none
      
    case .startButtonClicked:
      state.showPicker = true
      return .none
      
      
    case .pickerClosed:
      return .none
    
    case let .pickerAction(action):
      print("PickerAction received: \(action)")
      state.showPicker = false
      return .none
    }
  }
)
  .debug()
// swiftlint:enable trailing_closure
