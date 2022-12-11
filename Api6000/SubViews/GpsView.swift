//
//  GpsView.swift
//  Api6000Components/ApiViewer/Subviews/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import Objects
import Shared

// ----------------------------------------------------------------------------
// MARK: - View

struct GpsView: View {
  @ObservedObject var gps: Gps
  @ObservedObject var radio: Radio

  let post = String(repeating: " ", count: 8)
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("GPS")
          if radio.gpsPresent {
            Text("Not implemented").foregroundColor(.red)
          } else {
            Text("Not installed").foregroundColor(.red)
          }
        }
        .frame(width: 100, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct GpsView_Previews: PreviewProvider {
  static var previews: some View {
    GpsView(gps: Gps(), radio: Radio(Packet()))
  }
}