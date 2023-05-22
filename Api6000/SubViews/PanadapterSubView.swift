//
//  PanadapterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct PanadapterSubView: View {
  @ObservedObject var objectModel: ObjectModel
  @ObservedObject var streamModel: StreamModel
  let handle: UInt32
  let showMeters: Bool


  var body: some View {
    
    if objectModel.panadapters.count == 0 {
      HStack(spacing: 20) {
        Text("PANADAPTER").frame(width: 80, alignment: .leading)
        Text("None present").foregroundColor(.red)
      }
      .padding(.leading, 40)
      
    } else {
      ForEach(objectModel.panadapters.filter { $0.clientHandle == handle }) { panadapter in
        VStack(alignment: .leading) {
          // Panadapter
          PanadapterDetailView(panadapter: panadapter)
          
          // corresponding Waterfall
          ForEach(objectModel.waterfalls.filter { $0.panadapterId == panadapter.id} ) { waterfall in
            WaterfallDetailView(waterfall: waterfall)
          }
          
          // corresponding Slice(s)
          ForEach(objectModel.slices.filter { $0.panadapterId == panadapter.id}) { slice in
            SliceDetailView(slice: slice)
            
            // slice meter(s)
            if showMeters { MeterSubView(streamModel: streamModel, sliceId: slice.id, sliceClientHandle: slice.clientHandle, handle: handle) }
          }
        }
      }
      .padding(.leading, 40)
    }
  }
}

private struct PanadapterDetailView: View {
  @ObservedObject var panadapter: Panadapter
  
  var body: some View {
    HStack(spacing: 20) {
      
      Text("PANADAPTER").frame(width: 80, alignment: .leading)
      
      Group {
        HStack(spacing: 5) {
          Text("Streaming")
          Text(panadapter.isStreaming ? "Y" : "N").foregroundColor(panadapter.isStreaming ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("Id")
          Text(panadapter.isStreaming ? panadapter.id.hex : "0x--------").padding(.leading, 5).foregroundColor(.secondary)
        }
        
        HStack(spacing: 5) {
          Text("Width")
          Text("\(panadapter.bandwidth)").foregroundColor(.secondary)
        }
      }.frame(width: 100, alignment: .leading)
      
      HStack(spacing: 5) {
        Text("Center")
        Text("\(panadapter.center)").foregroundColor(.secondary)
      }
    }
  }
}

private struct WaterfallDetailView: View {
  @ObservedObject var waterfall: Waterfall
  
  var body: some View {
    HStack(spacing: 20) {
      Text("WATERFALL").frame(width: 80, alignment: .leading)
      
      Group {
        HStack(spacing: 5) {
          Text("Streaming")
          Text(waterfall.isStreaming ? "Y" : "N").foregroundColor(waterfall.isStreaming ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("Id")
          Text(waterfall.isStreaming ? waterfall.id.hex : "0x--------").padding(.leading, 5).foregroundColor(.secondary)
        }

        HStack(spacing: 5) {
          Text("Auto Black")
          Text(waterfall.autoBlackEnabled ? "Y" : "N").foregroundColor(waterfall.autoBlackEnabled ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("Color Gain")
          Text("\(waterfall.colorGain)").foregroundColor(.secondary)
        }
        
        HStack(spacing: 5) {
          Text("Black Level")
          Text("\(waterfall.blackLevel)").foregroundColor(.secondary)
        }
        
        HStack(spacing: 5) {
          Text("Duration")
          Text("\(waterfall.lineDuration)").foregroundColor(.secondary)
        }
      }.frame(width: 100, alignment: .leading)
    }
  }
}

private struct SliceDetailView: View {
  @ObservedObject var slice: Slice
  
  func stringArrayToString( _ list: [String]?) -> String {
    
    guard list != nil else { return "Unknown"}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 20) {
        HStack(spacing: 5) {
          Text("SLICE")
          Text(String(format: "%02d", slice.id)).foregroundColor(.green)
        }.frame(width: 80, alignment: .leading)
        
        HStack(spacing: 5) {
          Text("Frequency").frame(width: 110, alignment: .leading)
          Text("\(slice.frequency)").foregroundColor(.secondary).frame(width: 105, alignment: .trailing)
        }
        
        Group {
          HStack(spacing: 5) {
            Text("Mode")
            Text("\(slice.mode)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Rx Ant")
            Text("\(slice.rxAnt)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Tx Ant")
            Text("\(slice.txAnt)").foregroundColor(.secondary)
          }
        }.frame(width: 100, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("Low")
            Text("\(slice.filterLow)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("High")
            Text("\(slice.filterHigh)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Active")
            Text(slice.active ? "Y" : "N").foregroundColor(slice.active ? .green : .red)
          }
          
          HStack(spacing: 5) {
            Text("Locked")
            Text(slice.locked ? "Y" : "N").foregroundColor(slice.locked ? .green : .red)
          }
        }.frame(width: 100, alignment: .leading)
      }
      HStack(spacing: 20) {
        Text("").frame(width: 80, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("DAX_channel")
            Text("\(slice.daxChannel)").foregroundColor(.green)
          }
          
          HStack(spacing: 5) {
            Text("DAX_clients")
            Text("\(slice.daxClients)").foregroundColor(.green)
          }
        }.frame(width: 100, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("Rx Ant List")
            Text(stringArrayToString(slice.rxAntList)).foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Tx Ant List")
            Text(stringArrayToString(slice.txAntList)).foregroundColor(.secondary)
          }
        }.frame(width: 340, alignment: .leading)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct PanadapterSubView_Previews: PreviewProvider {
  static var previews: some View {
    PanadapterSubView(
      objectModel: ObjectModel(), streamModel: StreamModel(),
      handle: 1,
      showMeters: true
    )
    .frame(minWidth: 1000)
    .padding()
  }
}
