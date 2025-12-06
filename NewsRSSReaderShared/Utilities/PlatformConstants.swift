//
//  PlatformConstants.swift
//  NewsRSSReaderShared
//
//  Platform-aware sizing helpers for iOS and watchOS
//

import Foundation
import CoreGraphics

/// Returns font size depending on platform
/// - Parameters:
///   - ios: Size for iOS
///   - watch: Size for watchOS
/// - Returns: Size for current platform
public func platformSize(ios: CGFloat, watch: CGFloat) -> CGFloat {
    #if os(iOS)
    return ios
    #elseif os(watchOS)
    return watch
    #endif
}

/// Returns padding depending on platform
/// - Parameter base: Base padding for iOS
/// - Returns: Padding for current platform (watchOS = base / 2)
public func platformPadding(base: CGFloat) -> CGFloat {
    #if os(iOS)
    return base
    #elseif os(watchOS)
    return base / 2
    #endif
}
