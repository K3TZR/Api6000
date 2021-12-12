//
//  RootCore.swift
//  TestDiscoveryApp/Root
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture
import Dispatch

import ApiViewer
import LogViewer
import Shared

public enum ViewType: Equatable {
  case api
  case log
}

// TODO: Where to get smartlinkEmail ???

public struct RootState: Equatable {
  public var viewType: ViewType = .api
  public var logState: LogState?
  public var apiState: ApiState? = ApiState(fontSize: 12, smartlinkEmail: "douglas.adams@me.com")
  public var fontSize: CGFloat = 12

  public init() {}
}

public enum RootAction: Equatable {
  case apiAction(ApiAction)
  case logAction(LogAction)
}

public struct RootEnvironment {
  public init(
    queue: @escaping () -> AnySchedulerOf<DispatchQueue> = { .main }
  )
  {
    self.queue = queue
  }
  
  var queue: () -> AnySchedulerOf<DispatchQueue>
}

// swiftlint:disable trailing_closure
let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
  apiReducer
    .optional()
    .pullback(
      state: \RootState.apiState,
      action: /RootAction.apiAction,
      environment: { _ in ApiEnvironment() }
    ),
  logReducer
    .optional()
    .pullback(
      state: \RootState.logState,
      action: /RootAction.logAction,
      environment: { _ in LogEnvironment() }
    ),
  Reducer { state, action, environment in
    switch action {
    
      // Log actions
    case .logAction(.buttonTapped(.apiView)):
      state.apiState = ApiState(fontSize: state.fontSize, smartlinkEmail: "douglas.adams@me.com")
      state.logState = nil
      state.viewType = .api
      return .none

    case .logAction(let .fontSizeChanged(value)):
      state.fontSize = value
      return .none

    case let .logAction(value):
      // IGNORE ALL OTHERS
      return .none

      // Api actions
    case .apiAction(.buttonTapped(.logView)):
      state.logState = LogState(fontSize: state.fontSize)
      state.apiState = nil
      state.viewType = .log
      return .none
    
    case .apiAction(let .fontSizeChanged(value)):
      state.fontSize = value
      return .none

    case let .apiAction(value):
      // IGNORE ALL OTHERS
      return .none
    }
  }
)
  .debug("ROOT ")
