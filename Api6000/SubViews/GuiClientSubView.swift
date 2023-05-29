//
//  GuiClientSubView.swift
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

struct GuiClientSubView: View {
  let store: StoreOf<ApiModule>
  @ObservedObject var apiModel: ApiModel

  var body: some View {
    VStack(alignment: .leading) {
//      if apiModel.activePacket == nil {
//        Text("No active packet")
//      } else {
      if let radio = apiModel.radio {
        ForEach(radio.packet.guiClients, id: \.id) { guiClient in
          DetailView(store: store, guiClient: guiClient)
        }
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
    if showSubView { GuiClientDetailView(store: store, handle: guiClient.handle) }
  }
}

struct GuiClientDetailView: View {
  let store: StoreOf<ApiModule>
  
//  struct ViewState: Equatable {
//    let objectFilter: ObjectFilter
//    init(state: ApiModule.State) {
//      self.objectFilter = state.objectFilter
//    }
//  }
  
  @Dependency(\.apiModel) var apiModel
  @Dependency(\.objectModel) var objectModel
  @Dependency(\.streamModel) var streamModel

  @AppStorage("objectFilter") var objectFilter = ObjectFilter.core.rawValue
  
  let handle: UInt32
  
  var body: some View {
    
    WithViewStore(self.store, observe: {$0}) { viewStore in
      switch objectFilter {
        
      case ObjectFilter.core.rawValue:
        PanadapterSubView(objectModel: objectModel, streamModel: streamModel, handle: handle, showMeters: true)
        
      case ObjectFilter.coreNoMeters.rawValue:
        PanadapterSubView(objectModel: objectModel, streamModel: streamModel, handle: handle, showMeters: false)
        
      case ObjectFilter.amplifiers.rawValue:        AmplifierSubView()
      case ObjectFilter.bandSettings.rawValue:      BandSettingSubView(objectModel: objectModel)
      case ObjectFilter.cwx.rawValue:               CwxSubView(cwx: objectModel.cwx)
      case ObjectFilter.equalizers.rawValue:        EqualizerSubView(objectModel: objectModel)
      case ObjectFilter.interlock.rawValue:         InterlockSubView(interlock: objectModel.interlock)
      case ObjectFilter.memories.rawValue:          MemorySubView(objectModel: objectModel)
      case ObjectFilter.meters.rawValue:            MeterSubView(streamModel: streamModel, sliceId: nil, sliceClientHandle: nil, handle: handle)
      case ObjectFilter.misc.rawValue:
        if apiModel.radio != nil {
          MiscSubView(radio: apiModel.radio!)
        } else {
          EmptyView()
        }
      case ObjectFilter.network.rawValue:           NetworkSubView()
      case ObjectFilter.profiles.rawValue:          ProfileSubView(objectModel: objectModel)
      case ObjectFilter.streams.rawValue:           StreamSubView(objectModel: objectModel, streamModel: streamModel, handle: handle)
      case ObjectFilter.usbCable.rawValue:          UsbCableSubView(objectModel: objectModel)
      case ObjectFilter.wan.rawValue:               WanSubView(wan: objectModel.wan)
      case ObjectFilter.waveforms.rawValue:         WaveformSubView(waveform: objectModel.waveform)
      case ObjectFilter.xvtrs.rawValue:             XvtrSubView(objectModel: objectModel)
      default:
        PanadapterSubView(objectModel: objectModel, streamModel: streamModel, handle: handle, showMeters: true)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct GuiClientSubView_Previews: PreviewProvider {
  static var previews: some View {
    GuiClientSubView( store:
                    Store(initialState: ApiModule.State(),
                          reducer: ApiModule()),
                   apiModel: ApiModel())
    .frame(minWidth: 975)
    .padding()
  }
}
