//
//  Optional+OrNil.swift
//

import Foundation

public extension Optional {
    
    var orNil : String {
        if self == nil {
            return "nil"
        }
        if "\(Wrapped.self)" == "String" {
            return "\"\(self!)\""
        }
        return "\(self!)"
    }
}
