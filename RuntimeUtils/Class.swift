//
//  Class.swift
//  RuntimeUtils
//
//  Copyright © 2015 Alice Atlas. See LICENSE.md
//

import ObjectiveC

private let makeMethodViews = Method.copyWrap(class_copyMethodList)
private let makePropertyViews = Property.copyWrap(class_copyPropertyList)
private let makeIvarViews = Ivar.copyWrap(class_copyIvarList)

public struct Class<T: AnyObject> {
    public init(_ cls: T.Type) {}
    
    public var metaclass: AnyClass { return object_getClass(T) }
    public var name: String { return String.fromCString(class_getName(T))! }
    
    public var classMethods: [Method] { return makeMethodViews(metaclass) }
    public var instanceMethods: [Method] { return makeMethodViews(T) }
    //public var classProperties: [Property] { return makePropertyViews(metaclass) }
    public var instanceProperties: [Property] { return makePropertyViews(T) }
    //public var classVariables: [Ivar] { return makeIvarViews(metaclass) }
    public var instanceVariables: [Ivar] { return makeIvarViews(T) }
    
    public var declaration: String {
        return joinLines(
            ["@interface \(name) {"],
            instanceVariables.map{"    \($0.declaration);"},
            ["}", ""],
            instanceProperties.map{"\($0.declaration);"},
            classMethods.map{"+ \($0.declaration);"},
            instanceMethods.map{"- \($0.declaration);"},
            ["", "@end"]
        )
    }
}