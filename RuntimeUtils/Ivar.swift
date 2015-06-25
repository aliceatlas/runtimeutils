//
//  Ivar.swift
//  RuntimeUtils
//
//  Copyright © 2015 Alice Atlas. See LICENSE.md
//

import ObjectiveC

public struct Ivar: Wrapper {
    let ivar: ObjectiveC.Ivar
    init(_ ivar: ObjectiveC.Ivar) { self.ivar = ivar }
    
    public var name: String { return String.fromCString(ivar_getName(ivar))! }
    
    public var typeEncoding: String {
        return String.fromCString(ivar_getTypeEncoding(ivar))!
    }
    
    public var decodedType: String? {
        return decodeType(typeEncoding)
    }
    
    public var declaration: String {
        let type = prepareType(decodedType ?? "?(\(typeEncoding))")
        return "\(type)\(name)"
    }
}
