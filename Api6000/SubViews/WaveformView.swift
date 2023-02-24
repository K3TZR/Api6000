//
//  WaveformView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/4/22.
//

import SwiftUI

import Objects

struct WaveformView: View {
  @ObservedObject var waveform: Waveform
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      if waveform.list.isEmpty {
        GridRow {
          Group {
            Text("WAVEFORMs")
            Text("None present").foregroundColor(.red)
          }.frame(width: 100, alignment: .leading)
        }
        
      } else {
        GridRow {
          Group {
            Text("WAVEFORMS").frame(width: 100, alignment: .leading)
            Text(waveform.list)
          }
        }
      }
    }.padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

struct WaveformView_Previews: PreviewProvider {
  static var previews: some View {
    WaveformView(waveform: Waveform())
    .frame(minWidth: 1000)
    .padding()
  }
}
