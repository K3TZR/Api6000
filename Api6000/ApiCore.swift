//
//  ApiCore.swift
//  Api6000
//
//  Created by Douglas Adams on 11/24/21.
//

import ComposableArchitecture
import SwiftUI

import ClientDialog
import Listener
import LoginDialog
import LogView
import FlexApi
import OpusPlayer
import RadioPicker
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
    var guiDefault: DefaultValue? { didSet { setDefaultValue("guiDefault", guiDefault) } }
    var nonGuiDefault: DefaultValue? { didSet { setDefaultValue("nonGuiDefault", nonGuiDefault) } }
    var rxAudio: Bool { didSet { UserDefaults.standard.set(rxAudio, forKey: "rxAudio") } }
    var txAudio: Bool { didSet { UserDefaults.standard.set(txAudio, forKey: "txAudio") } }
    
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
    var startStopDisabled = false
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
      guiDefault: DefaultValue? = getDefaultValue("guiDefault"),
      nonGuiDefault: DefaultValue? = getDefaultValue("nonGuiDefault"),
      rxAudio: Bool  = UserDefaults.standard.bool(forKey: "rxAudio"),
      txAudio: Bool  = UserDefaults.standard.bool(forKey: "txAudio")
    )
    {
      self.guiDefault = guiDefault
      self.nonGuiDefault = nonGuiDefault
      self.rxAudio = rxAudio
      self.txAudio = txAudio
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
    case fontSize(CGFloat)
    case gotoLast
    case loginRequired
    case messagesClear
    case messagesFilter(String)
    case messagesFilterText(String)
    case messagesSave
    case rxAudio
    case startStop
//    case stateSet(WritableKeyPath<ApiModule.State, Bool>, Bool)
//    case stateToggle(WritableKeyPath<ApiModule.State, Bool>)
    case txAudio
    
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
        
      case let .fontSize(size):
        UserDefaults.standard.set(size, forKey: "fontSize")
        return .none
        
      case .gotoLast:
        state.gotoLast.toggle()
        return .none
        
      case .messagesClear:
        messagesModel.clearAll()
        return .none
        
      case let .messagesFilter(filter):
        messagesModel.reFilter(filter: filter)
      return .none
        
      case let .messagesFilterText(filterText):
        messagesModel.reFilter(filterText: filterText)
      return .none
        
      case .messagesSave:
        return saveMessagesToFile(messagesModel)
        
      case .rxAudio:
        state.rxAudio.toggle()
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

        
      case .startStop:
        state.startStopDisabled = true
        if state.isConnected {
          // ----- STOP -----
          if UserDefaults.standard.bool(forKey: "clearOnStop") { messagesModel.clearAll() }
          apiModel.resetClientInitialized()
          return .run { send in
            await apiModel.disconnect()
            await send(.connectionStatus(false))
          }
          
        } else {
          // ----- START -----
          if UserDefaults.standard.bool(forKey: "clearOnStart") { messagesModel.clearAll() }
          // use the default?
          if UserDefaults.standard.bool(forKey: "useDefault") {
            // YES, use the Default
            return .run { [state] send in
              if let packet = listener.findPacket(for: state.guiDefault, state.nonGuiDefault, UserDefaults.standard.bool(forKey: "isGui")) {
                // valid default
                let pickable = Pickable(packet: packet, station: UserDefaults.standard.bool(forKey: "isGui") ? "" : state.nonGuiDefault?.station ?? "")
                await send( checkConnectionStatus(UserDefaults.standard.bool(forKey: "isGui"), pickable) )
              } else {
                // invalid default
                await send(.showPickerSheet)
              }
            }
          }
          // default not in use, open the Picker
          return .run {send in await send(.showPickerSheet) }
        }
        
//      case let .stateSet(keyPath, boolValue):
//        state[keyPath: keyPath] = boolValue
//        return .none
        
      case .loginRequired:
        state.loginRequired.toggle()
        return initializeMode(state, listener)
        
      case .txAudio:
        state.txAudio.toggle()
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
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: invoked by other actions
        
      case let .connect(selection, disconnectHandle):
        state.clientState = nil
        return connectionAttempt(state, selection, disconnectHandle, messagesModel, apiModel)
        
      case let .connectionStatus(connected):
        state.isConnected = connected
        state.startStopDisabled = false
        if state.isConnected && UserDefaults.standard.bool(forKey: "isGui") && state.rxAudio {
          // Start RxAudio
          return startRxAudio(&state, apiModel, streamModel)
        }
        return .none
        
      case let .loginStatus(success, user):
        // a smartlink login was completed
        if success {
          // save the User
          UserDefaults.standard.set(user, forKey: "smartlinkEmail")
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
        state.loginState = LoginFeature.State(heading: "Smartlink Login Required", user: UserDefaults.standard.string(forKey: "smartlinkEmail") ?? "")
        return .none
        
      case .showPickerSheet:
        state.pickerState = PickerFeature.State(defaultValue: UserDefaults.standard.bool(forKey: "isGui") ? state.guiDefault : state.nonGuiDefault, isGui: UserDefaults.standard.bool(forKey: "isGui"))
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
        state.startStopDisabled = false
        return .none
        
      case let .picker(.connectButton(selection)):
        // close the Picker sheet
        state.pickerState = nil
        // save the station (if any)
        state.station = selection.station
        // check for other connections
        return .task {
          await checkConnectionStatus(UserDefaults.standard.bool(forKey: "isGui"), selection)
        }
        
      case let .picker(.defaultButton(selection)):
        return updateDefault(&state, selection)
        
      case let .picker(.testButton(selection)):
        state.pickerState?.testResult = false
        // send a Test request
        return .fireAndForget { listener.sendWanTest(selection.packet.serial) }
        
      case .picker(_):
        // IGNORE ALL OTHER picker actions
        state.startStopDisabled = false
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

private func clientEvent(_ state: ApiModule.State, _ event: ClientEvent, _ apiModel: ApiModel, _ objectModel: ObjectModel) ->  EffectTask<ApiModule.Action> {
  // a GuiClient change occurred
  switch event.action {
  case .added:
    return .none
    
  case .removed:
    return .fireAndForget { [state] in
      // if nonGui, is it our connected Station?
      if UserDefaults.standard.bool(forKey: "isGui") == false && event.client.station == state.station {
        // YES, unbind
        await objectModel.setActiveStation( nil )
        apiModel.bindToGuiClient(nil)
      }
    }
    
  case .completed:
    return .fireAndForget { [state] in
      // if nonGui, is there a clientId for our connected Station?
      if UserDefaults.standard.bool(forKey: "isGui") == false && event.client.station == state.station {
        // YES, bind to it
        await objectModel.setActiveStation( event.client.station )
        apiModel.bindToGuiClient(event.client.clientId)
      }
    }
  }
}

private func connectionAttempt(_ state: ApiModule.State, _ selection: Pickable, _ disconnectHandle: UInt32?, _ messagesModel: MessagesModel, _ apiModel: ApiModel) ->  EffectTask<ApiModule.Action> {
  
  return .run { send in
    messagesModel.start()
    // attempt to connect to the selected Radio / Station
    do {
      // try to connect
      try await apiModel.connectTo(selection: selection,
                                   isGui: UserDefaults.standard.bool(forKey: "isGui"),
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

private func initialization(_ state: inout ApiModule.State, _ listener: Listener) ->  EffectTask<ApiModule.Action> {
  // if the first time, start various effects
  if state.initialized == false {
    state.initialized = true
    // instantiate the Logger,
    _ = XCGWrapper(logLevel: .debug)

    if !UserDefaults.standard.bool(forKey: "smartlinkEnabled")  && !UserDefaults.standard.bool(forKey: "localEnabled") {
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
    if await listener.setConnectionMode(UserDefaults.standard.bool(forKey: "localEnabled"),  UserDefaults.standard.bool(forKey: "smartlinkEnabled"), UserDefaults.standard.string(forKey: "smartlinkEmail") ?? "") {
      if state.loginRequired && UserDefaults.standard.bool(forKey: "smartlinkEnabled") {
        // Smartlink login is required
        await send(.showLoginSheet)
      }
    } else {
      // Wan listener was required and failed to start
      await send(.showLoginSheet)
    }
  }
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
      
      let textArray = messagesModel.filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
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
  
  if UserDefaults.standard.bool(forKey: "clearOnSend") {
    state.commandToSend = ""
    state.commandsIndex = 0
  }
  return .fireAndForget { [state] in
    apiModel.sendTcp(state.commandToSend)
  }
}

//private func setConnectionStatus(_ state: inout ApiModule.State, _ status: Bool) ->  EffectTask<ApiModule.Action> {
//  state.isConnected = status
//  return .none
//}

private func showLogAlert(_ state: inout ApiModule.State, _ logEntry: LogEntry) ->  EffectTask<ApiModule.Action> {
  if UserDefaults.standard.bool(forKey: "alertOnError") {
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
    for await event in listener.clientStream {
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
  if UserDefaults.standard.bool(forKey: "isGui") {
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
  state.pickerState!.defaultValue = UserDefaults.standard.bool(forKey: "isGui") ? state.guiDefault : state.nonGuiDefault
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
