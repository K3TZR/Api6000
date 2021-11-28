//
//  RootCore.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture
import Dispatch
import Discovery
import Picker

public struct RootState: Equatable {
  public var listener: Listener?
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
  case onAppear
  case isGuiClicked
  case showTimesClicked
  case showPingsClicked
  case showRepliesClicked
  case showButtonsClicked
  case startButtonClicked
  case logViewButtonClicked
  case sheetClosed
  case pickerAction(PickerAction)
}

public struct RootEnvironment {
  public init(
    queue: @escaping () -> AnySchedulerOf<DispatchQueue> = { .main },
    listener: @escaping () -> Listener = { Listener() }
  )
  {
    self.queue = queue
    self.listener = listener
  }
  
  var queue: () -> AnySchedulerOf<DispatchQueue>
  var listener: () -> Listener
}

// swiftlint:disable trailing_closure
let rootReducer = Reducer<RootState, RootAction, RootEnvironment>
  .combine(
    pickerReducer
      .optional()
      .pullback(
        state: \RootState.pickerState,
        action: /RootAction.pickerAction,
        environment: { _ in PickerEnvironment() }
      ),
    Reducer { state, action, environment in
      switch action {
        
      case .onAppear:
        return .none
        
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
        state.pickerState = PickerState(listener: environment.listener(), pickType: .radio)
        state.showPicker = true
        return .none
        
      case .logViewButtonClicked:
        print("RootCore: .logViewButtonClicked")
        return .none
        
      case .sheetClosed:
        print("RootCore: .sheetClosed")
        state.pickerState = nil
        return .none
        
      case .pickerAction(.cancelButtonTapped):
        print("RootCore: .pickerAction: \(action)")
        state.showPicker = false
        state.pickerState = nil
        return .none
        
      case .pickerAction(.testButtonTapped):
        print("RootCore: .picker: \(action)")
        return .none
        
      case .pickerAction(_):
        print("RootCore: .pickerAction: \(action)")
        return .none
      }
    }
  )
//  .debug()

//    case .picker(action: .onAppear):
//      print("RootCore: .picker: \(action)")
//      return .none
//
//    case .picker(action: .onDisappear):
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
