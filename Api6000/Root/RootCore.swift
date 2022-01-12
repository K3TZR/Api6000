//
//  RootCore.swift
//  TestDiscoveryApp/Root
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture

import ApiViewer
import LogViewer

import Shared
import XCGWrapper

public enum ViewType: Equatable {
  case api
  case log
}

public struct RootState: Equatable {
  public var apiState: ApiState? = ApiState()
  public var appName: String
  public var domain: String
  public var fontSize: CGFloat = 12
  public var logState: LogState?
  public var smartlinkEmail: String?
  public var viewType: ViewType = .api
  public var xcgWrapper = XCGWrapper()

  public init(
    domain: String,
    appName: String
  )
  {
    self.domain = domain
    self.appName = appName
  }
}

public enum RootAction: Equatable {
  // upstream actions
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

      // ----------------------------------------------------------------------------
      // MARK: - Log actions

    case .logAction(.backButton):
      state.apiState = ApiState()
      state.logState = nil
      state.viewType = .api
      return .none

    case .logAction(let .fontSize(value)):
      state.fontSize = value
      return .none

    case .logAction(_):
      // IGNORE ALL OTHERS
      return .none

      // ----------------------------------------------------------------------------
      // MARK: - Api actions

    case .apiAction(.logViewButton):
      state.logState = LogState(domain: state.domain, appName: state.appName, backName: "Api Viewer", fontSize: state.fontSize)
      state.apiState = nil
      state.viewType = .log
      return .none
    
    case let .apiAction(.fontSizeStepper(value)):
      state.fontSize = value
      return .none

    case .apiAction(_):
      // IGNORE ALL OTHERS
      return .none
    }
  }
)
//  .debug("ROOT ")
