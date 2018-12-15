struct UpdateApplicationContextData<T: ApplicationContextDataType> : CustomTypeName {
    let data: T
    
    static var typeName: String {
        // e.g. "UpdateApplicationContextData<RecordListData>"
        return "UpdateApplicationContextData<\(String(describing: T.self))>"
    }
}
