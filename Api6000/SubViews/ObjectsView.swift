//
//  ObjectsView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

import Listener
import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct ObjectsView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var objectModel: ObjectModel
  @ObservedObject var packet: Packet
  @ObservedObject var radio: Radio

  @Dependency(\.listener) var listener

//  struct ViewState: Equatable {
//    let isGui: Bool
//    let fontSize: CGFloat
//    let isStopped: Bool
//    init(state: ApiModule.State) {
//      self.isGui = state.isGui
//      self.fontSize = state.fontSize
//      self.isStopped = state.isStopped
//    }
//  }

  var body: some View {
    
    WithViewStore(self.store, observe: {$0} ) { viewStore in
     
//      if apiModel.activePacket != nil && objectModel.radio != nil {
        ScrollView([.horizontal, .vertical]) {
          VStack(alignment: .leading) {
            RadioView(objectModel: objectModel, packet: packet, radio: radio)
            GuiClientView(store: store, apiModel: apiModel, packet: packet)
            //          if viewStore.isGui == false { TesterView() }
          }
        }
        .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
        .font(.system(size: viewStore.fontSize, weight: .regular, design: .monospaced))

//      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct ObjectsView_Previews: PreviewProvider {

  static var previews: some View {
    ObjectsView(
      store:
        Store(
          initialState: ApiModule.State(),
          reducer: ApiModule()), apiModel: ApiModel(),
      objectModel: ObjectModel(), packet: Packet(), radio: Radio(Packet()))
    .frame(minWidth: 975)
    .padding()
  }
}
