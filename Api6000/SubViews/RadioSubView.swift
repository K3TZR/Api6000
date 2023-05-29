//
//  RadioSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApi
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct RadioSubView: View {
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var objectModel: ObjectModel
  @ObservedObject var streamModel: StreamModel
//  @ObservedObject var packet: Packet
  @ObservedObject var radio: Radio

  @State var showSubView = true
  
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        HStack(spacing: 20) {
          Image(systemName: showSubView ? "chevron.down" : "chevron.right")
            .help("          Tap to toggle details")
            .onTapGesture(perform: { showSubView.toggle() })
          Text(" RADIO   ").foregroundColor(radio.packet.source == .local ? .blue : .red)
            .font(.title)
            .help("          Tap to toggle details")
            .onTapGesture(perform: { showSubView.toggle() })
          Text(radio.packet.nickname)
            .foregroundColor(radio.packet.source == .local ? .blue : .red)
          
          Line1View(radio: radio)
        }
        Line2View(apiModel: apiModel)
        if showSubView {
          Divider().background(radio.packet.source == .local ? .blue : .red)
          DetailView(apiModel: apiModel, objectModel: objectModel, streamModel: streamModel)
        }
      }
    }
  }
}

private struct Line1View: View {
  @ObservedObject var radio: Radio
  
  var body: some View {
    
    HStack(spacing: 5) {
      Text("Connection")
      Text(radio.packet.source.rawValue)
        .foregroundColor(radio.packet.source == .local ? .green : .red)
    }
    HStack(spacing: 5) {
      Text("Ip")
      Text(radio.packet.publicIp).foregroundColor(.green)
    }
    HStack(spacing: 5) {
      Text("FW")
      Text(radio.packet.version + "\(radio.alpha ? "(alpha)" : "")").foregroundColor(radio.alpha ? .red : .green)
    }
    HStack(spacing: 5) {
      Text("Model")
      Text(radio.packet.model).foregroundColor(.green)
    }
    HStack(spacing: 5) {
      Text("Serial")
      Text(radio.packet.serial).foregroundColor(.green)
    }
    .frame(alignment: .leading)
  }
}

private struct Line2View: View {
  @ObservedObject var apiModel: ApiModel

  func stringArrayToString( _ list: [String]?) -> String {
    guard list != nil else { return "Unknown"}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  func uint32ArrayToString( _ list: [UInt32]) -> String {
    let str = list.reduce("") {String($0) + String($1) + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
    HStack(spacing: 20) {
      Text("").frame(width: 120)
      
      HStack(spacing: 5) {
        Text("Ant List")
        Text(stringArrayToString(apiModel.antList)).foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("Mic List")
        Text(stringArrayToString(apiModel.micList)).foregroundColor(.green)
      }
      
      if let radio = apiModel.radio {
        HStack(spacing: 5) {
          Text("Tnf Enabled")
          Text(radio.tnfsEnabled ? "Y" : "N").foregroundColor(radio.tnfsEnabled ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("HW")
          Text(radio.hardwareVersion ?? "").foregroundColor(.green)
        }
      }
      
      HStack(spacing: 5) {
        Text("Uptime")
        Text("\(apiModel.uptime)").foregroundColor(.green)
        Text("(seconds)")
      }
    }
  }
}

private struct DetailView: View {
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var objectModel: ObjectModel
  @ObservedObject var streamModel: StreamModel

  var body: some View {
    
    if apiModel.radio != nil {
      VStack(alignment: .leading) {
        AtuSubView(atu: objectModel.atu, apiModel: apiModel)
        GpsSubView(gps: objectModel.gps, radio: apiModel.radio!)
        MeterStreamSubView(streamModel: streamModel)
        TransmitSubView(transmit: objectModel.transmit)
        TnfSubView(objectModel: objectModel)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct RadioSubView_Previews: PreviewProvider {
  static var previews: some View {
    RadioSubView(apiModel: ApiModel(), objectModel: ObjectModel(), streamModel: StreamModel(), radio: Radio(Packet()))
    .frame(minWidth: 1000)
  }
}
