//
//  TypeEncoding.swift
//  RuntimeUtils
//
//  Copyright © 2015 Alice Atlas. See LICENSE.md
//

public func decodeType(enc: String) -> String? {
    guard let types = decodeTypes(enc) where types.count == 1 else { return nil }
    return types[0]
}

public func decodeTypes(enc: String, _method: Bool = false) -> [String]? {
    var position = enc.startIndex
    var out: [String] = []
    while position < enc.endIndex {
        guard let type = decodeOneType(enc, &position) else { return nil }
        out.append(type)
        if _method {
            decodeNatural(enc, &position)
        }
    }
    guard position == enc.endIndex else { return nil }
    return out
}

public func decodeMethodTypes(enc: String) -> (returnType: String, argTypes: ArraySlice<String>)? {
    guard let types = decodeTypes(enc, _method: true) where types.count >= 3 else { return nil }
    return (types[0], types[3..<types.endIndex])
}

public func prepareType(var type: String) -> String {
    if type[type.endIndex.predecessor()] != "*" { type += " " }
    return type
}

private let typeEncodings: [Character: String] = [
    "c": "char",
    "i": "int",
    "s": "short",
    "l": "long",
    "q": "long long",
    "C": "unsigned char",
    "I": "unsigned int",
    "S": "unsigned short",
    "L": "unsigned long",
    "Q": "unsigned long long",
    "f": "float",
    "d": "double",
    "B": "bool",
    "v": "void",
    "*": "char *",
    "@": "id",
    "#": "Class",
    ":": "SEL",
    "?": "?",
]

private func decodeOneType(enc: String, inout _ position: String.Index) -> String? {
    let origPosition = position
    let char = enc[position++]
    if let base = typeEncodings[char] {
        if base == "id", let className = decodeQuotedString(enc, &position) {
            return className + " *"
        }
        return base
    } else if char == "^", var inner = decodeOneType(enc, &position) {
        if inner[inner.endIndex.predecessor()] != "*" {
            inner += " "
        }
        return inner + "*"
    }
    position = origPosition
    return nil
}

private func decodeQuotedString(input: String, inout _ position: String.Index) -> String? {
    guard position < input.endIndex && input[position] == "\"" else { return nil }
    let origPosition = position
    position++
    var chars = ""
    while position < input.endIndex {
        switch input[position++] {
            case "\"": return chars
            case let char: chars.append(char)
        }
    }
    position = origPosition
    return nil
}

private func decodeNatural(input: String, inout _ position: String.Index) -> Int? {
    var chars = ""
    while position < input.endIndex && ("0"..."9").contains(input[position]) {
        chars.append(input[position++])
    }
    guard !chars.isEmpty else { return nil }
    return Int(chars)
}
