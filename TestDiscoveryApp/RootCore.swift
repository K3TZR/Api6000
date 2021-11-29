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
import Shared

public enum RootButton {
  case logView
  case startStop
  case gui
  case times
  case pings
  case replies
  case buttons
  case clearDefault
  case smartlink
  case status
  case clearNow
  case clearOnConnect
  case clearOnDisconnect
}

public struct RootState: Equatable {
  public var listener: Listener?
  public var isGui = true
  public var showTimes = false
  public var showPings = false
  public var showReplies = false
  public var showButtons = false
  public var showPicker = false
  public var pickerState: PickerState?
  public var connectedPacket: Packet? = nil
  public var defaultPacket: Packet? = nil
  public var clearNow = false
  public var clearOnConnect = false
  public var clearOnDisconnect = false
  
  public init() {}
}

public enum RootAction: Equatable {
  case onAppear
  
  case buttonTapped(RootButton)

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
let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
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
      
    case let .buttonTapped(button):
      switch button {
      case .logView:
        print("RootCore: logView button tapped")
      case .startStop:
        state.pickerState = PickerState(listener: environment.listener(), pickType: .radio)
        state.showPicker = true
      case .gui:
        state.isGui.toggle()
      case .times:
        state.showTimes.toggle()
      case .pings:
        state.showPings.toggle()
      case .replies:
        state.showReplies.toggle()
      case .buttons:
        state.showButtons.toggle()
      case .clearDefault:
        state.defaultPacket = nil
      case .smartlink:
        print("RootCore: smartlink button tapped")
      case .status:
        print("RootCore: status button tapped")
      case .clearOnConnect:
        state.clearOnConnect.toggle()
      case .clearOnDisconnect:
        state.clearOnDisconnect.toggle()
      case .clearNow:
        state.clearNow.toggle()
      }
      return .none
      
      
    case .sheetClosed:
      print("RootCore: .sheetClosed")
      state.pickerState = nil
      return .none
      
    case let .pickerAction(.defaultSelected(packet)):
      print("RootCore: .pickerAction: \(action)")
      state.defaultPacket = packet
      return .none
      
    case .pickerAction(.buttonTapped(.cancel)):
      print("RootCore: .pickerAction: \(action)")
      state.showPicker = false
      state.pickerState = nil
      return .none
      
    case let .pickerAction(.connectResultReceived(index)):
      print("RootCore: .picker: \(action), index = \(index == nil ? "none" : String(index!))")
      return .none
      
    case .pickerAction(.buttonTapped(.test)):
      print("RootCore: .picker: \(action)")
      return .none
      
    case .pickerAction(_):
      print("RootCore: .pickerAction: \(action)")
      return .none
    }
  }
)

//  .debug()
