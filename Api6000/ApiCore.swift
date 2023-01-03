//
//  ApiCore.swift
//  Api6000Components/ApiViewer
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture
import SwiftUI

//import Api6000
import ClientFeature
import Listener
import LoginFeature
import LogFeature
import Objects
import OpusPlayer
import PickerFeature
import RightSideFeature
import Shared
//import SecureStorage
import XCGWrapper

public struct ApiModule: ReducerProtocol {
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.listener) var listener
  @Dependency(\.messagesModel) var messagesModel
  //  @Dependency(\.opusPlayer) var opusPlayer
  @Dependency(\.streamModel) var streamModel
  
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
    var local: Bool { didSet { UserDefaults.standard.set(local, forKey: "local") } }
    var messageFilter: MessageFilter { didSet { UserDefaults.standard.set(messageFilter.rawValue, forKey: "messageFilter") } }
    var messageFilterText: String { didSet { UserDefaults.standard.set(messageFilterText, forKey: "messageFilterText") } }
    var nonGuiDefault: DefaultValue? { didSet { setDefaultValue("nonGuiDefault", nonGuiDefault) } }
    var objectFilter: ObjectFilter { didSet { UserDefaults.standard.set(objectFilter.rawValue, forKey: "objectFilter") } }
    var reverse: Bool { didSet { UserDefaults.standard.set(reverse, forKey: "reverse") } }
    var rxAudio: Bool { didSet { UserDefaults.standard.set(rxAudio, forKey: "rxAudio") } }
    var showLeftButtons: Bool { didSet { UserDefaults.standard.set(showLeftButtons, forKey: "showLeftButtons") } }
    var showPings: Bool { didSet { UserDefaults.standard.set(showPings, forKey: "showPings") } }
    var showTimes: Bool { didSet { UserDefaults.standard.set(showTimes, forKey: "showTimes") } }
    var smartlink: Bool { didSet { UserDefaults.standard.set(smartlink, forKey: "smartlink") } }
    var smartlinkEmail: String { didSet { UserDefaults.standard.set(smartlinkEmail, forKey: "smartlinkEmail") } }
    var txAudio: Bool { didSet { UserDefaults.standard.set(txAudio, forKey: "txAudio") } }
    var useDefault: Bool { didSet { UserDefaults.standard.set(useDefault, forKey: "useDefault") } }
    
    var connectionMode: ConnectionMode { didSet { UserDefaults.standard.set(connectionMode.rawValue, forKey: "connectionMode") } }

    
    
    // other state
    var commandToSend = ""
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
    
    public init(
      alertOnError: Bool = UserDefaults.standard.bool(forKey: "alertOnError"),
      clearOnSend: Bool  = UserDefaults.standard.bool(forKey: "clearOnSend"),
      clearOnStart: Bool = UserDefaults.standard.bool(forKey: "clearOnStart"),
      clearOnStop: Bool  = UserDefaults.standard.bool(forKey: "clearOnStop"),
      fontSize: CGFloat = UserDefaults.standard.double(forKey: "fontSize") == 0 ? 12 : UserDefaults.standard.double(forKey: "fontSize"),
      guiDefault: DefaultValue? = getDefaultValue("guiDefault"),
      isGui: Bool = UserDefaults.standard.bool(forKey: "isGui"),
      local: Bool = UserDefaults.standard.bool(forKey: "local"),
      messageFilter: MessageFilter = MessageFilter(rawValue: UserDefaults.standard.string(forKey: "messageFilter") ?? "all") ?? .all,
      messageFilterText: String = UserDefaults.standard.string(forKey: "messageFilterText") ?? "",
      nonGuiDefault: DefaultValue? = getDefaultValue("nonGuiDefault"),
      objectFilter: ObjectFilter = ObjectFilter(rawValue: UserDefaults.standard.string(forKey: "objectFilter") ?? "core") ?? .core,
      reverse: Bool = UserDefaults.standard.bool(forKey: "reverse"),
      rxAudio: Bool  = UserDefaults.standard.bool(forKey: "rxAudio"),
      showLeftButtons: Bool = UserDefaults.standard.bool(forKey: "showLeftButtons"),
      showPings: Bool = UserDefaults.standard.bool(forKey: "showPings"),
      showTimes: Bool = UserDefaults.standard.bool(forKey: "showTimes"),
      smartlink: Bool = UserDefaults.standard.bool(forKey: "smartlink"),
      smartlinkEmail: String = UserDefaults.standard.string(forKey: "smartlinkEmail") ?? "",
      txAudio: Bool  = UserDefaults.standard.bool(forKey: "txAudio"),
      useDefault: Bool = UserDefaults.standard.bool(forKey: "useDefault"),

      connectionMode: ConnectionMode = ConnectionMode(rawValue: UserDefaults.standard.string(forKey: "connectionMode") ?? "none") ?? .none


    )
    {
      self.alertOnError = alertOnError
      self.clearOnStart = clearOnStart
      self.clearOnStop = clearOnStop
      self.clearOnSend = clearOnSend
      self.guiDefault = guiDefault
      self.fontSize = fontSize
      self.isGui = isGui
      self.local = local
      self.messageFilter = messageFilter
      self.messageFilterText = messageFilterText
      self.nonGuiDefault = nonGuiDefault
      self.objectFilter = objectFilter
      self.reverse = reverse
      self.rxAudio = rxAudio
      self.showLeftButtons = showLeftButtons
      self.showPings = showPings
      self.showTimes = showTimes
      self.smartlink = smartlink
      self.smartlinkEmail = smartlinkEmail
      self.txAudio = txAudio
      self.useDefault = useDefault
      
      self.connectionMode = connectionMode
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Actions
  
  public enum Action: Equatable {
    // initialization
    case onAppear
    
    // UI controls
    case clearNowButton
    case connectionModePicker(String)
    case fontSizeStepper(CGFloat)
//    case localButton(Bool)
    case loginRequiredButton(Bool)
    case messagesFilterTextField(String)
    case messagesFilterPicker(MessageFilter)
    case objectsPicker(ObjectFilter)
    case rxAudioButton(Bool)
    case saveButton
    case sendButton
    case sendClearButton
    case sendNextStepper
    case sendPreviousStepper
    case sendTextField(String)
    case showPingsToggle
//    case smartlinkButton(Bool)
    case startStopButton
    case toggle(WritableKeyPath<ApiModule.State, Bool>)
    case txAudioButton(Bool)
    
    // subview related
    case alertDismissed
    case client(ClientFeature.Action)
    case login(LoginFeature.Action)
    case picker(PickerFeature.Action)
    
    // Effects related
    //    case checkConnectionStatus(Pickable)
    case connect(Pickable, UInt32?)
    case connectionStatus(Bool)
    case loginStatus(Bool, String)
    //    case startRxAudio(RemoteRxAudioStreamId)
    
    // Sheet related
    case showClientSheet(Pickable, [String], [UInt32])
    case showErrorAlert(ConnectionError)
    case showLogAlert(LogEntry)
    case showLoginSheet
    case showPickerSheet
    
    // Subscription related
    case clientEvent(ClientEvent)
    //    case packetEvent(PacketEvent)
    case testResult(TestResult)
    
    case closeOtherWindows
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
        
      case .clearNowButton:
        return .fireAndForget {
          await messagesModel.clearAll()
        }
        
      case .closeOtherWindows:
        let windows = NSApp.windows
        for window in windows {
          if window.identifier?.rawValue == WindowType.logView.rawValue
              || window.identifier?.rawValue == WindowType.leftSideView.rawValue
              || window.identifier?.rawValue == WindowType.rightSideView.rawValue {
            log("Api6000: \(window.identifier!.rawValue) window closed", .debug, #function, #file, #line)
            window.close()
          }
        }
        return .none
        
      case .connectionModePicker(let mode):
        state.connectionMode = ConnectionMode(rawValue: mode) ?? .none
        return initializeMode(state, listener)
        
      case .fontSizeStepper(let size):
        state.fontSize = size
        return .none
        
//      case .localButton(let newState):
//        state.local = newState
//        return initializeMode(state, listener)
        
      case .loginRequiredButton(_):
        state.loginRequired.toggle()
        if state.loginRequired {
          // re-initialize the connection mode
          return initializeMode(state, listener)
        }
        return .none
        
      case .messagesFilterTextField(let text):
        state.messageFilterText = text
        return .fireAndForget { [state] in
          await messagesModel.setFilter(state.messageFilter, state.messageFilterText)
        }
        
      case .messagesFilterPicker(let filter):
        state.messageFilter = filter
        return .fireAndForget { [state] in
          await messagesModel.setFilter(state.messageFilter, state.messageFilterText)
        }
        
      case .objectsPicker(let newFilter):
        state.objectFilter = newFilter
        return .none
        
      case .rxAudioButton(let startRx):
        // update state
        state.rxAudio = startRx
        if state.isConnected {
          // CONNECTED, start / stop RxAudio
          if startRx {
            return startRxAudio(&state, apiModel, streamModel)
          } else {
            return stopRxAudio(&state, apiModel, streamModel)
          }
        } else {
          // NOT CONNECTED
          return .none
        }
        
      case .saveButton:
        return saveMessagesToFile(messagesModel)
        
      case .sendButton:
        return sendCommand(&state, apiModel)
        
      case .sendClearButton:
        state.commandToSend = ""
        state.commandsIndex = 0
        return .none
        
      case .sendNextStepper:
        if state.commandsIndex == state.commandsArray.count - 1{
          state.commandsIndex = 0
        } else {
          state.commandsIndex += 1
        }
        state.commandToSend = state.commandsArray[state.commandsIndex]
        return .none
        
      case .sendPreviousStepper:
        if state.commandsIndex == 0 {
          state.commandsIndex = state.commandsArray.count - 1
        } else {
          state.commandsIndex -= 1
        }
        state.commandToSend = state.commandsArray[state.commandsIndex]
        return .none
        
      case .sendTextField(let text):
        state.commandToSend = text
        return .none
        
      case .showPingsToggle:
        state.showPings.toggle()
        return .fireAndForget { [state] in
          await messagesModel.setShowPings(state.showPings)
        }
        
//      case .smartlinkButton(let newState):
//        state.smartlink = newState
//        return initializeMode(state, listener)
        
      case .startStopButton:
        if state.isConnected {
          return stopTester(&state, apiModel, streamModel)
        } else {
          return startTester(&state, apiModel, streamModel, listener)
        }
        
      case .toggle(let keyPath):
        state[keyPath: keyPath].toggle()
        return .none
        
      case .txAudioButton(let startTx):
        // update state
        state.txAudio = startTx
        if state.isConnected {
          // CONNECTED, start / stop TxAudio
          if startTx {
            return startTxAudio(&state, apiModel, streamModel)
          } else {
            return stopTxAudio(&state, apiModel, streamModel)
          }
        } else {
          // NOT CONNECTED
          return .none
        }
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: invoked by other actions
        
      case .connect(let selection, let disconnectHandle):
        state.clientState = nil
        return connectionAttempt(state, selection, disconnectHandle, messagesModel, apiModel)
        
      case .connectionStatus(let connected):
        state.isConnected = connected
        if state.isConnected && state.isGui && state.rxAudio {
          // Start RxAudio
          return startRxAudio(&state, apiModel, streamModel)
        }
        return .none
        
      case .loginStatus(let success, let user):
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
        
      case .showClientSheet(let selection, let stations, let handles):
        state.clientState = ClientFeature.State(selection: selection, stations: stations, handles: handles)
        return .none
        
      case .showErrorAlert(let error):
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
        
      case .clientEvent(let event):
        return clientEvent(state, event, apiModel)
        
      case .showLogAlert(let logEntry):
        return showLogAlert(&state,logEntry)
        
      case .testResult(let result):
        // a test result has been received
        state.pickerState?.testResult = result.success
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Login Actions (LoginFeature -> ApiView)
        
      case .login(.cancelButton):
        state.loginState = nil
        state.loginRequired = false
        return .none
        
      case .login(.loginButton(let user, let pwd)):
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
        
      case .picker(.connectButton(let selection)):
        // close the Picker sheet
        state.pickerState = nil
        // save the station (if any)
        state.station = selection.station
        // check for other connections
        return .task { [state] in
          await checkConnectionStatus(state.isGui, selection)
        }
        
      case .picker(.defaultButton(let selection)):
        return updateDefault(&state, selection)
        
      case .picker(.testButton(let selection)):
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
        
      case .client(.connect(let selection, let disconnectHandle)):
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

private func checkConnectionStatus(_ isGui: Bool, _ selection: Pickable) async -> ApiModule.Action {
  // Gui connection with othe stations?
  if isGui && selection.packet.guiClients.count > 0 {
    // YES, may need a disconnect
    var stations = [String]()
    var handles = [Handle]()
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

private func clearMessages(_ clear: Bool) -> Effect<ApiModule.Action, Never> {
  if clear { return .run { send in await send(.clearNowButton) } }
  return .none
}

private func clientEvent(_ state: ApiModule.State, _ event: ClientEvent, _ apiModel: ApiModel) -> Effect<ApiModule.Action, Never> {
  // a GuiClient change occurred
  switch event.action {
  case .added:
    return .none
    
  case .removed:
    return .fireAndForget { [state] in
      // if nonGui, is it our connected Station?
      if state.isGui == false && event.client.station == state.station {
        // YES, unbind
        await apiModel.setActiveStation( nil )
        await apiModel.radio?.bindToGuiClient(nil)
      }
    }
    
  case .completed:
    return .fireAndForget { [state] in
      // if nonGui, is there a clientId for our connected Station?
      if state.isGui == false && event.client.station == state.station {
        // YES, bind to it
        await apiModel.setActiveStation( event.client.station )
        await apiModel.radio?.bindToGuiClient(event.client.clientId)
      }
    }
  }
}

private func connectionAttempt(_ state: ApiModule.State, _ selection: Pickable, _ disconnectHandle: Handle?, _ messagesModel: MessagesModel, _ apiModel: ApiModel) -> Effect<ApiModule.Action, Never> {
  
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

private func disconnect(_ apiModel: ApiModel) -> Effect<ApiModule.Action, Never> {
  return .run { send in await apiModel.disconnect() }
}

private func initialization(_ state: inout ApiModule.State, _ listener: Listener) -> Effect<ApiModule.Action, Never> {
  // if the first time, start various effects
  if state.initialized == false {
    state.initialized = true
    // instantiate the Logger,
    _ = XCGWrapper(logLevel: .debug)
    // start subscriptions
    return .merge(
      subscribeToClients(listener),
      subscribeToLogAlerts(),
      initializeMode(state, listener)
    )
  }
  return .none
}

func initializeMode(_ state: ApiModule.State, _ listener: Listener) -> Effect<ApiModule.Action, Never> {
  // start / stop listeners as appropriate for the Mode
  return .run { [state] send in
    // set the connection mode, start the Lan and/or Wan listener
    if await listener.setConnectionMode(state.connectionMode, state.smartlinkEmail) {
      if state.loginRequired && state.smartlink {
        // Smartlink login is required
        await send(.showLoginSheet)
      }
    } else {
      // Wan listener was required and failed to start
      await send(.showLoginSheet)
    }
  }
}

private func pickerSheet(_ isGui: Bool) -> Effect<ApiModule.Action, Never> {
  return .run {send in await send(.showPickerSheet) }
}

private func resetClientInitialized(_ apiModel: ApiModel) -> Effect<ApiModule.Action, Never> {
  return .fireAndForget {
    await apiModel.resetClientInitialized()
  }
}

private func saveMessagesToFile(_ messagesModel: MessagesModel) -> Effect<ApiModule.Action, Never> {
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

private func sendCommand(_ state: inout ApiModule.State, _ apiModel: ApiModel) -> Effect<ApiModule.Action, Never> {
  // update the command history
  if state.commandToSend != state.previousCommand { state.commandsArray.append(state.commandToSend) }
  state.previousCommand = state.commandToSend
  state.commandsIndex = state.commandsIndex + 1
  
  if state.clearOnSend {
    state.commandToSend = ""
    state.commandsIndex = 0
  }
  return .fireAndForget { [state] in
    _ = await apiModel.radio?.send(state.commandToSend)
  }
}

private func setConnectionStatus(_ state: inout ApiModule.State, _ status: Bool) -> Effect<ApiModule.Action, Never> {
  state.isConnected = status
  return .none
}

private func showLogAlert(_ state: inout ApiModule.State, _ logEntry: LogEntry) -> Effect<ApiModule.Action, Never> {
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

private func startRxAudio(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel) -> Effect<ApiModule.Action, Never> {
  if state.opusPlayer == nil {
    // ----- START Rx AUDIO -----
    state.opusPlayer = OpusPlayer()
    // start audio
    return .fireAndForget { [state] in
      // request a stream
      if let id = try await apiModel.radio!.requestRemoteRxAudioStream().streamId {
        // finish audio setup
        state.opusPlayer?.start(id)
        await streamModel.remoteRxAudioStreams[id: id]?.setDelegate(state.opusPlayer)
      }
    }
  }
  return .none
}

private func stopRxAudio(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel) -> Effect<ApiModule.Action, Never> {
  if state.opusPlayer != nil {
    // ----- STOP Rx AUDIO -----
    let id = state.opusPlayer!.id
    state.opusPlayer!.stop()
    state.opusPlayer = nil
    return .fireAndForget {
      await streamModel.removeRemoteRxAudioStream(id)
    }
  }
  return .none
}

private func startTester(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel, _ listener: Listener) -> Effect<ApiModule.Action, Never> {
  // ----- START -----
  // use the default?
  if state.useDefault {
    // YES, use the Default
    return .run { [state] send in
      if let packet = await listener.findPacket(for: state.guiDefault, state.nonGuiDefault, state.isGui) {
        // valid default
        let pickable = Pickable(packet: packet, station: state.isGui ? "" : state.nonGuiDefault?.station ?? "")
        await send(.clearNowButton)
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

private func stopTester(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel) -> Effect<ApiModule.Action, Never> {
  // ----- STOP -----
  return .merge(
    resetClientInitialized(apiModel),
    clearMessages(state.clearOnStop),
    stopRxAudio(&state, apiModel, streamModel),
    disconnect(apiModel),
    setConnectionStatus(&state, false)
  )
}

private func startTxAudio(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel) -> Effect<ApiModule.Action, Never> {
  // FIXME:
  
  //        if newState {
  //          state.txAudio = true
  //          if state.isConnected {
  //            // start audio
  //            return .run { send in
  //              // request a stream
  //              let id = try await apiModel.radio!.requestRemoteTxAudioStream()
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
  //              await streamModel.removeRemoteTxAudioStream(apiModel.radio!.connectionHandle)
  //            }
  //          }
  //        }
  return .none
}

private func stopTxAudio(_ state: inout ApiModule.State, _ apiModel: ApiModel, _ streamModel: StreamModel) -> Effect<ApiModule.Action, Never> {
  // FIXME:
  
  return .none
}

//private func subscribeToPackets() -> Effect<ApiModule.Action, Never> {
//  Effect.run { send in
//    for await event in PacketModel.shared.packetStream {
//      // a packet has been added / updated or deleted
//      await send(.packetEvent(event))
//    }
//  }
//}

private func subscribeToClients(_ listener: Listener) -> Effect<ApiModule.Action, Never> {
  return .run { send in
    for await event in await listener.clientStream {
      // a guiClient has been added / updated or deleted
      await send(.clientEvent(event))
    }
  }
}

private func subscribeToLogAlerts() -> Effect<ApiModule.Action, Never>  {
  return .run { send in
    for await entry in logAlerts {
      // a Warning or Error has been logged.
      await send(.showLogAlert(entry))
    }
  }
}

private func updateDefault(_ state: inout ApiModule.State, _ selection: Pickable) -> Effect<ApiModule.Action, Never> {
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
