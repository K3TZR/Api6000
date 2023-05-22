//
//  WaveformSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/4/22.
//

import SwiftUI

import FlexApi

struct WaveformSubView: View {
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

struct WaveformSubView_Previews: PreviewProvider {
  static var previews: some View {
    WaveformSubView(waveform: Waveform())
    .frame(minWidth: 1000)
    .padding()
  }
}
