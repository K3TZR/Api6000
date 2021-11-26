//
//  RootView.swift
//  TestDiscoveryApp
//
//  Created by Douglas Adams on 11/20/21.
//

import SwiftUI
import ComposableArchitecture
import Picker

struct RootView: View {
  let store: Store<RootState, RootAction>
  
  @State var activeRadio = false
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        TopButtonsView(store: store)
        //        SendView(tester: tester, radioManager: radioManager)
        //        FiltersView(tester: tester)
        
        Divider().background(Color(.red))
        
        VSplitView {
          Text("----- Objects go here -----").frame(minWidth: 950, minHeight: 100, idealHeight: 200, maxHeight: 300, alignment: .leading)
          Divider().background(Color(.green))
          Text("----- Messages go here -----").frame(minWidth: 950, minHeight: 100, idealHeight: 200, maxHeight: 300, alignment: .leading)
        }
        Spacer()
        Divider().background(Color(.red))
        BottomButtonsView()
      }
      .toolbar {
        Button("Log Viewer") { print("Log Viewer button clicked") }
      }
      .sheet(
        isPresented: viewStore.binding(
          get: { $0.pickerState != nil },
          send: .dismissSheet),
        content: {
          IfLetStore(
            store.scope(state: \.pickerState, action: RootAction.pickerAction),
            then: PickerView.init(store:)
          )
        }
      )
    }
  }
}

struct TopButtonsView: View {
  let store: Store<RootState, RootAction>
  
  @State var isConnected = false
  @State var smartlinkIsLoggedIn = false
  @State var smartlinkIsEnabled = false
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 30) {
        Button(isConnected ? "Stop" : "Start") {
          viewStore.send(.startButtonClicked)
        }
        .keyboardShortcut(isConnected ? .cancelAction : .defaultAction)
        .help("Using the Default connection type")
        
        HStack(spacing: 20) {
          Toggle("Gui", isOn: viewStore.binding(get: \.isGui, send: .isGuiClicked))
          Toggle("Times", isOn: viewStore.binding(get: \.showTimes, send: .showTimesClicked))
          Toggle("Pings", isOn: viewStore.binding(get: \.showPings, send: .showPingsClicked))
          Toggle("Replies", isOn: viewStore.binding(get: \.showReplies, send: .showRepliesClicked))
          Toggle("Buttons", isOn: viewStore.binding(get: \.showButtons, send: .showButtonsClicked))
        }
        
        Spacer()
        HStack(spacing: 10) {
          Text("SmartLink")
          Button(smartlinkIsLoggedIn ? "Logout" : "Login") {
            print("SmartLink button clicked")
          }
          .disabled(!smartlinkIsEnabled)
          
          Button("Status") { print("Status button clicked") }
        }.disabled(isConnected)
        
        Spacer()
        Button("Default") { print("Default button clicked") }
      }
    }
  }
}

struct BottomButtonsView: View {
  
  @State var fontSize: CGFloat = 12
  
  var body: some View {
    
    HStack(spacing: 40) {
      Stepper("Font Size", value: $fontSize, in: 8...16)
      Text("\(fontSize)").frame(alignment: .leading)
      Spacer()
      Toggle("Clear on Connect", isOn: .constant(true))
      Toggle("Clear on Disconnect", isOn: .constant(false))
      Button("Clear Now") { print("Clear Now clicked") }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: RootState(),
        reducer: rootReducer,
        environment: RootEnvironment()
      )
    )
  }
}

struct TopButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    TopButtonsView(
      store: Store(
        initialState: RootState(),
        reducer: rootReducer,
        environment: RootEnvironment()
      )
    )
  }
}

struct BottomButtonsView_Previews: PreviewProvider {
  static var previews: some View {
    BottomButtonsView()
  }
}
