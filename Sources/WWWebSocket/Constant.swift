//
//  Constant.swift
//  WWWebSocket
//
//  Created by William.Weng on 2023/4/24.
//

import UIKit

// MARK: - Constant
final class Constant: NSObject {}

// MARK: - typealias
extension Constant {

    enum MyError: Error {
        case notUrlFormat
        case isEmpty
    }
}
