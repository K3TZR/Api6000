//
//  InterlockSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/1/22.
//

import SwiftUI

import FlexApi

struct InterlockSubView: View {
  @ObservedObject var interlock: Interlock
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      HeadingView()
      DetailView(interlock: interlock)
    }
    .padding(.leading, 20)
  }
}

private struct HeadingView: View {
  
  var body: some View {
    GridRow {
      Group {
        Text("INTERLOCK")
        Text("Tx / Delay")
        Text("Tx1 / Delay")
        Text("Tx2 / Delay")
        Text("Tx3 / Delay")
        Text("Acc / Delay")
        Text("Acc Req / Pol")
        Text("Rca Req / Pol")
      }
      .frame(width: 100, alignment: .leading)
    }
  }
}

private struct DetailView: View {
  @ObservedObject var interlock: Interlock
  
  var body: some View {
    GridRow {
      Group {
        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        HStack(spacing: 5) {
          Text(interlock.txAllowed ? "Y" : "N").foregroundColor(interlock.txAllowed ? .green : .red)
          Text("/")
          Text(String(format: "%#4d", interlock.txDelay)).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text(interlock.tx1Enabled ? "Y" : "N").foregroundColor(interlock.tx1Enabled ? .green : .red)
          Text("/")
          Text(String(format: "%#4d", interlock.tx1Delay)).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text(interlock.tx2Enabled ? "Y" : "N").foregroundColor(interlock.tx2Enabled ? .green : .red)
          Text("/")
          Text(String(format: "%#4d", interlock.tx2Delay)).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text(interlock.tx3Enabled ? "Y" : "N").foregroundColor(interlock.tx3Enabled ? .green : .red)
          Text("/")
          Text(String(format: "%#4d", interlock.tx3Delay)).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text(interlock.accTxEnabled ? "Y" : "N").foregroundColor(interlock.accTxEnabled ? .green : .red)
          Text("/")
          Text(String(format: "%#4d", interlock.accTxDelay)).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text(interlock.accTxReqEnabled ? "Y" : "N").foregroundColor(interlock.accTxReqEnabled ? .green : .red)
          Text("/")
          Text(interlock.accTxReqPolarity ? " + " : " - ").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text(interlock.rcaTxReqEnabled ? "Y" : "N").foregroundColor(interlock.rcaTxReqEnabled ? .green : .red)
          Text("/")
          Text(interlock.rcaTxReqPolarity ? " + " : " - ").foregroundColor(.green)
        }
      }
      .frame(width: 100, alignment: .leading)
    }
  }
}

struct InterlockSubView_Previews: PreviewProvider {
  static var previews: some View {
    InterlockSubView(interlock: Interlock())
  }
}

// amplifier = ""
// reason = ""
// source = ""
// state = ""
// timeout = 0
// txClientHandle: Handle = 0
