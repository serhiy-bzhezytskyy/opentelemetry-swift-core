/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation

/// Bounds what a baggage propagator accepts from a carrier: at most `maxEntries` entries, whose
/// keys and values together take at most `maxBytes` of UTF-8. An entry that does not fit is
/// refused and not counted.
struct BaggageExtractLimits {
  /// The W3C Baggage limits (https://www.w3.org/TR/baggage/#limits), borrowed for formats that
  /// define none of their own.
  static let w3cMaxEntries = 64
  static let w3cMaxBytes = 8192

  let maxEntries: Int
  let maxBytes: Int
  private(set) var entries = 0
  private(set) var bytes = 0

  init(maxEntries: Int = BaggageExtractLimits.w3cMaxEntries, maxBytes: Int = BaggageExtractLimits.w3cMaxBytes) {
    self.maxEntries = maxEntries
    self.maxBytes = maxBytes
  }

  /// Returns whether the entry fits within the limits, and counts it when it does.
  mutating func accept(key: EntryKey, value: EntryValue) -> Bool {
    let size = key.name.utf8.count + value.string.utf8.count
    guard entries < maxEntries, bytes + size <= maxBytes else {
      return false
    }

    entries += 1
    bytes += size
    return true
  }
}
