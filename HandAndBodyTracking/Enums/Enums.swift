//
//  Enums.swift
//  HandAndBodyTracking
//
//  Created by Michele Manniello on 27/09/23.
//

import Foundation

enum FingerCombination: String {
    case thumIndex
    case thumbMiddle
    case thumbRing
    case thumbLittle
    case none
    
    var rowValue: String {
        switch self {
        case .thumIndex:
            return "PolliceIndice"
        case .thumbMiddle:
            return "PolliceMedio"
        case .thumbRing:
            return "PolliceAnulare"
        case .thumbLittle:
            return "PolliceMignolo"
        case .none:
            return ""
        }
    }
}
