// NOTE: Dirty Singleton.
// I am not aware of any decent DI solution...

let _pubSub = PubSub()
let _applicationContextManager = ApplicationContextManager(_pubSub)
let _bootstrapper = Bootstrapper(_pubSub, _applicationContextManager)
