// NOTE: Taken verbatim from https://github.com/MooseMagnet/DeliciousPubSub
// with an update to include the `CustomTypeName` protocol to support generics.
// I don't like any of the current package management solutions for Xcode.

import Foundation

class PubSub {
    
    private var handlers: [String: ArrayReference<Handler>] = [:]
    private let dispatchImmediately: Bool
    private var unhandledMessages: Array<Any> = []
    
    public init(dispatchImmediately: Bool) {
        self.dispatchImmediately = dispatchImmediately
    }
    
    public convenience init() {
        self.init(dispatchImmediately: true)
    }
    
    deinit {
        handlers.removeAll()
    }
    
    func sub<T: Any>(_ fn: @escaping (T) -> Void) -> () -> Void {
        let typeName = getTypeName(T.self)
        if (handlers[typeName] == nil) {
            handlers[typeName] = ArrayReference<Handler>(array: [])
        }
        var unsubbed = false
        let handler = Handler(handlingFunction: { (any: Any) in
            if (unsubbed) {
                return
            }
            fn(any as! T)
        })
        handlers[typeName]!.append(handler)
        
        return {
            if (unsubbed) {
                return
            }
            self.handlers[typeName]!.remove(handler)
            unsubbed = true
        }
    }
    
    func sub<T: Any>(_ type: T.Type, fn: @escaping (T) -> Void) -> () -> Void {
        return sub(fn)
    }
    
    func sub<T: Any>(predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        let predicatedFn: (T) -> Void = {
            if predicate($0) {
                fn($0)
            }
        }
        return sub(predicatedFn)
    }
    
    func sub<T: Any>(_ type: T.Type, predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        return sub(predicate: predicate, fn: fn)
    }
    
    func subOnce<T: Any>(_ fn: @escaping (T) -> Void) -> () -> Void {
        var unsub: () -> Void = {
            fatalError("unsub should be re-assigned to the unsub function.")
        }
        let unsubbingFn: (T) -> Void = {
            fn($0)
            unsub()
        }
        unsub = sub(unsubbingFn)
        return unsub
    }
    
    func subOnce<T: Any>(_ type: T.Type, fn: @escaping (T) -> Void) -> () -> Void {
        return subOnce(fn)
    }
    
    func subOnce<T: Any>(predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        var unsub: () -> Void = {
            fatalError("unsub should be re-assigned to the unsub function.")
        }
        let unsubbingFn: (T) -> Void = {
            fn($0)
            unsub()
        }
        unsub = sub(predicate: predicate, fn: unsubbingFn)
        return unsub
    }
    
    func subOnce<T: Any>(_ type: T.Type, predicate: @escaping (T) -> Bool, fn: @escaping (T) -> Void) -> () -> Void {
        return subOnce(predicate: predicate, fn: fn)
    }
    
    func pub(_ message: Any) {
        if (dispatchImmediately) {
            dispatchMessageOfType(getTypeNameOf(message), message: message)
        } else {
            unhandledMessages.append(message)
        }
    }
    
    func dispatchMessages() {
        while (unhandledMessages.count > 0) {
            let message = unhandledMessages.removeFirst()
            dispatchMessageOfType(
                getTypeNameOf(message),
                message: message)
        }
    }
    
    private func getTypeNameOf(_ object: Any) -> String {
        let type = Mirror(reflecting: object).subjectType
        if let customTypeNameProtocol = type as? CustomTypeName.Type {
            return customTypeNameProtocol.typeName
        }
        return String(describing: type)
    }
    
    private func getTypeName<T>(_ type: T) -> String {
        if let customTypeNameProtocol = T.self as? CustomTypeName.Type {
            return customTypeNameProtocol.typeName
        }
        return String(describing: type)
    }
    
    private func dispatchMessageOfType(_ typeName: String, message: Any) {
        
        guard let typeHandlers = handlers[typeName] else {
            return
        }
        
        for (_, handler) in typeHandlers.array.enumerated() {
            handler.handle(message)
        }
    }
}

fileprivate class ArrayReference<T: AnyObject> {
    
    private var _array: Array<T>
    
    var array: Array<T> {
        get {
            return _array
        }
    }
    
    init(array: Array<T>) {
        _array = array
    }
    
    func append(_ element: T) {
        _array.append(element)
    }
    
    func remove(_ element: T) {
        let index = _array.index(where: { (thisElement) -> Bool in
            return thisElement === element
        })
        guard index != nil else {
            return
        }
        _array.remove(at: index!)
    }
}

fileprivate class Handler {
    
    let _function: (Any) -> Void
    
    init(handlingFunction: @escaping (Any) -> Void) {
        _function = handlingFunction
    }
    
    func handle(_ argument: Any) {
        _function(argument)
    }
}

// RE: The CustomTypeName protocol
// This helps work around the lack of support for generics.
// i.e. the name for `MyClass<GenericType>` would usually just be "MyClass".
// With this you can at least override it statically...
protocol CustomTypeName {
    static var typeName: String { get }
}
