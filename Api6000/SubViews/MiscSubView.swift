//
//  MiscSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/20/22.
//

import SwiftUI

import FlexApi

struct MiscSubView: View {
  @ObservedObject var radio: Radio
  
  func stringArrayToString( _ list: [String]) -> String {
    let str = list.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  func uint32ArrayToString( _ list: [UInt32]) -> String {
    let str = list.reduce("") {String($0) + String($1) + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
    
    HStack {
      VStack(alignment: .leading) {
        Text("Software Version")
        Text("Hardware Version")
        Text("Antenna List")
        Text("Microphone List")
        Text("Radio Uptime")
      }.frame(width: 150)
      
      VStack(alignment: .leading) {
        Text(radio.softwareVersion)
        Text(radio.hardwareVersion ?? "Unknown")
        Text(stringArrayToString(radio.antList))
        Text(stringArrayToString(radio.micList))
        Text("\(radio.uptime) (value at time of this connection)")
      }
    }
    .padding(.leading, 40)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

//struct MiscSubView_Previews: PreviewProvider {
//  static var previews: some View {
//    MiscSubView(radio: Radio(Packet(), command: Tcp.shared, stream: Udp.shared) )
//      .frame(minWidth: 1000)
//      .padding()
//  }
//}
