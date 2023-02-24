//
//  RadioView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import Objects
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct RadioView: View {
  @ObservedObject var apiModel: ApiModel
  @ObservedObject var packet: Packet
  @ObservedObject var radio: Radio

  @State var showSubView = true
  
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        HStack(spacing: 20) {
          Image(systemName: showSubView ? "chevron.down" : "chevron.right")
            .help("          Tap to toggle details")
            .onTapGesture(perform: { showSubView.toggle() })
          Text(" RADIO   ").foregroundColor(packet.source == .local ? .blue : .red)
            .font(.title)
            .help("          Tap to toggle details")
            .onTapGesture(perform: { showSubView.toggle() })
          Text(packet.nickname)
            .foregroundColor(packet.source == .local ? .blue : .red)
          
          Line1View(packet: packet, radio: radio)
        }
        Line2View(radio: radio)
        if showSubView {
          Divider().background(packet.source == .local ? .blue : .red)
          DetailSubView(apiModel: apiModel)
        }
      }
    }
  }
}

private struct Line1View: View {
  @ObservedObject var packet: Packet
  @ObservedObject var radio: Radio
  
  var body: some View {
    
    HStack(spacing: 5) {
      Text("Connection")
      Text(packet.source.rawValue)
        .foregroundColor(packet.source == .local ? .green : .red)
    }
    HStack(spacing: 5) {
      Text("Ip")
      Text(packet.publicIp).foregroundColor(.green)
    }
    HStack(spacing: 5) {
      Text("FW")
      Text(packet.version + "\(radio.alpha ? "(alpha)" : "")").foregroundColor(radio.alpha ? .red : .green)
    }
    HStack(spacing: 5) {
      Text("Model")
      Text(packet.model).foregroundColor(.green)
    }
    HStack(spacing: 5) {
      Text("Serial")
      Text(packet.serial).foregroundColor(.green)
    }
    .frame(alignment: .leading)
  }
}

private struct Line2View: View {
  @ObservedObject var radio: Radio

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
        Text(stringArrayToString(radio.antennaList)).foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("Mic List")
        Text(stringArrayToString(radio.micList)).foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("Tnf Enabled")
        Text(radio.tnfsEnabled ? "Y" : "N").foregroundColor(radio.tnfsEnabled ? .green : .red)
      }
      
      HStack(spacing: 5) {
        Text("HW")
        Text(radio.hardwareVersion ?? "").foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("Uptime")
        Text("\(radio.uptime)").foregroundColor(.green)
        Text("(seconds)")
      }
    }
  }
}

private struct DetailSubView: View {
  @ObservedObject var apiModel: ApiModel
  
  var body: some View {
    
    if apiModel.radio != nil {
      VStack(alignment: .leading) {
        AtuView(atu: apiModel.atu, radio: apiModel.radio!)
        GpsView(gps: apiModel.gps, radio: apiModel.radio!)
        MeterStreamView(apiModel: apiModel)
        TransmitView(transmit: apiModel.transmit)
        TnfView(apiModel: apiModel)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct RadioView_Previews: PreviewProvider {
  static var previews: some View {
    RadioView(apiModel: ApiModel(), packet: Packet(), radio: Radio(Packet()))
    .frame(minWidth: 1000)
  }
}
