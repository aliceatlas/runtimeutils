//
//  Property.swift
//  RuntimeUtils
//
//  Copyright © 2015 Alice Atlas. See LICENSE.md
//

import ObjectiveC

private let makePropertyAttrPairs = _copyWrap(property_copyAttributeList) { (String.fromCString($0.name)!, String.fromCString($0.value)!) }

public struct Property: Wrapper {
    internal let prop: objc_property_t
    internal init(_ prop: objc_property_t) { self.prop = prop }
    
    public var name: String { return String.fromCString(property_getName(prop))! }
    public var attrString: String { return String.fromCString(property_getAttributes(prop))! }
    public var attributes: [String: String] {
        var dict: [String: String] = [:]
        for (name, value) in makePropertyAttrPairs(prop) {
            dict[name] = value
        }
        return dict
    }
    public enum Attribute: Hashable, Equatable {
        case ReadOnly, Copy, Retain, Nonatomic, Dynamic, Weak, GarbageCollectionEligible
        case Getter(String)
        case Setter(String)
        case OldStyleType(String)
        case Unknown(String, String)
        
        init(_ key: String, _ value: String = "") {
            switch key {
            case "R", "C", "&", "N", "D", "W", "P":
                assert(value == "")
            case "G", "S", "t":
                assert(value != "")
            default:
                break
            }
            switch key {
                case "R": self = .ReadOnly
                case "C": self = .Copy
                case "&": self = .Retain
                case "N": self = .Nonatomic
                case "D": self = .Dynamic
                case "W": self = .Weak
                case "P": self = .GarbageCollectionEligible
                case "G": self = .Getter(value)
                case "S": self = .Setter(value)
                case "t": self = .OldStyleType(value)
                default:  self = .Unknown(key, value)
            }
        }
        
        public var hashValue: Int {
            return declaration.hashValue
        }
        
        public var declaration: String {
            switch self {
                case .ReadOnly:                    return "readonly"
                case .Copy:                        return "copy"
                case .Retain:                      return "retain"
                case .Nonatomic:                   return "nonatomic"
                case .Dynamic:                     return "@dynamic"
                case .Weak:                        return "__weak"
                case .GarbageCollectionEligible:   return "?(P)"
                case .Getter(let name):            return "getter=" + name
                case .Setter(let name):            return "setter=" + name
                case .OldStyleType(let string):    return "?(t=\(string))"
                case .Unknown(let key, let value): return "?(\(key)=\(value))"
            }
        }
    }
    public var unpackedAttributes: [Attribute] {
        return attributes.filter{$0.0 != "T"}.map(Attribute.init)
    }
    
    public var declaration: String {
        var attrs = ", ".join(unpackedAttributes.map{$0.declaration})
        if attrs != "" { attrs = "(\(attrs)) " }
        let type = prepareType(decodedType ?? "?(\(typeEncoding))")
        return "@property \(attrs)\(type)\(name)"
    }
    
    public var typeEncoding: String {
        return "T".withCString {
            return String.fromCString(property_copyAttributeValue(prop, $0))!
        }
    }
    
    public var decodedType: String? {
        return decodeType(typeEncoding)
    }
}

public func ==(left: Property.Attribute, right: Property.Attribute) -> Bool {
    return left.declaration == right.declaration
}