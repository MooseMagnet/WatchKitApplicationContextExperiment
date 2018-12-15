class Gate {
    private var todos: [() -> Void] = []
    
    private var isOpen = false
    
    func open() {
        isOpen = true
        todos.forEach { $0() }
    }
    
    func close() {
        isOpen = false
    }
    
    func enqueue(_ todo: @escaping () -> Void) {
        if isOpen { todo() }
        else { todos.append(todo) }
    }
}
