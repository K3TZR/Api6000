//
//  ObjectsView.swift
//  Api6000Components/ApiViewer/Subviews/ViewerSubViews
//
//  Created by Douglas Adams on 1/8/22.
//

import ComposableArchitecture
import SwiftUI

import Listener
import Objects
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct ObjectsView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var apiModel: ApiModel
  
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
     
      if apiModel.activePacket != nil && apiModel.radio != nil {
        ScrollView([.horizontal, .vertical]) {
          VStack(alignment: .leading) {
            RadioView(apiModel: apiModel, packet: apiModel.activePacket!, radio: apiModel.radio!)
            GuiClientView(store: store, apiModel: apiModel)
            //          if viewStore.isGui == false { TesterView() }
          }
        }
        .frame(minWidth: 900, maxWidth: .infinity, alignment: .leading)
        .font(.system(size: viewStore.fontSize, weight: .regular, design: .monospaced))

      }
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
          reducer: ApiModule()),
      apiModel: ApiModel())
    .frame(minWidth: 975)
    .padding()
  }
}
