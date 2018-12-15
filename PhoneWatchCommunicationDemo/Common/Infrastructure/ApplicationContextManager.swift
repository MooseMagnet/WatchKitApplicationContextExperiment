import WatchConnectivity

struct ApplicationContextUpdate {
    let key: String
    let value: Any
}

class ApplicationContextManager : NSObject, WCSessionDelegate {

    private var watchSession: WCSession!
    
    private let gate = Gate()
    
    private let pubSub: PubSub
    
    init(_ pubSub: PubSub) {
        self.pubSub = pubSub
        super.init()
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    func getContext() -> [String: Any] {
        return mergeApplicationContexts(watchSession.applicationContext, watchSession.receivedApplicationContext)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        gate.open()
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        applicationContext.forEach {
            pubSub.pub(ApplicationContextUpdate(key: $0, value: $1))
        }
    }
    
    func shareDataAcrossDevices<T: ApplicationContextDataType>(_ t: T) {
        updateContext(toApplicationContext(t)) {
            print("Failed.", $0.localizedDescription)
        }
    }
    
    func getDataSharedAcrossDevices<T: ApplicationContextDataType>(_ type: T.Type) -> T {
        return createFromApplicationContext(
            type,
            context: getContext())
    }
    
    func clearDataAcrossDevices<T: ApplicationContextDataType>(_ t: T.Type) {
        updateContext(toApplicationContext(t.empty(Date().timeIntervalSince1970))) {
            print("Failed.", $0.localizedDescription)
        }
    }
    
    #if os(iOS)
    private func updateContext(_ update: [String: Any], errorHandler: ((Error) -> Void)? = nil) {
        gate.enqueue {
            guard self.watchSession.isPaired && self.watchSession.isWatchAppInstalled else { return }
            do {
                let new = mergeApplicationContexts(self.watchSession.applicationContext, self.watchSession.receivedApplicationContext, update)
                try self.watchSession.updateApplicationContext(new)
            } catch {
                errorHandler?(error)
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        gate.close()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        watchSession = WCSession.default
        watchSession.delegate = self
        watchSession.activate()
    }
    
    #elseif os(watchOS)
    private func updateContext(_ update: [String: Any], errorHandler: ((Error) -> Void)? = nil) {
        gate.enqueue {
            do {
                let newContext = mergeApplicationContexts(
                    self.watchSession.applicationContext,
                    self.watchSession.receivedApplicationContext,
                    update)
                
                try self.watchSession.updateApplicationContext(newContext)
            } catch {
                errorHandler?(error)
            }
        }
    }
    #endif
}
