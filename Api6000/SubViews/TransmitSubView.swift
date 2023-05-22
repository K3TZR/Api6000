//
//  TransmitSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct TransmitSubView: View {
  @ObservedObject var transmit: Transmit
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      Group {
        Row1View(transmit: transmit)
        Row2View(transmit: transmit)
        Row3View(transmit: transmit)
      }.frame(width: 100, alignment: .leading)
    }
    .padding(.leading, 20)
  }
}

private struct Row1View: View {
  @ObservedObject var transmit: Transmit
  
  var body: some View {
    
    GridRow {
      Text("TRANSMIT")
      Group {
        HStack(spacing: 5) {
          Text("RF_Power")
          Text("\(transmit.rfPower)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Tune_Power")
          Text("\(transmit.tunePower)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Frequency")
          Text("\(transmit.frequency)").foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          Text("Mon_Level")
          Text("\(transmit.ssbMonitorGain)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Comp_Level")
          Text("\(transmit.companderLevel)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Mic")
          Text("\(transmit.micSelection)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Mic_Level")
          Text("\(transmit.micLevel)").foregroundColor(.green)
        }
      }
    }
  }
}
  
private struct Row2View: View {
  @ObservedObject var transmit: Transmit
  
  var body: some View {
    GridRow {
      Text("")
      HStack(spacing: 5) {
        Text("Proc")
        Text(transmit.speechProcessorEnabled ? "Y" : "N")
          .foregroundColor(transmit.speechProcessorEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Comp")
        Text(transmit.companderEnabled ? "Y" : "N")
          .foregroundColor(transmit.companderEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Mon")
        Text(transmit.txMonitorEnabled ? "Y" : "N")
          .foregroundColor(transmit.txMonitorEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Acc")
        Text(transmit.micAccEnabled ? "Y" : "N")
          .foregroundColor(transmit.micAccEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Dax")
        Text(transmit.daxEnabled ? "Y" : "N")
          .foregroundColor(transmit.daxEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Vox")
        Text(transmit.voxEnabled ? "Y" : "N")
          .foregroundColor(transmit.voxEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Vox_Delay")
        Text("\(transmit.voxDelay)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Vox_Level")
        Text("\(transmit.voxLevel)").foregroundColor(.green)
      }
    }
  }
}
  
private struct Row3View: View {
  @ObservedObject var transmit: Transmit
  
  var body: some View {
    GridRow {
      Text("")
      HStack(spacing: 5) {
        Text("Sidetone")
        Text(transmit.cwSidetoneEnabled ? "Y" : "N").foregroundColor(transmit.cwSidetoneEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Level")
        Text("\(transmit.cwMonitorGain)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Pan")
        Text("\(transmit.cwMonitorPan)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Pitch")
        Text("\(transmit.cwPitch)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Speed")
        Text("\(transmit.cwSpeed)").foregroundColor(.green)
      }
    }
  }
}
  
  // ----------------------------------------------------------------------------
  // MARK: - Preview
  
  //struct TransmitSubView_Previews: PreviewProvider {
  //  static var previews: some View {
  //    TransmitSubView(transmit: Transmit.shared)
  //      .frame(minWidth: 1000)
  //      .padding()
  //  }
  //}
