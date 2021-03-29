//
//  UnfairLock.swift
//  ADManager
//
//  Created by my on 2021/3/24.
//

import Foundation

public final class UnfairLock {
    
    private let unfairLock: os_unfair_lock_t

    init() {
        unfairLock = .allocate(capacity: 1)
        if #available(iOS 10.0, *) {
            unfairLock.initialize(to: os_unfair_lock())
        } else {
            unfairLock.initialize(to: os_unfair_lock_s())
        }
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    fileprivate func lock() {
        if #available(iOS 10.0, *) {
            os_unfair_lock_lock(unfairLock)
        } else {
        }
    }

    fileprivate func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }

    func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }

    func around(_ closure: () -> Void) {
        lock(); defer { unlock() }
        closure()
    }
}

/// A thread-safe wrapper around a value.
@propertyWrapper
@dynamicMemberLookup
public final class Protected<T> {
    private let lock = UnfairLock()
    private var value: T

    init(_ value: T) {
        self.value = value
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    public var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }

    public var projectedValue: Protected<T> { self }

    public init(wrappedValue: T) {
        value = wrappedValue
    }

    func read<U>(_ closure: (T) -> U) -> U {
        lock.around { closure(self.value) }
    }

    @discardableResult
    func write<U>(_ closure: (inout T) -> U) -> U {
        lock.around { closure(&self.value) }
    }

    subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.around { value[keyPath: keyPath] } }
        set { lock.around { value[keyPath: keyPath] = newValue } }
    }
}

extension Protected where T: RangeReplaceableCollection {

    func append(_ newElement: T.Element) {
        write { (ward: inout T) in
            ward.append(newElement)
        }
    }

    func append<S: Sequence>(contentsOf newElements: S) where S.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
    func append<C: Collection>(contentsOf newElements: C) where C.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
}

extension Protected where T == Data? {
    func append(_ data: Data) {
        write { (ward: inout T) in
            ward?.append(data)
        }
    }
}
