//
//  ApiCore.swift
//  Api6000
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture
import SwiftUI

import ClientFeature
import Listener
import LoginFeature
import LogFeature
import FlexApi
import OpusPlayer
import PickerFeature
import Shared
import XCGWrapper

// ----------------------------------------------------------------------------
// MARK: - Global Functions

/// Read a user default entry and transform it into a struct
/// - Parameters:
///    - key:         the name of the default
/// - Returns:        a struct or nil
public func getDefaultValue<T: Decodable>(_ key: String) -> T? {
  
  if let data = UserDefaults.standard.object(forKey: key) as? Data {
    let decoder = JSONDecoder()
    if let value = try? decoder.decode(T.self, from: data) {
      return value
    } else {
      return nil
    }
  }
  return nil
}

/// Write a user default entry for a struct
/// - Parameters:
///    - key:        the name of the default
///    - value:      a struct  to be encoded and written to user defaults
public func setDefaultValue<T: Encodable>(_ key: String, _ value: T?) {
  
  if value == nil {
    UserDefaults.standard.removeObject(forKey: key)
  } else {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(value) {
      UserDefaults.standard.set(encoded, forKey: key)
    } else {
      UserDefaults.standard.removeObject(forKey: key)
    }
  }
}

public struct ApiModule: ReducerProtocol {
  // ----------------------------------------------------------------------------
  // MARK: - Dependency decalarations

  @Environment(\.openWindow) var openWindow
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.listener) var listener
  @Dependency(\.messagesModel) var messagesModel
  //  @Dependency(\.opusPlayer) var opusPlayer
  @Dependency(\.streamModel) var streamModel
  
  // ----------------------------------------------------------------------------
  // MARK: - Module Initialization

  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - State
  
  public struct State: Equatable {
    // State held in User Defaults
    var alertOnError: Bool { didSet { UserDefaults.standard.set(alertOnError, forKey: "alertOnError") } }
    var clearOnSend: Bool { didSet { UserDefaults.standard.set(clearOnSend, forKey: "clearOnSend") } }
    var clearOnStart: Bool { didSet { UserDefaults.standard.set(clearOnStart, forKey: "clearOnStart") } }
    var clearOnStop: Bool { didSet { UserDefaults.standard.set(clearOnStop, forKey: "clearOnStop") } }
    var guiDefault: DefaultValue? { didSet { setDefaultValue("guiDefault", guiDefault) } }
    var fontSize: CGFloat { didSet { UserDefaults.standard.set(fontSize, forKey: "fontSize") } }
    var isGui: Bool { didSet { UserDefaults.standard.set(isGui, forKey: "isGui") } }
    var localEnabled: Bool { didSet { UserDefaults.standard.set(localEnabled, forKey: "localEnabled") } }
    var messageFilter: MessageFilter { didSet { UserDefaults.standard.set(messageFilter.rawValue, forKey: "messageFilter") } }
    var messageFilterText: String { didSet { UserDefaults.standard.set(messageFilterText, forKey: "messageFilterText") } }
    var nonGuiDefault: DefaultValue? { didSet { setDefaultValue("nonGuiDefault", nonGuiDefault) } }
    var objectFilter: ObjectFilter { didSet { UserDefaults.standard.set(objectFilter.rawValue, forKey: "objectFilter") } }
    var openLeftWindow: Bool { didSet { UserDefaults.standard.set(openLeftWindow, forKey: "openLeftWindow") } }
    var openLogWindow: Bool { didSet { UserDefaults.standard.set(openLogWindow, forKey: "openLogWindow") } }
    var openRightWindow: Bool { didSet { UserDefaults.standard.set(openRightWindow, forKey: "openRightWindow") } }
    var reverse: Bool { didSet { UserDefaults.standard.set(reverse, forKey: "reverse") } }
    var rxAudio: Bool { didSet { UserDefaults.standard.set(rxAudio, forKey: "rxAudio") } }
    var showLeftButtons: Bool { didSet { UserDefaults.standard.set(showLeftButtons, forKey: "showLeftButtons") } }
    var showPings: Bool { didSet { UserDefaults.standard.set(showPings, forKey: "showPings") } }
    var showTimes: Bool { didSet { UserDefaults.standard.set(showTimes, forKey: "showTimes") } }
    var smartlinkEnabled: Bool { didSet { UserDefaults.standard.set(smartlinkEnabled, forKey: "smartlinkEnabled") } }
    var smartlinkEmail: String { didSet { UserDefaults.standard.set(smartlinkEmail, forKey: "smartlinkEmail") } }
    var txAudio: Bool { didSet { UserDefaults.standard.set(txAudio, forKey: "txAudio") } }
    var useDefault: Bool { didSet { UserDefaults.standard.set(useDefault, forKey: "useDefault") } }
    
    // other state
    var commandToSend = ""
    var isClosing = false
    var loginRequired = false
    var forceUpdate = false
    var gotoLast = false
    var initialized = false
    var isConnected = false
    var opusPlayer: OpusPlayer? = nil
    var pickables = IdentifiedArrayOf<Pickable>()
    var station: String? = nil
    
    // subview state
    var alertState: AlertState<ApiModule.Action>?
    var clientState: ClientFeature.State?
    var loginState: LoginFeature.State? = nil
    var pickerState: PickerFeature.State? = nil
    
    var previousCommand = ""
    var commandsIndex = 0
    var commandsArray = [""]
        
    // ----------------------------------------------------------------------------
    // MARK: - State Initialization

    public init(
      alertOnError: Bool = UserDefaults.standard.bool(forKey: "alertOnError"),
      clearOnSend: Bool  = UserDefaults.standard.bool(forKey: "clearOnSend"),
      clearOnStart: Bool = UserDefaults.standard.bool(forKey: "clearOnStart"),
      clearOnStop: Bool  = UserDefaults.standard.bool(forKey: "clearOnStop"),
      fontSize: CGFloat = UserDefaults.standard.double(forKey: "fontSize") == 0 ? 12 : UserDefaults.standard.double(forKey: "fontSize"),
      guiDefault: DefaultValue? = getDefaultValue("guiDefault"),
      isGui: Bool = UserDefaults.standard.bool(forKey: "isGui"),
      localEnabled: Bool = UserDefaults.standard.bool(forKey: "localEnabled"),
      messageFilter: MessageFilter = MessageFilter(rawValue: UserDefaults.standard.string(forKey: "messageFilter") ?? "all") ?? .all,
      messageFilterText: String = UserDefaults.standard.string(forKey: "messageFilterText") ?? "",
      nonGuiDefault: DefaultValue? = getDefaultValue("nonGuiDefault"),
      objectFilter: ObjectFilter = ObjectFilter(rawValue: UserDefaults.standard.string(forKey: "objectFilter") ?? "core") ?? .core,
      openLeftWindow: Bool = UserDefaults.standard.bool(forKey: "openLeftWindow"),
      openLogWindow: Bool = UserDefaults.standard.bool(forKey: "openLogWindow"),
      openRightWindow: Bool = UserDefaults.standard.bool(forKey: "openRightWindow"),
      reverse: Bool = UserDefaults.standard.bool(forKey: "reverse"),
      rxAudio: Bool  = UserDefaults.standard.bool(forKey: "rxAudio"),
      showLeftButtons: Bool = UserDefaults.standard.bool(forKey: "showLeftButtons"),
      showPings: Bool = UserDefaults.standard.bool(forKey: "showPings"),
      showTimes: Bool = UserDefaults.standard.bool(forKey: "showTimes"),
      smartlinkEnabled: Bool = UserDefaults.standard.bool(forKey: "smartlinkEnabled"),
      smartlinkEmail: String = UserDefaults.standard.string(forKey: "smartlinkEmail") ?? "",
      txAudio: Bool  = UserDefaults.standard.bool(forKey: "txAudio"),
      useDefault: Bool = UserDefaults.standard.bool(forKey: "useDefault")
    )
    {
      self.alertOnError = alertOnError
      self.clearOnStart = clearOnStart
      self.clearOnStop = clearOnStop
      self.clearOnSend = clearOnSend
      self.guiDefault = guiDefault
      self.fontSize = fontSize
      self.isGui = isGui
      self.localEnabled = localEnabled
      self.messageFilter = messageFilter
      self.messageFilterText = messageFilterText
      self.nonGuiDefault = nonGuiDefault
      self.objectFilter = objectFilter
      self.openLeftWindow = openLeftWindow
      self.openLogWindow = openLogWindow
      self.openRightWindow = openRightWindow
      self.reverse = reverse
      self.rxAudio = rxAudio
      self.showLeftButtons = showLeftButtons
      self.showPings = showPings
      self.showTimes = showTimes
      self.smartlinkEnabled = smartlinkEnabled
      self.smartlinkEmail = smartlinkEmail
      self.txAudio = txAudio
      self.useDefault = useDefault
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Actions
  
  public enum Action: Equatable {
    // initialization
    case onAppear
    
    // UI controls
    case commandClear
    case commandNext
    case commandPrevious
    case commandSend
    case commandText(String)
    case connectionStartStop
    case fontSize(CGFloat)
    case messagesClear
    case messagesFilter(MessageFilter)
    case messagesFilterText(String)
    case messagesSave
    case objectsFilter(ObjectFilter)
    case stateSet(WritableKeyPath<ApiModule.State, Bool>, Bool)
    case stateToggle(WritableKeyPath<ApiModule.State, Bool>)
    
    // Subview related
    case alertDismissed
    case client(ClientFeature.Action)
    case login(LoginFeature.Action)
    case picker(PickerFeature.Action)
    
    // Effects related
    case connect(Pickable, UInt32?)
    case connectionStatus(Bool)
    case loginStatus(Bool, String)
    
    // Sheet related
    case showClientSheet(Pickable, [String], [UInt32])
    case showErrorAlert(ConnectionError)
    case showLogAlert(LogEntry)
    case showLoginSheet
    case showPickerSheet
    
    // Subscription related
    case clientEvent(ClientEvent)
    case testResult(TestResult)
    
    // Window related
    case closeAllWindows
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Reducer
  
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      // Parent logic
      switch action {
        // ----------------------------------------------------------------------------
        // MARK: - Actions: ApiView Initialization
        
      case .onAppear:
        return initialization(&state, listener)
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: ApiView UI controls
        
      case .closeAllWindows:
        state.isClosing = true
        // close all of the app's windows
        for window in NSApp.windows {
          window.close()
        }
        return .none
        
      case .commandClear:
        state.commandToSend = ""
        state.commandsIndex = 0
        return .none
        
      case .commandNext:
        if state.commandsIndex == state.commandsArray.count - 1{
          state.commandsIndex = 0
        } else {
          state.commandsIndex += 1
        }
        state.commandToSend = state.commandsArray[state.commandsIndex]
        return .none
        
      case .commandPrevious:
        if state.commandsIndex == 0 {
          state.commandsIndex = state.commandsArray.count - 1
        } else {
          state.commandsIndex -= 1
        }
        state.commandToSend = state.commandsArray[state.commandsIndex]
        return .none
        
      case .commandSend:
        return sendCommand(&state, apiModel)
        
      case let .commandText(text):
        state.commandToSend = text
        return .none
        
      case .connectionStartStop:
        if state.isConnected {
          return stopTester(&state, apiModel, objectModel, streamModel)
        } else {
          return startTester(&state, objectModel, streamModel, listener)
        }
        
      case let .fontSize(size):
        state.fontSize = size
        return .none
        
      case .messagesClear:
        return .fireAndForget { await messagesModel.clearAll() }
        
      case let .messagesFilter(filter):
        state.messageFilter = filter
        return .fireAndForget { [state] in
          await messagesModel.setFilter(state.messageFilter, state.messageFilterText)
        }
        
      case let .messagesFilterText(text):
        state.messageFilterText = text
        return .fireAndForget { [state] in
          await messagesModel.setFilter(state.messageFilter, state.messageFilterText)
        }
        
      case .messagesSave:
        
        // FIXME: temporary test code
        
        //        var cmd = "spot add callsign=K3TZR" + " rx_freq=14.250"
        //        cmd += " tx_freq=14.255"
        //        cmd += " mode=SSB"
        //        cmd += " source=N1MM-[StationName]"
        //        cmd += " spotter_callsign=W6OP"
        //        cmd += " timestamp=\(Int(Date().timeIntervalSince1970))"
        //        cmd += " lifetime_seconds=300"
        //        cmd += " comment=spot comment"
        //        cmd += " priority=5"
        //        cmd += " trigger_action=none"
        //        apiModel.sendTcp(cmd)
        //
        //        return .none
        
        return saveMessagesToFile(messagesModel)
        
      case let .objectsFilter(newFilter):
        state.objectFilter = newFilter
        return .none
        
      case let .stateSet(keyPath, boolValue):
        state[keyPath: keyPath] = boolValue
        return .none
        
      case let .stateToggle(keyPath):
        state[keyPath: keyPath].toggle()
        switch keyPath {
        case \.smartlinkEnabled, \.localEnabled, \.loginRequired:
          return initializeMode(state, listener)
        case \.showPings:
          return .fireAndForget { [state] in
            await messagesModel.setShowPings(state.showPings)
          }
        case \.rxAudio:
          if state.isConnected {
            // CONNECTED, start / stop RxAudio
            if state.rxAudio {
              return startRxAudio(&state, apiModel, streamModel)
            } else {
              return stopRxAudio(&state, objectModel, streamModel)
            }
          } else {
            // NOT CONNECTED
            return .none
          }
          
        case \.txAudio:
          if state.isConnected {
            // CONNECTED, start / stop TxAudio
            if state.txAudio {
              return startTxAudio(&state, objectModel, streamModel)
            } else {
              return stopTxAudio(&state, objectModel, streamModel)
            }
          } else {
            // NOT CONNECTED
            return .none
          }
          
        default:
          return .none
        }
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: invoked by other actions
        
      case let .connect(selection, disconnectHandle):
        state.clientState = nil
        return connectionAttempt(state, selection, disconnectHandle, messagesModel, apiModel)
        
      case let .connectionStatus(connected):
        state.isConnected = connected
        if state.isConnected && state.isGui && state.rxAudio {
          // Start RxAudio
          return startRxAudio(&state, apiModel, streamModel)
        }
        return .none
        
      case let .loginStatus(success, user):
        // a smartlink login was completed
        if success {
          // save the User
          state.smartlinkEmail = user
          state.loginRequired = false
        } else {
          // tell the user it failed
          state.alertState = AlertState(title: TextState("Smartlink login failed for \(user)"))
        }
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: to display a sheet
        
      case let .showClientSheet(selection, stations, handles):
        state.clientState = ClientFeature.State(selection: selection, stations: stations, handles: handles)
        return .none
        
      case let .showErrorAlert(error):
        state.alertState = AlertState(title: TextState("An Error occurred"), message: TextState(error.rawValue))
        return .none
        
      case .showLoginSheet:
        state.loginState = LoginFeature.State(heading: "Smartlink Login Required", user: state.smartlinkEmail)
        return .none
        
      case .showPickerSheet:
        state.pickerState = PickerFeature.State(defaultValue: state.isGui ? state.guiDefault : state.nonGuiDefault, isGui: state.isGui)
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: invoked by subscriptions
        
      case let .clientEvent(event):
        return clientEvent(state, event, apiModel, objectModel)
        
      case let .showLogAlert(logEntry):
        return showLogAlert(&state,logEntry)
        
      case let .testResult(result):
        // a test result has been received
        state.pickerState?.testResult = result.success
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Login Actions (LoginFeature -> ApiView)
        
      case .login(.cancelButton):
        state.loginState = nil
        state.loginRequired = false
        return .none
        
      case let .login(.loginButton(user, pwd)):
        state.loginState = nil
        // try a Smartlink login
        return .run { send in
          let success = await listener.startWan(user, pwd)
          if success {
            //            let secureStore = SecureStore(service: "Api6000Tester-C")
            //            _ = secureStore.set(account: "user", data: user)
            //            _ = secureStore.set(account: "pwd", data: pwd)
          }
          await send(.loginStatus(success, user))
        }
        
      case .login(_):
        // IGNORE ALL OTHER login actions
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Picker Actions (PickerFeature -> ApiView)
        
      case .picker(.cancelButton):
        state.pickerState = nil
        return .none
        
      case let .picker(.connectButton(selection)):
        // close the Picker sheet
        state.pickerState = nil
        // save the station (if any)
        state.station = selection.station
        // check for other connections
        return .task { [state] in
          await checkConnectionStatus(state.isGui, selection)
        }
        
      case let .picker(.defaultButton(selection)):
        return updateDefault(&state, selection)
        
      case let .picker(.testButton(selection)):
        state.pickerState?.testResult = false
        // send a Test request
        return .fireAndForget {
          await listener.sendWanTest(selection.packet.serial)
        }
        
      case .picker(_):
        // IGNORE ALL OTHER picker actions
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Client Actions (ClientFeature -> ApiView)
        
      case .client(.cancelButton):
        state.clientState = nil
        return .none
        
      case let .client(.connect(selection, disconnectHandle)):
        state.clientState = nil
        return .task { .connect(selection, disconnectHandle) }
        
        // ----------------------------------------------------------------------------
        // MARK: - Alert Actions
        
      case .alertDismissed:
        state.alertState = nil
        return .none
      }
    }
    // ClientFeature logic
    .ifLet(\.clientState, action: /Action.client) {
      ClientFeature()
    }
    // LoginFeature logic
    .ifLet(\.loginState, action: /Action.login) {
      LoginFeature()
    }
    // PickerFeature logic
    .ifLet(\.pickerState, action: /Action.picker) {
      PickerFeature()
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Private Effect methods

//private func closeWindow(_ id: String) {
//  for window in NSApp.windows where window.identifier?.rawValue == id {
//    log("Api6000: \(window.identifier!.rawValue) window closed", .debug, #function, #file, #line)
//    window.close()
//  }
//}

private func checkConnectionStatus(_ isGui: Bool, _ selection: Pickable) async -> ApiModule.Action {
  // Gui connection with othe stations?
  if isGui && selection.packet.guiClients.count > 0 {
    // YES, may need a disconnect
    var stations = [String]()
    var handles = [UInt32]()
    for client in selection.packet.guiClients {
      stations.append(client.station)
      handles.append(client.handle)
    }
    // show the client chooser, let the user choose
    return .showClientSheet(selection, stations, handles)
  }
  else {
    // not Gui connection or Gui without other stations, attempt to connect
    return .connect(selection, nil)
  }
}

private func clearMessages(_ clear: Bool) ->  EffectTask<ApiModule.Action> {
//  if clear { return .run { send in await send(.clearNowButton) } }
  if clear { return .send(.messagesClear) }
  return .none
}

private func clientEvent(_ state: ApiModule.State, _ event: ClientEvent, _ apiModel: ApiModel, _ objectModel: ObjectModel) ->  EffectTask<ApiModule.Action> {
  // a GuiClient change occurred
  switch event.action {
  case .added:
    return .none
    
  case .removed:
    return .fireAndForget { [state] in
      // if nonGui, is it our connected Station?
      if state.isGui == false && event.client.station == state.station {
        // YES, unbind
        await objectModel.setActiveStation( nil )
        apiModel.bindToGuiClient(nil)
      }
    }
    
  case .completed:
    return .fireAndForget { [state] in
      // if nonGui, is there a clientId for our connected Station?
      if state.isGui == false && event.client.station == state.station {
        // YES, bind to it
        await objectModel.setActiveStation( event.client.station )
        apiModel.bindToGuiClient(event.client.clientId)
      }
    }
  }
}

private func connectionAttempt(_ state: ApiModule.State, _ selection: Pickable, _ disconnectHandle: UInt32?, _ messagesModel: MessagesModel, _ apiModel: ApiModel) ->  EffectTask<ApiModule.Action> {
  
  return .run { [state] send in
    await messagesModel.start(state.messageFilter, state.messageFilterText)
    // attempt to connect to the selected Radio / Station
    do {
      // try to connect
      try await apiModel.connectTo(selection: selection,
                                   isGui: state.isGui,
                                   disconnectHandle: disconnectHandle,
                                   station: "Tester",
                                   program: "Api6000Tester")
      await send(.connectionStatus(true))
    } catch {
      // connection attempt failed
      await send(.showErrorAlert( error as! ConnectionError ))
      await send(.connectionStatus(false))
    }
  }
}

private func disconnect(_ apiModel: ApiModel) ->  EffectTask<ApiModule.Action> {
  return .run { _ in apiModel.disconnect() }
}

private func initialization(_ state: inout ApiModule.State, _ listener: Listener) ->  EffectTask<ApiModule.Action> {
  // if the first time, start various effects
  if state.initialized == false {
    state.initialized = true
    // instantiate the Logger,
    _ = XCGWrapper(logLevel: .debug)

    if !state.localEnabled && !state.smartlinkEnabled {
      state.alertState = AlertState(title: TextState("select LOCAL and/or SMARTLINK"))
    }

    // start subscriptions
    return .merge(
      subscribeToClients(listener),
      subscribeToLogAlerts(),
      initializeMode(state, listener)
    )
  }
  return .none
}

func initializeMode(_ state: ApiModule.State, _ listener: Listener) ->  EffectTask<ApiModule.Action> {
  // start / stop listeners as appropriate for the Mode
  return .run { [state] send in
    // set the connection mode, start the Lan and/or Wan listener
    if await listener.setConnectionMode(state.localEnabled, state.smartlinkEnabled, state.smartlinkEmail) {
      if state.loginRequired && state.smartlinkEnabled {
        // Smartlink login is required
        await send(.showLoginSheet)
      }
    } else {
      // Wan listener was required and failed to start
      await send(.showLoginSheet)
    }
  }
}

private func pickerSheet(_ isGui: Bool) ->  EffectTask<ApiModule.Action> {
  return .run {send in await send(.showPickerSheet) }
}

private func resetClientInitialized(_ apiModel: ApiModel) ->  EffectTask<ApiModule.Action> {
  return .fireAndForget { apiModel.resetClientInitialized() }
}

private func saveMessagesToFile(_ messagesModel: MessagesModel) ->  EffectTask<ApiModule.Action> {
  let savePanel = NSSavePanel()
  savePanel.nameFieldStringValue = "Api6000Tester-C.messages"
  savePanel.canCreateDirectories = true
  savePanel.isExtensionHidden = false
  savePanel.allowsOtherFileTypes = false
  savePanel.title = "Save the Log"
  
  let response = savePanel.runModal()
  if response == .OK {
    return .fireAndForget {
      let formatter = NumberFormatter()
      formatter.minimumFractionDigits = 6
      formatter.positiveFormat = " * ##0.000000"
      
      let textArray = await messagesModel.filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
      let fileTextArray = textArray.joined(separator: "\n")
      try? await fileTextArray.write(to: savePanel.url!, atomically: true, encoding: .utf8)
    }
  } else {
    return .none
  }
}

private func sendCommand(_ state: inout ApiModule.State, _ apiModel: ApiModel) ->  EffectTask<ApiModule.Action> {
  // update the command history
  if state.commandToSend != state.previousCommand { state.commandsArray.append(state.commandToSend) }
  state.previousCommand = state.commandToSend
  state.commandsIndex = state.commandsIndex + 1
  
  if state.clearOnSend {
    state.commandToSend = ""
    state.commandsIndex = 0
  }
  return .fireAndForget { [state] in
    apiModel.sendTcp(state.commandToSend)
  }
}

private func setConnectionStatus(_ state: inout ApiModule.State, _ status: Bool) ->  EffectTask<ApiModule.Action> {
  state.isConnected = status
  return .none
}

private func showLogAlert(_ state: inout ApiModule.State, _ logEntry: LogEntry) ->  EffectTask<ApiModule.Action> {
  if state.alertOnError {
    // a Warning or Error has been logged, exit any sheet states
    state.clientState = nil
    state.loginState = nil
    state.pickerState = nil
    // alert the user
    state.alertState = .init(title: TextState("\(logEntry.level == .warning ? "A Warning" : "An Error") was logged:"),
                             message: TextState(logEntry.msg))
  }
  return .none
}

private func startRxAudio(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel) ->  EffectTask<ApiModule.Action> {
  if state.opusPlayer == nil {
    // ----- START Rx AUDIO -----
    state.opusPlayer = OpusPlayer()
    // start audio
    return .fireAndForget { [state] in
      // request a stream
      if let id = try await apiModel.requestRemoteRxAudioStream().streamId {
        // finish audio setup
        state.opusPlayer?.start(id: id)
        streamModel.remoteRxAudioStreams[id: id]?.delegate = state.opusPlayer
      }
    }
  }
  return .none
}

private func stopRxAudio(_ state: inout ApiModule.State, _ objectModel: ObjectModel, _ streamModel: StreamModel) ->  EffectTask<ApiModule.Action> {
  if state.opusPlayer != nil {
    // ----- STOP Rx AUDIO -----
    state.opusPlayer!.stop()
    let id = state.opusPlayer!.id
    state.opusPlayer = nil
    return .run { _ in 
      await streamModel.sendRemoveStream(id)
    }
  }
  return .none
}

private func startTester(_ state: inout ApiModule.State, _ objectModel: ObjectModel, _ streamModel: StreamModel, _ listener: Listener) ->  EffectTask<ApiModule.Action> {
  // ----- START -----
  // use the default?
  if state.useDefault {
    // YES, use the Default
    return .run { [state] send in
      if let packet = await listener.findPacket(for: state.guiDefault, state.nonGuiDefault, state.isGui) {
        // valid default
        let pickable = Pickable(packet: packet, station: state.isGui ? "" : state.nonGuiDefault?.station ?? "")
        await send(.messagesClear)
        await send( checkConnectionStatus(state.isGui, pickable) )
      } else {
        // invalid default
        await send(.showPickerSheet)
      }
    }
  }
  // default not in use, open the Picker
  return .merge(
    clearMessages(state.clearOnStart),
    pickerSheet(state.isGui)
  )
}

private func stopTester(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ objectModel: ObjectModel, _ streamModel: StreamModel) ->  EffectTask<ApiModule.Action> {
  // ----- STOP -----
  return .concatenate(
    resetClientInitialized(apiModel),
    clearMessages(state.clearOnStop),
    stopRxAudio(&state, objectModel, streamModel),
    disconnect(apiModel),
    setConnectionStatus(&state, false)
  )
}

private func startTxAudio(_ state: inout ApiModule.State, _ objectModel: ObjectModel, _ streamModel: StreamModel) ->  EffectTask<ApiModule.Action> {
  // FIXME:
  
  //        if newState {
  //          state.txAudio = true
  //          if state.isConnected {
  //            // start audio
  //            return .run { send in
  //              // request a stream
  //              let id = try await objectModel.radio!.requestRemoteTxAudioStream()
  //
  //              // FIXME:
  //
  //              // finish audio setup
  //              //            await send(.startAudio(id.streamId!))
  //            }
  //          } else {
  //            return .none
  //          }
  //
  //        } else {
  //          // stop audio
  //          state.txAudio = false
  //          //        state.opusPlayer?.stop()
  //          //        state.opusPlayer = nil
  //          if state.isConnected == false {
  //            return .none
  //          } else {
  //            return .run { send in
  //              // request removal of the stream
  //              await streamModel.removeRemoteTxAudioStream(objectModel.radio!.connectionHandle)
  //            }
  //          }
  //        }
  return .none
}

private func stopTxAudio(_ state: inout ApiModule.State, _ objectModel: ObjectModel, _ streamModel: StreamModel) ->  EffectTask<ApiModule.Action> {
  // FIXME:
  
  return .none
}

//private func subscribeToPackets() ->  EffectTask<ApiModule.Action> {
//  Effect.run { send in
//    for await event in PacketModel.shared.packetStream {
//      // a packet has been added / updated or deleted
//      await send(.packetEvent(event))
//    }
//  }
//}

private func subscribeToClients(_ listener: Listener) ->  EffectTask<ApiModule.Action> {
  return .run { send in
    for await event in await listener.clientStream {
      // a guiClient has been added / updated or deleted
      await send(.clientEvent(event))
    }
  }
}

private func subscribeToLogAlerts() ->  EffectTask<ApiModule.Action>  {
  return .run { send in
    for await entry in logAlerts {
      // a Warning or Error has been logged.
      await send(.showLogAlert(entry))
    }
  }
}

private func updateDefault(_ state: inout ApiModule.State, _ selection: Pickable) ->  EffectTask<ApiModule.Action> {
  // SET / RESET the default
  if state.isGui {
    // GUI
    let newValue = DefaultValue(selection)
    if state.guiDefault == newValue {
      state.guiDefault = nil
    } else {
      state.guiDefault = newValue
    }
  } else {
    // NONGUI
    let newValue = DefaultValue(selection)
    if state.nonGuiDefault == newValue {
      state.nonGuiDefault = nil
    } else {
      state.nonGuiDefault = newValue
    }
  }
  state.pickerState!.defaultValue = state.isGui ? state.guiDefault : state.nonGuiDefault
  return .none
}

// ----------------------------------------------------------------------------
// MARK: - Structs and Enums

public enum ViewType: Equatable {
  case api
  case log
}

public enum ObjectFilter: String, CaseIterable {
  case core
  case coreNoMeters = "core w/o meters"
  case amplifiers
  case cwx
  case bandSettings = "band settings"
  case equalizers
  case interlock
  case memories
  case misc
  case profiles
  case meters
  case network
  case streams
  case usbCable
  case wan
  case waveforms
  case xvtrs
}

public enum MessageFilter: String, CaseIterable {
  case all
  case prefix
  case includes
  case excludes
  case command
  case status
  case reply
  case S0
}
