//
//  SBUGroupChannelPushSettingsModule.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This is the main class for the Group Channel Push Settings Module in Sendbird UIKit.
/// It handles the configuration and behavior of the push settings for group channels.
extension SBUGroupChannelPushSettingsModule {
    // MARK: Properties (Public)
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelPushSettingsModule.Header.Type = SBUGroupChannelPushSettingsModule.Header.self
    /// The module component that shows the list of push setting options
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelPushSettingsModule.List.Type = SBUGroupChannelPushSettingsModule.List.self
}

// MARK: Header
extension SBUGroupChannelPushSettingsModule.Header {
    
}

// MARK: List
extension SBUGroupChannelPushSettingsModule.List {
    
}
