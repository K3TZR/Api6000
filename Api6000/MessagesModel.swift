//
//  MessagesModel.swift
//  Api6000
//
//  Created by Douglas Adams on 10/15/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

import Tcp
import Shared

// ----------------------------------------------------------------------------
// MARK: - Dependency decalarations

extension MessagesModel: DependencyKey {
  public static let liveValue = MessagesModel()
}

extension DependencyValues {
  var messagesModel: MessagesModel {
    get { self[MessagesModel.self] }
//    set { self[MessagesModel.self] = newValue }
  }
}

public final class MessagesModel: ObservableObject {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization (Singleton)
  
//  public static var shared = MessagesModel()
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @Published var filteredMessages = IdentifiedArrayOf<TcpMessage>()

  @AppStorage("showPings") var showPings = false
  @AppStorage("messageFilter") var messageFilter = MessageFilter.all.rawValue
  @AppStorage("messageFilterText") var messageFilterText = ""

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _messages = IdentifiedArrayOf<TcpMessage>()
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Clear all messages
  public func clearAll(_ enabled: Bool = true) {
    if enabled {
      self._messages.removeAll()
      Task { await removeAllFilteredMessages() }
    }
  }

  /// Set the messages filter parameters and re-filter
  public func reFilter(filter: String) {
    messageFilter = filter
    Task { await self.filterMessages() }
  }

  /// Set the messages filter parameters and re-filter
  public func reFilter(filterText: String) {
    messageFilterText = filterText
    Task { await self.filterMessages() }
  }

  /// Begin to process TcpMessages
  public func start() {
    subscribeToTcpMessages()
  }
  
  /// Stop processing TcpMessages
  public func stop() {
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Rebuild the entire filteredMessages array
  @MainActor private func filterMessages() {
    // re-filter the entire messages array
    switch (messageFilter, messageFilterText) {

    case (MessageFilter.all.rawValue, _):        filteredMessages = _messages
    case (MessageFilter.prefix.rawValue, ""):    filteredMessages = _messages
    case (MessageFilter.prefix.rawValue, _):     filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains("|" + messageFilterText) }
    case (MessageFilter.includes.rawValue, _):   filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains(messageFilterText) }
    case (MessageFilter.excludes.rawValue, ""):  filteredMessages = _messages
    case (MessageFilter.excludes.rawValue, _):   filteredMessages = _messages.filter { !$0.text.localizedCaseInsensitiveContains(messageFilterText) }
    case (MessageFilter.command.rawValue, _):    filteredMessages = _messages.filter { $0.text.prefix(1) == "C" }
    case (MessageFilter.S0.rawValue, _):         filteredMessages = _messages.filter { $0.text.prefix(3) == "S0|" }
    case (MessageFilter.status.rawValue, _):     filteredMessages = _messages.filter { $0.text.prefix(1) == "S" && $0.text.prefix(3) != "S0|"}
    case (MessageFilter.reply.rawValue, _):      filteredMessages = _messages.filter { $0.text.prefix(1) == "R" }
    default:                                     filteredMessages = _messages
    }
  }
  
  @MainActor private func removeAllFilteredMessages() {
    self.filteredMessages.removeAll()
  }
}

extension MessagesModel {
  // ----------------------------------------------------------------------------
  // MARK: - Subscription methods

  private func subscribeToTcpMessages()  {
    Task(priority: .high) {
      log("MessagesModel: TcpMessage subscription STARTED", .debug, #function, #file, #line)
      for await msg in Tcp.shared.testerStream {
        process(msg)
      }
      log("MessagesModel: : TcpMessage subscription STOPPED", .debug, #function, #file, #line)
    }
  }

  /// Process a TcpMessage
  /// - Parameter msg: a TcpMessage struct
  private func process(_ msg: TcpMessage) {

    // ignore routine replies (i.e. replies with no error or no attached data)
    func ignoreReply(_ text: String) -> Bool {
      if text.first != "R" { return false }     // not a Reply
      let parts = text.components(separatedBy: "|")
      if parts.count < 3 { return false }       // incomplete
      if parts[1] != kNoError { return false }  // error of some type
      if parts[2] != "" { return false }        // additional data present
      return true                               // otherwise, ignore it
    }

    // ignore received replies unless they are non-zero or contain additional data
    if msg.direction == .received && ignoreReply(msg.text) { return }
    // ignore sent "ping" messages unless showPings is true
    if msg.text.contains("ping") && showPings == false { return }
    // add it to the backing collection
    _messages.append(msg)
    Task {
      await MainActor.run {
        // add it to the published collection (if appropriate)
        switch (messageFilter, messageFilterText) {

        case (MessageFilter.all.rawValue, _):        filteredMessages.append(msg)
        case (MessageFilter.prefix.rawValue, ""):    filteredMessages.append(msg)
        case (MessageFilter.prefix.rawValue, _):     if msg.text.localizedCaseInsensitiveContains("|" + messageFilterText) { filteredMessages.append(msg) }
        case (MessageFilter.includes.rawValue, _):   if msg.text.localizedCaseInsensitiveContains(messageFilterText) { filteredMessages.append(msg) }
        case (MessageFilter.excludes.rawValue, ""):  filteredMessages.append(msg)
        case (MessageFilter.excludes.rawValue, _):   if !msg.text.localizedCaseInsensitiveContains(messageFilterText) { filteredMessages.append(msg) }
        case (MessageFilter.command.rawValue, _):    if msg.text.prefix(1) == "C" { filteredMessages.append(msg) }
        case (MessageFilter.S0.rawValue, _):         if msg.text.prefix(3) == "S0|" { filteredMessages.append(msg) }
        case (MessageFilter.status.rawValue, _):     if msg.text.prefix(1) == "S" && msg.text.prefix(3) != "S0|" { filteredMessages.append(msg) }
        case (MessageFilter.reply.rawValue, _):      if msg.text.prefix(1) == "R" { filteredMessages.append(msg) }
        default:                                     filteredMessages.append(msg)
        }
      }
    }
  }
}
