//
//  Method.swift
//  RuntimeUtils
//
//  Copyright © 2015 Alice Atlas. See LICENSE.md
//

import ObjectiveC

public struct Method: Wrapper {
    let method: ObjectiveC.Method
    init(_ method: ObjectiveC.Method) { self.method = method }
    
    public var selector: Selector { return method_getName(method) }
    public var numArguments: Int { return Int(method_getNumberOfArguments(method)) - 2 }
    
    public var typeEncoding: String {
        return String.fromCString(method_getTypeEncoding(method))!
    }
    
    public var decodedTypes: (returnType: String, argTypes: ArraySlice<String>)? {
        return decodeMethodTypes(typeEncoding)
    }
    
    public var declaration: String {
        if let (returnType, argTypes) = decodedTypes {
            var sel = String(selector)
            if !argTypes.isEmpty {
                let components = split(sel.characters, allowEmptySlices: true, isSeparator: {$0 == ":"}).map(String.init)
                var out: [String] = []
                for (i, (component, type)) in zip(components, argTypes).enumerate() {
                    out.append("\(component):(\(type))arg\(i)")
                }
                sel = " ".join(out)
            }
            return "(\(returnType))\(sel)"
        }
        return "\(selector) /* \(typeEncoding) */"
    }
}