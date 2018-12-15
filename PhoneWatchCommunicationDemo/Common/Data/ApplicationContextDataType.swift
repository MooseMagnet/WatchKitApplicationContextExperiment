import Foundation

protocol ApplicationContextDataType : Codable {
    var timestamp: Double { get }
    static func empty(_ timestamp: Double) -> Self
}

func createFromApplicationContext<T: ApplicationContextDataType>(_ type: T.Type, context: [String: Any]) -> T {
    let typeName = nameForType(type)
    if context[typeName] == nil { return T.empty(Date().timeIntervalSince1970) }
    return try! jsonDecoder.decode(type, from: context[typeName] as! Data)
}

func toApplicationContext<T: ApplicationContextDataType>(_ t: T) -> [String: Any] {
    let key = nameForType(type(of: t))
    let value = try! jsonEncoder.encode(t)
    return [key: value]
}

func mergeApplicationContexts(_ applicationContext: [String: Any], _ receivedApplicationContext: [String: Any], _ update: [String: Any] = [:]) -> [String: Any] {
    return try! applicationContext
        .merging(receivedApplicationContext, uniquingKeysWith: takeTheLatest)
        .merging(update, uniquingKeysWith: takeTheLatest)
}



fileprivate struct MergeDto : ApplicationContextDataType {
    static func empty(_ timestamp: Double) -> MergeDto { fatalError("Not Implemented") }
    let timestamp: Double
}

fileprivate func takeTheLatest(_ left: Any, _ right: Any) throws -> Any {
    let leftDto = try! jsonDecoder.decode(MergeDto.self, from: left as! Data)
    let rightDto = try! jsonDecoder.decode(MergeDto.self, from: right as! Data)
    return leftDto.timestamp > rightDto.timestamp ? left : right
}


fileprivate let jsonDecoder = JSONDecoder()
fileprivate let jsonEncoder = JSONEncoder()
