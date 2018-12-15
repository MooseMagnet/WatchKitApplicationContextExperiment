class Bootstrapper {
    
    private let pubSub: PubSub
    private let applicationContextManager: ApplicationContextManager
    
    init(_ pubSub: PubSub, _ applicationContextManager: ApplicationContextManager) {
        self.pubSub = pubSub
        self.applicationContextManager = applicationContextManager
    }
    
    func go() {
        _ = republishApplicationContextUpdatesAsSpecificTypes()
        _ = publishUpdatesTo(RecordListData.self)
        _ = publishUpdatesTo(MessageFromWatchData.self)
        _ = publishUpdatesTo(MessageFromPhoneData.self)
    }
    
    private func publishUpdatesTo<T>(_ type: T.Type) -> () -> Void where T: ApplicationContextDataType {
        return pubSub.sub { (a: UpdateApplicationContextData<T>) in
            self.pubSub.pub(a.data)
            self.applicationContextManager.shareDataAcrossDevices(a.data)
        }
    }

    func republishApplicationContextUpdatesAsSpecificTypes() -> () -> Void {
        
        var last = [String: Double]()
        
        return pubSub.sub(ApplicationContextUpdate.self) { update in
            func publishIf<T: ApplicationContextDataType>(_ type: T.Type) -> Bool {
                if update.key == nameForType(T.self) {
                    
                    let data = createFromApplicationContext(T.self, context: [update.key: update.value])
                    
                    let lastTimestamp = last[update.key]
                    
                    if lastTimestamp == nil || lastTimestamp! < data.timestamp {
                        last[update.key] = data.timestamp
                        self.pubSub.pub(data)
                    }
                    
                    return true
                }
                return false
            }
            
            // NOTE: RH - In lieu of proper reflection, here's a list of the types
            // that need to be published... =(
            // It's basically any that implement ApplicationContextDataType.
            _ = publishIf(RecordListData.self) ||
                publishIf(MessageFromWatchData.self) ||
                publishIf(MessageFromPhoneData.self)
        }
    }

}
