//
//  Common.swift
//  RuntimeUtils
//
//  Copyright © 2015 Alice Atlas. See LICENSE.md
//

internal func _copyWrap<Q, T, U>(fn: (Q, UnsafeMutablePointer<UInt32>) -> UnsafeMutablePointer<T>, _ transform: T -> U) (_ param: Q) -> [U] {
    var count: UInt32 = 0
    let buf = fn(param, &count)
    defer { buf.destroy(Int(count)) }
    let things = UnsafeBufferPointer(start: buf, count: Int(count))
    return things.map(transform)
}
internal func _copyWrap<Q, T>(fn: (Q, UnsafeMutablePointer<UInt32>) -> UnsafeMutablePointer<T>) -> (Q -> [T]) {
    return _copyWrap(fn, {$0})
}
internal func _copyWrap<Q, T, U>(fn: (Q, UnsafeMutablePointer<UInt32>) -> UnsafeMutablePointer<T>, _ type: U.Type, _ transform: T -> U) -> (Q -> [U]) {
    return _copyWrap(fn, transform)
}

protocol Wrapper {
    typealias Target
    init(_ target: Target)
}
internal extension Wrapper {
    static func copyWrap<Q>(fn: (Q, UnsafeMutablePointer<UInt32>) -> UnsafeMutablePointer<Target>) -> (Q -> [Self]) {
        return _copyWrap(fn, self.init)
    }
}

internal func joinLines(lineSets: [String]...) -> String {
    return "\n".join([].join(lineSets))
}
