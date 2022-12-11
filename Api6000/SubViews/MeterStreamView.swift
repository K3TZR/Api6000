//
//  MeterStreamView.swift
//  Api6000Tester-C
//
//  Created by Douglas Adams on 9/23/22.
//

import ComposableArchitecture
import SwiftUI

import Shared
import Objects

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterStreamView: View {
  @ObservedObject var apiModel: ApiModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("METERS")
          Text("\(apiModel.meterStreamId == 0 ? "0x--------" : apiModel.meterStreamId.hex)").foregroundColor(.green)
          HStack(spacing: 5) {
            Text("Streaming")
            Text(apiModel.meterStreamId == 0 ? "N" : "Y").foregroundColor(apiModel.meterStreamId == 0 ? .red : .green)
          }
        }.frame(width: 100, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

struct MeterStreamView_Previews: PreviewProvider {
  static var previews: some View {
    MeterStreamView(apiModel: ApiModel())
  }
}
