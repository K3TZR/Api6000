//
//  ApiView.swift
//  Api6000
//
//  Created by Douglas Adams on 12/1/21.
//

import ComposableArchitecture
import SwiftUI

import ClientFeature
import LoginFeature
import LogFeature
import PickerFeature
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {
  let store: StoreOf<ApiModule>
  
  @Environment(\.openWindow) var openWindow
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.messagesModel) var messagesModel
  @Dependency(\.objectModel) var objectModel
  
  public init(store: StoreOf<ApiModule>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: {$0} ) { viewStore in
      VStack(alignment: .leading) {
        TopButtonsView(store: store)
        SendView(store: store)
        FiltersView(store: store)
        
        Divider().background(Color(.gray))
        
        VSplitView {
          if viewStore.isConnected {
            ObjectsView(store: store, apiModel: apiModel, objectModel: objectModel, packet: apiModel.activePacket!, radio: apiModel.radio!)
              .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
            Divider().background(Color(.cyan))
            MessagesView(store: store, messagesModel: messagesModel)
              .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
            
          } else {
            Text("Radio objects will be displayed here")
              .frame(minWidth: 900, maxWidth: .infinity, minHeight: 200, alignment: .center)
            
            Divider().background(Color(.cyan))
            Text("Tcp Messages will be displayed here")
              .frame(minWidth: 900, maxWidth: .infinity, minHeight: 200, alignment: .center)
          }
        }
        Spacer()
        Divider().background(Color(.gray))
        BottomButtonsView(store: store)        
      }
      
      // ---------- Initialization ----------
      // initialize on first appearance
      .onAppear() {
        if viewStore.openLogWindow { openWindow(id: WindowType.log.rawValue) }
        if viewStore.openRightWindow { openWindow(id: WindowType.right.rawValue) }
        viewStore.send(.onAppear)
      }
      
      // ---------- Sheet Management ----------
      // alert dialogs
      .alert(
        self.store.scope(state: \.alertState),
        dismiss: .alertDismissed
      )
      
      // Picker sheet
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.pickerState != nil },
          send: ApiModule.Action.picker(.cancelButton)),
        content: {
          IfLetStore(
            store.scope(state: \.pickerState, action: ApiModule.Action.picker),
            then: PickerView.init(store:)
          )
        }
      )
      
      // Login sheet
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.loginState != nil },
          send: ApiModule.Action.login(.cancelButton)),
        content: {
          IfLetStore(
            store.scope(state: \.loginState, action: ApiModule.Action.login),
            then: LoginView.init(store:)
          )
        }
      )
      
      // Client connection sheet
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.clientState != nil },
          send: ApiModule.Action.client(.cancelButton)),
        content: {
          IfLetStore(
            store.scope(state: \.clientState, action: ApiModule.Action.client),
            then: ClientView.init(store:)
          )
        }
      )
      
      // ---------- Window Management ----------
      .toolbar {
        Spacer()
        Button("Log") { openWindow(id: WindowType.log.rawValue) }
        Button("Pan") { openWindow(id: WindowType.panadapter.rawValue) }
        Button("Left") { openWindow(id: WindowType.left.rawValue) }
        Button("Right") { openWindow(id: WindowType.right.rawValue) }
      }
      
      .onDisappear {
        viewStore.send(.closeAllWindows)
      }
      
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
        // observe openings
        if let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: viewStore.send(.stateSet(\.openLogWindow, true))
          case WindowType.left.rawValue: viewStore.send(.stateSet(\.openLeftWindow, true))
          case WindowType.right.rawValue: viewStore.send(.stateSet(\.openRightWindow, true))
          default:  break
          }
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
        // observe closings unless the entire app is closing
        if !viewStore.isClosing, let window = notification.object as? NSWindow {
          switch window.identifier?.rawValue {
          case WindowType.log.rawValue: viewStore.send(.stateSet(\.openLogWindow, false))
          case WindowType.left.rawValue: viewStore.send(.stateSet(\.openLeftWindow, false))
          case WindowType.right.rawValue: viewStore.send(.stateSet(\.openRightWindow, false))
          default:  break
          }
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - SubView(s)

private struct TopButtonsView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let isGui: Bool
    let showTimes: Bool
    let showPings: Bool
    let rxAudio: Bool
    let txAudio: Bool
    let localEnabled: Bool
    let smartlinkEnabled: Bool
    let loginRequired: Bool
    let useDefault: Bool
    let isConnected: Bool
    
    init(state: ApiModule.State) {
      self.isGui = state.isGui
      self.showTimes = state.showTimes
      self.showPings = state.showPings
      self.rxAudio = state.rxAudio
      self.txAudio = state.txAudio
      self.localEnabled = state.localEnabled
      self.smartlinkEnabled = state.smartlinkEnabled
      self.loginRequired = state.loginRequired
      self.useDefault = state.useDefault
      self.isConnected = state.isConnected
    }
  }
  
  public  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack(spacing: 20) {
        Button(viewStore.isConnected ? "Stop" : "Start") {
          viewStore.send(.connectionStartStop)
        }
        .keyboardShortcut(viewStore.isConnected ? .cancelAction : .defaultAction)
        
        HStack(spacing: 10) {
          Toggle("Gui", isOn: viewStore.binding(get: \.isGui, send: .stateToggle(\.isGui)))
            .frame(width: 60)
            .disabled( viewStore.isConnected )
          Group {
            Toggle("Show Times", isOn: viewStore.binding(get: \.showTimes, send: .stateToggle(\.showTimes)))
            Toggle("Show Pings", isOn: viewStore.binding(get: \.showPings, send: .stateToggle(\.showPings)))
          }
          .frame(width: 100)
        }
        
        Spacer()
        ControlGroup {
          Toggle(isOn: viewStore.binding(get: \.rxAudio, send: .stateToggle(\.rxAudio) )) {
            Text("Rx Audio") }
          Toggle(isOn: viewStore.binding(get: \.txAudio, send: .stateToggle(\.txAudio) )) {
            Text("Tx Audio") }
        }
        .frame(width: 130)
        
        Spacer()
        ControlGroup {
          Toggle(isOn: viewStore.binding(get: \.localEnabled, send: .stateToggle(\.localEnabled))) {
            Text("Local") }
          Toggle(isOn: viewStore.binding(get: \.smartlinkEnabled, send: .stateToggle(\.smartlinkEnabled) )) {
            Text("Smartlink") }
        }
        .disabled( viewStore.isConnected )
        .frame(width: 130)
        
        Spacer()
        Toggle("Smartlink Login", isOn: viewStore.binding(get: \.loginRequired, send: .stateToggle(\.loginRequired)))
          .disabled( viewStore.isConnected || viewStore.smartlinkEnabled == false )
        Toggle("Use Default", isOn: viewStore.binding(get: \.useDefault, send: .stateToggle(\.useDefault)))
          .disabled( viewStore.isConnected )
      }
    }
  }
}

private struct BottomButtonsView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let alertOnError: Bool
    let clearOnStart: Bool
    let clearOnStop: Bool
    let fontSize: CGFloat
    let gotoLast: Bool
    let showLeftButtons: Bool
    init(state: ApiModule.State) {
      self.alertOnError = state.alertOnError
      self.clearOnStart = state.clearOnStart
      self.clearOnStop = state.clearOnStop
      self.fontSize = state.fontSize
      self.gotoLast = state.gotoLast
      self.showLeftButtons = state.showLeftButtons
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      HStack {
        Stepper("Font Size",
                value: viewStore.binding(
                  get: \.fontSize,
                  send: { value in .fontSize(value) }),
                in: 8...12)
        Text(String(format: "%2.0f", viewStore.fontSize)).frame(alignment: .leading)
        
        Spacer()
        HStack {
          Text("Go to \(viewStore.gotoLast ? "Last" : "First")")
          Image(systemName: viewStore.gotoLast ? "arrow.up.square" : "arrow.down.square").font(.title)
            .onTapGesture { viewStore.send(.stateToggle(\.gotoLast)) }
        }
        Spacer()
        
        HStack {
          Button("Save") { viewStore.send(.messagesSave) }
        }
        Spacer()
        
        HStack(spacing: 30) {
          Toggle("Alert on Error", isOn: viewStore.binding(get: \.alertOnError, send: .stateToggle(\.alertOnError)))
          Toggle("Clear on Start", isOn: viewStore.binding(get: \.clearOnStart, send: .stateToggle(\.clearOnStart)))
          Toggle("Clear on Stop", isOn: viewStore.binding(get: \.clearOnStop, send: .stateToggle(\.clearOnStop)))
          Button("Clear Now") { viewStore.send(.messagesClear)}
          Image(systemName: "rectangle.bottomthird.inset.filled")
            .onTapGesture { viewStore.send(.stateToggle(\.showLeftButtons)) }
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct ApiView_Previews: PreviewProvider {
  static var previews: some View {
    ApiView(
      store: Store(
        initialState: ApiModule.State(),
        reducer: ApiModule()
      )
    )
    .frame(minWidth: 975, minHeight: 600)
    .padding()
  }
}
