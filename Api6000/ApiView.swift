//
//  ApiView.swift
//  Api6000Components/ApiViewer
//
//  Created by Douglas Adams on 12/1/21.
//

import ComposableArchitecture
import SwiftUI

import ClientFeature
import LeftSideFeature
import LoginFeature
import LogFeature
import PickerFeature
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {
  let store: StoreOf<ApiModule>

  @Dependency(\.messagesModel) var messagesModel
  @Dependency(\.apiModel) var apiModel

  public init(store: StoreOf<ApiModule>) {
    self.store = store
  }
  
//  struct ViewState: Equatable {
//    let loginState: LoginFeature.State?
//    let clientState: ClientFeature.State?
//    let pickerState: PickerFeature.State?
//    let isConnected: Bool
//    init(state: ApiModule.State) {
//      self.loginState = state.loginState
//      self.clientState = state.clientState
//      self.pickerState = state.pickerState
//      self.isConnected = state.isConnected
//    }
//  }
  
  public var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in

      VStack(alignment: .leading) {
        TopButtonsView(store: store)
        SendView(store: store)
        FiltersView(store: store)

        Divider().background(Color(.gray))

        VSplitView {
          if viewStore.isConnected {
            ObjectsView(store: store, apiModel: apiModel, packet: apiModel.activePacket!, radio: apiModel.radio!)
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
        if viewStore.showLeftButtons {
          LeftSideView(store: Store(
            initialState: LeftSideFeature.State(vertical: false),
            reducer: LeftSideFeature()
          ), apiModel: apiModel)
        }
      }
      // initialize on first appearance
      .onAppear() { viewStore.send(.onAppear) }
            
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
      
      .onDisappear {
        viewStore.send(.closeOtherWindows)
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
//    .frame(minWidth: 975, minHeight: 400)
    .padding()
  }
}
