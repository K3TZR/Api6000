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

public enum ConnectionMode: String, Identifiable, CaseIterable {
  case both
  case local
  case none
  case smartlink
  
  public var id: String { rawValue }
}

public struct ApiModule: ReducerProtocol {
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.messagesModel) var messagesModel
  @Dependency(\.streamModel) var streamModel

  public init() {}
  
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
    var showPings: Bool { didSet { UserDefaults.standard.set(showPings, forKey: "showPings") } }
    var showTimes: Bool { didSet { UserDefaults.standard.set(showTimes, forKey: "showTimes") } }
    var smartlink: Bool { didSet { UserDefaults.standard.set(smartlink, forKey: "smartlink") } }
    var smartlinkEmail: String { didSet { UserDefaults.standard.set(smartlinkEmail, forKey: "smartlinkEmail") } }
    var txAudio: Bool { didSet { UserDefaults.standard.set(txAudio, forKey: "txAudio") } }
    var useDefault: Bool { didSet { UserDefaults.standard.set(useDefault, forKey: "useDefault") } }
    
    // other state
    var clearNow = false
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
      showPings: Bool = UserDefaults.standard.bool(forKey: "showPings"),
      showTimes: Bool = UserDefaults.standard.bool(forKey: "showTimes"),
      smartlink: Bool = UserDefaults.standard.bool(forKey: "smartlink"),
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
      self.local = local
      self.messageFilter = messageFilter
      self.messageFilterText = messageFilterText
      self.nonGuiDefault = nonGuiDefault
      self.objectFilter = objectFilter
      self.reverse = reverse
      self.rxAudio = rxAudio
      self.showPings = showPings
      self.showTimes = showTimes
      self.smartlink = smartlink
      self.smartlinkEmail = smartlinkEmail
      self.txAudio = txAudio
      self.useDefault = useDefault
    }
  }
  
  public enum Action: Equatable {
    // initialization
    case onAppear
    
    // UI controls
    case clearNowButton
    case fontSizeStepper(CGFloat)
    case localButton(Bool)
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
    case sidebarRight
    case smartlinkButton(Bool)
    case startStopButton
    case toggle(WritableKeyPath<ApiModule.State, Bool>)
    case txAudioButton(Bool)
    
    // subview related
    case alertDismissed
    case client(ClientFeature.Action)
    case login(LoginFeature.Action)
    case picker(PickerFeature.Action)
    
    // Effects related
    case checkConnectionStatus(Pickable)
    case connect(Pickable, UInt32?)
    case isConnected(Bool)
    case loginStatus(Bool, String)
    case startRxAudio(RemoteRxAudioStreamId)
    
    // Sheet related
    case showClientSheet(Pickable, [String], [UInt32])
    case showErrorAlert(ConnectionError)
    case showLogAlert(LogEntry)
    case showLoginSheet
    case showPickerSheet(IdentifiedArrayOf<Pickable>)
    
    // Subscription related
    case clientEvent(ClientEvent)
//    case packetEvent(PacketEvent)
    case testResult(TestResult)
    
    
  }
  
  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      // Parent logic
      switch action {
        // ----------------------------------------------------------------------------
        // MARK: - Actions: ApiView Initialization
        
      case .onAppear:
        // if the first time, start various effects
        if state.initialized == false {
          state.initialized = true
          // instantiate the Logger,
          _ = XCGWrapper(logLevel: .debug)
          // start subscriptions
          return .merge(
//            subscribeToPackets(),
            subscribeToClients(),
            subscribeToLogAlerts(),
//            subscribeToSmartlinkTest(),
            initializeMode(state)
          )
        }
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: ApiView UI controls
        
      case .clearNowButton:
        return .fireAndForget {
          await messagesModel.clearAll()
        }
        
      case .fontSizeStepper(let size):
        state.fontSize = size
        return .none
        
      case .localButton(let newState):
        state.local = newState
        return initializeMode(state)
        
      case .loginRequiredButton(_):
        state.loginRequired.toggle()
        if state.loginRequired {
          // re-initialize the connection mode
          return initializeMode(state)
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
        
      case .rxAudioButton(let newState):
        //        if newState {
        //          state.rxAudio = true
        //          if state.isStopped {
        //            return .none
        //          } else {
        //            // start audio
        //            return .run { send in
        //              // request a stream
        //              let id = try await ViewModel.shared.radio!.requestRemoteRxAudioStream()
        //              // finish audio setup
        //              await send(.startRxAudio(id.streamId!))
        //            }
        //          }
        //
        //        } else {
        //          // stop audio
        //          state.rxAudio = false
        //          state.opusPlayer?.stop()
        //          state.opusPlayer = nil
        //          if state.isStopped == false {
        //            return .run {send in
        //              // request removal of the stream
        //              streamModel.removeRemoteRxAudioStream(ViewModel.shared.radio!.connectionHandle)
        //            }
        //          } else {
        //            return .none
        //          }
        //        }
        return .none
        
      case .saveButton:
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "Api6000Tester-C.messages"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save the Log"
        
        let response = savePanel.runModal()
        if response == .OK {
          return .run { _ in
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 6
            formatter.positiveFormat = " * ##0.000000"
            
            let textArray = await messagesModel.filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
            let fileTextArray = textArray.joined(separator: "\n")
            try? await fileTextArray.write(to: savePanel.url!, atomically: true, encoding: .utf8)
          }
        }
        return .none
        
      case .sendButton:
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
        
      case .sidebarRight:
        return.none
        
      case .smartlinkButton(let newState):
        state.smartlink = newState
        return initializeMode(state)
        
      case .startStopButton:
        return .run { [state] send in
          if state.isConnected {
            // ----- STOP -----
            if state.clearOnStop {
              await messagesModel.clearAll()
            }
            await apiModel.disconnect()
            await send(.isConnected(false))

          } else {
            // ----- START -----
            if state.clearOnStart {
              await messagesModel.clearAll()
            }
            // use the default?
            if state.useDefault && state.isGui && state.guiDefault != nil {
              // YES, use the GuiDefault
              if let packet = Listener.shared.findPacket(for: state.guiDefault, state.isGui) {
                // valid default
                let pickable = Pickable(packet: packet, station: "")
                await send(.checkConnectionStatus(pickable))
              } else {
                // invalid default
                await send(.showPickerSheet(Listener.shared.pickableRadios))
              }
              
            } else if state.useDefault && state.isGui == false && state.nonGuiDefault != nil {
              // YES, use the nonGuiDefault
              if let packet = Listener.shared.findPacket(for: state.nonGuiDefault, state.isGui) {
                // valid default
                let pickable = Pickable(packet: packet, station: state.nonGuiDefault!.station!)
                await send(.checkConnectionStatus(pickable))
              } else {
                // invalid default
                await send(.showPickerSheet(Listener.shared.pickableStations))
              }
              
            } else {
              // NO default or default not in use, open the Picker
              if state.isGui {
                // Pickable radios
                await send(.showPickerSheet(Listener.shared.pickableRadios))
              } else {
                // Pickable stations
                await send(.showPickerSheet(Listener.shared.pickableStations))
              }
            }
          }
        }
          
      case .toggle(let keyPath):
        // handles all buttons with a Bool state, EXCEPT LoginRequiredButton and audioCheckbox
        state[keyPath: keyPath].toggle()
        return .none
        
      case .txAudioButton(let newState):
        return .none
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
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: invoked by other actions
        
      case .checkConnectionStatus(let selection):
        // Gui connection with othe stations?
        let count = Listener.shared.guiClients.count
        if state.isGui && count > 0 {
          // YES, may need a disconnect
          var stations = [String]()
          var handles = [Handle]()
          for client in Listener.shared.guiClients {
            stations.append(client.station)
            handles.append(client.handle)
          }
          // show the client chooser, let the user choose
          return Effect(value: .showClientSheet(selection, stations, handles))
        }
        else {
          // not Gui connection or Gui without other stations, attempt to connect
          return Effect(value: .connect(selection, nil))
        }
        
      case .connect(let selection, let disconnectHandle):
        state.clientState = nil
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
            if state.isGui && state.rxAudio {
              // start audio, request a stream
              let id = try await apiModel.radio!.requestRemoteRxAudioStream()
              // finish audio setup
              await send(.startRxAudio(id.streamId!))
            }
            await send(.isConnected(true))
          } catch {
            // connection attempt failed
            await send(.showErrorAlert( error as! ConnectionError ))
            await send(.isConnected(false))
          }
        }
        
      case .isConnected(let value):
        state.isConnected = value
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
        
      case .startRxAudio(let id):
        state.rxAudio = true
        state.opusPlayer = OpusPlayer()
        streamModel.remoteRxAudioStreams[id: id]?.setDelegate(state.opusPlayer)
        state.opusPlayer!.start()
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: to display a sheet
        
      case .showClientSheet(let selection, let stations, let handles):
        // show the client chooser, let the user choose
        state.clientState = ClientFeature.State(selection: selection, stations: stations, handles: handles)
        return .none
        
      case .showErrorAlert(let error):
        // an error occurred
        state.alertState = AlertState(title: TextState("An Error occurred"), message: TextState(error.rawValue))
        return .none
        
      case .showLoginSheet:
        state.loginState = LoginFeature.State(heading: "Smartlink Login Required", user: state.smartlinkEmail)
        return .none
        
      case .showPickerSheet(let pickables):
        // open the Picker sheet
        state.pickerState = PickerFeature.State(pickables: pickables, defaultValue: state.isGui ? state.guiDefault : state.nonGuiDefault, isGui: state.isGui)
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Actions: invoked by subscriptions
        
      case .clientEvent(let event):
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
        
//      case .packetEvent:
//        // a packet change occurred
//        // is the Picker open?
//        if state.pickerState == nil {
//          // NO, ignore
//          return .none
//        } else {
//          // YES, update it
//          return .run { [isGui = state.isGui] send in
//            // reload the Pickables
//            if isGui {
//              await send(.showPickerSheet(Listener.shared.pickableRadios))
//            } else {
//              await send(.showPickerSheet(Listener.shared.pickableStations))
//            }
//          }
//        }
        
      case .showLogAlert(let logEntry):
        if state.alertOnError {
          // a Warning or Error has been logged.
          // exit any sheet states
          state.clientState = nil
          state.loginState = nil
          state.pickerState = nil
          // alert the user
          state.alertState = .init(title: TextState("\(logEntry.level == .warning ? "A Warning" : "An Error") was logged:"),
                                   message: TextState(logEntry.msg))
        }
        return .none
        
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
          let success = await Listener.shared.startWan(user, pwd)
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
        return Effect(value: .checkConnectionStatus(selection))
        
      case .picker(.defaultButton(let selection)):
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
        
      case .picker(.testButton(let selection)):
        state.pickerState?.testResult = false
        // send a Test request
        Listener.shared.sendWanTest(selection.packet.serial)
        return .none
        
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
        return .run { send in
          await send (.connect(selection, disconnectHandle))
        }
        
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
// MARK: - Effects

func initializeMode(_ state: ApiModule.State) -> Effect<ApiModule.Action, Never> {
  // start / stop listeners as appropriate for the Mode
  return .run { [state] send in
    // set the connection mode, start the Lan and/or Wan listener
    if await Listener.shared.setConnectionMode(state.local, state.smartlink, state.smartlinkEmail) {
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

private func subscribeToClients() -> Effect<ApiModule.Action, Never> {
  return .run { send in
    for await event in Listener.shared.clientStream {
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

//private func subscribeToPackets() -> Effect<ApiModule.Action, Never> {
//  Effect.run { send in
//    for await event in Listener.shared.packetStream {
//      // a packet has been added / updated or deleted
//      await send(.packetEvent(event))
//    }
//  }
//}

//private func subscribeToSmartlinkTest() -> Effect<ApiModule.Action, Never> {
//  Effect.run { send in
//    for await result in Listener.shared.testStream {
//      // the result of a Smartlink Test has been received
//      await send(.testResult(result))
//    }
//  }
//}

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
