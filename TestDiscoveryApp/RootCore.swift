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
  case dismissSheet
  case pickerAction(PickerAction)
}

public struct RootEnvironment {
  public init(queue: @escaping () -> AnySchedulerOf<DispatchQueue> = { .immediate }) {
    
    self.queue = queue
  }
  
  var queue: () -> AnySchedulerOf<DispatchQueue> = { .main }
}

// swiftlint:disable trailing_closure

//  .combine(
//  pickerReducer
//    .optional()
//    .pullback(
//      state: \RootState.pickerState,
//      action: /RootAction.picker(action:),
//      environment: { _ in PickerEnvironment() }
//    ),
//  Reducer



let rootReducer = Reducer<RootState, RootAction, RootEnvironment>
  .combine(
  pickerReducer
    .optional()
    .pullback(
      state: \RootState.pickerState,
      action: /RootAction.pickerAction,
      environment: { _ in PickerEnvironment() }
    ),
  Reducer
  { state, action, environment in
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
      state.pickerState = PickerState(pickType: .radio)
      return .none
      
    case .dismissSheet:
      state.pickerState = nil
      return .none

    case .pickerAction(.cancelButtonTapped):
      print("RootCore: .pickerAction: \(action)")
      return Effect(value: .dismissSheet)

    case .pickerAction(_):
      print("RootCore: .pickerAction: \(action)")
      return .none
    }
  }
  ).debug()
//    case .picker(action: .onAppear):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .onDisappear):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .testButtonTapped):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .testResultReceived(_)):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .connectButtonTapped):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .connectResultReceived(_)):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .packetsUpdate(_)):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .clientsUpdate(_)):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .packet(index: let index, action: let action)):
//      print("RootCore: .picker: \(action)")
//      return .none
//    }
//  }
//)
//  .debug()
// swiftlint:enable trailing_closure
