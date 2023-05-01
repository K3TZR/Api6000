//
//  GuiClientView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import Listener
import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var packet: Packet

  var body: some View {
    VStack(alignment: .leading) {
//      if apiModel.activePacket == nil {
//        Text("No active packet")
//      } else {
        ForEach(packet.guiClients, id: \.id) { guiClient in
          DetailView(store: store, guiClient: guiClient)
        }
//      }
    }
  }
}

private struct DetailView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var guiClient: GuiClient
  
  @State var showSubView = true
  
  var body: some View {
    Divider().background(Color(.yellow))
    HStack(spacing: 20) {
      
      HStack(spacing: 0) {
        Image(systemName: showSubView ? "chevron.down" : "chevron.right")
          .help("          Tap to toggle details")
          .onTapGesture(perform: { showSubView.toggle() })
        Text(" Gui   ").foregroundColor(.yellow)
          .font(.title)
          .help("          Tap to toggle details")
          .onTapGesture(perform: { showSubView.toggle() })

        Text("\(guiClient.station)").foregroundColor(.yellow)
      }
      
      HStack(spacing: 5) {
        Text("Program")
        Text("\(guiClient.program)").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Handle")
        Text(guiClient.handle.hex).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("ClientId")
        Text(guiClient.clientId ?? "Unknown").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("LocalPtt")
        Text(guiClient.isLocalPtt ? "Y" : "N").foregroundColor(guiClient.isLocalPtt ? .green : .red)
      }
    }
    if showSubView { GuiClientSubView(store: store, handle: guiClient.handle) }
  }
}

struct GuiClientSubView: View {
  let store: StoreOf<ApiModule>
  
  struct ViewState: Equatable {
    let objectFilter: ObjectFilter
    init(state: ApiModule.State) {
      self.objectFilter = state.objectFilter
    }
  }
  
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel

  let handle: UInt32
  
  var body: some View {
    
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      switch viewStore.objectFilter {
        
      case ObjectFilter.core:
        PanadapterView(objectModel: objectModel, streamModel: streamModel, handle: handle, showMeters: true)
        
      case ObjectFilter.coreNoMeters:
        PanadapterView(objectModel: objectModel, streamModel: streamModel, handle: handle, showMeters: false)
        
      case ObjectFilter.amplifiers:        AmplifierView()
      case ObjectFilter.bandSettings:      BandSettingView(objectModel: objectModel)
      case ObjectFilter.cwx:               CwxView(cwx: objectModel.cwx)
      case ObjectFilter.equalizers:        EqualizerView(objectModel: objectModel)
      case ObjectFilter.interlock:         InterlockView(interlock: objectModel.interlock)
      case ObjectFilter.memories:          MemoryView(objectModel: objectModel)
      case ObjectFilter.meters:            MeterView(streamModel: streamModel, sliceId: nil, sliceClientHandle: nil, handle: handle)
      case ObjectFilter.misc:
        if objectModel.radio != nil {
          MiscView(radio: objectModel.radio!)
        } else {
          EmptyView()
        }
      case ObjectFilter.network:           NetworkView()
      case ObjectFilter.profiles:          ProfileView(objectModel: objectModel)
      case ObjectFilter.streams:           StreamView(objectModel: objectModel, streamModel: streamModel, handle: handle)
      case ObjectFilter.usbCable:          UsbCableView(objectModel: objectModel)
      case ObjectFilter.wan:               WanView(wan: objectModel.wan)
      case ObjectFilter.waveforms:         WaveformView(waveform: objectModel.waveform)
      case ObjectFilter.xvtrs:             XvtrView(objectModel: objectModel)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct GuiClientView_Previews: PreviewProvider {
  static var previews: some View {
    GuiClientView( store:
                    Store(initialState: ApiModule.State(),
                          reducer: ApiModule()),
                   apiModel: ApiModel(), packet: Packet())
    .frame(minWidth: 975)
    .padding()
  }
}
