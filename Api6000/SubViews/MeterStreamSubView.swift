//
//  MeterStreamSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 9/23/22.
//

import ComposableArchitecture
import SwiftUI

import Shared
import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterStreamSubView: View {
  @ObservedObject var streamModel: StreamModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("METERS")
          Text("Stream Id")
          Text(streamModel.meterStream == nil ? "0x--------" : streamModel.meterStream!.id.hex ).foregroundColor(.green)
          HStack(spacing: 5) {
            Text("Streaming")
            Text(streamModel.meterStream == nil ? "N" : "Y").foregroundColor(streamModel.meterStream == nil ? .red : .green)
          }
        }.frame(width: 100, alignment: .leading)
      }
    }.padding(.leading, 20)
  }
}

struct MeterStreamSubView_Previews: PreviewProvider {
  static var previews: some View {
    MeterStreamSubView(streamModel: StreamModel())
  }
}
