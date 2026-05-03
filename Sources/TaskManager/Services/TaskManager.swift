import Foundation

class TaskManager {
    private var tasks: [Task] = []
    private let fileURL: URL

    init() {
        let currentDirectory = FileManager.default.currentDirectoryPath
        self.fileURL = URL(fileURLWithPath: currentDirectory)
            .appendingPathComponent("tasks.json")

        loadFromFile()
        print("Plik JSON: \(fileURL.path)")
        print("\n📊 Liczba zadań: \(tasks.count)")
    }

    // licznik nad menu
    func getStats() -> (completed: Int, total: Int) {
        let completed = tasks.filter { $0.isCompleted }.count
        let total = tasks.count
        return (completed, total)
    }

    // Statystyki Nr 5 Menu glowne
    func showStatistics() {
        let total = tasks.count
        let completed = tasks.filter { $0.isCompleted }.count
        let incomplete = total - completed

        print("""
        ------------------------------
        STATYSTYKI
        ------------------------------
        Wszystkie zadania: \(total)
        Wykonane: \(completed)
        Niewykonane: \(incomplete)
        ------------------------------
        """)
}

    // MARK: - Dodawanie zadania
    func addTask(title: String, description: String, category: String, priority: Priority) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            print("❌ Tytuł nie może być pusty.")
            return
        }

        guard !trimmedDescription.isEmpty else {
            print("❌ Opis nie może być pusty.")
            return
        }

        guard !trimmedCategory.isEmpty else {
            print("❌ Kategoria nie może być pusta.")
            return
        }

        let newId = (tasks.map { $0.id }.max() ?? 0) + 1

        let newTask = Task(
            id: newId,
            title: trimmedTitle,
            description: trimmedDescription,
            isCompleted: false,
            category: trimmedCategory,
            priority: priority
        )

        tasks.append(newTask)
        saveToFile()
        print("✅ Dodano nowe zadanie.")
    }

    // MARK: - Wyświetlanie wszystkich zadań
    func showAllTasks() {
        if tasks.isEmpty {
            print("📭 Brak zadań.")
            return
        }

    printTaskTable(tasks)
    }

    // MARK: - Szczegóły zadania
    func showTaskDetails(id: Int) {
        guard let task = tasks.first(where: { $0.id == id }) else {
            print("❌ Nie znaleziono zadania.")
            return
        }

        print("---------------")
        print("ID: \(task.id)")
        print("Tytuł: \(task.title)")
        print("Opis: \(task.description)")
        print("Kategoria: \(task.category)")
        print("Status: \(task.isCompleted ? "Wykonane" : "Niewykonane")")
        print("Priorytet: \(task.priority.rawValue)")
        print("---------------")
    }

    // MARK: - Oznacz / odznacz jako wykonane
    func toggleTaskCompletion(id: Int) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            print("❌ Nie znaleziono zadania.")
            return
        }

        tasks[index].isCompleted.toggle()
        saveToFile()

        let status = tasks[index].isCompleted ? "wykonane" : "niewykonane"
        print("✅ Zadanie oznaczono jako \(status).")
    }

    // MARK: - Usuwanie zadania
    func deleteTask(id: Int) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            print("❌ Nie znaleziono zadania.")
            return
        }

        tasks.remove(at: index)
        saveToFile()
        print("✅ Usunięto zadanie.")
    }
    // MARK: - Edycja zadania
    func editTask(id: Int, newTitle: String, newDescription: String, newCategory: String, newPriority: Priority?) {
    guard let index = tasks.firstIndex(where: { $0.id == id }) else {
        print("❌ Nie znaleziono zadania.")
        return
    }
    let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedCategory = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)

    if !trimmedTitle.isEmpty {
        tasks[index].title = trimmedTitle
    }
    if !trimmedDescription.isEmpty {
        tasks[index].description = trimmedDescription
    }
    if !trimmedCategory.isEmpty {
        tasks[index].category = trimmedCategory
    }
    if let newPriority = newPriority {
        tasks[index].priority = newPriority
    }
    saveToFile()
    print("✅ Zadanie zostało zaktualizowane.")
}

    // MARK: - Tylko wykonane
    func showCompletedTasks() {
        let completedTasks = tasks.filter { $0.isCompleted }

        if completedTasks.isEmpty {
            print("📭 Brak wykonanych zadań.")
            return
        }

        printTaskTable(completedTasks)
    }

    // MARK: - Tylko niewykonane
    func showIncompleteTasks() {
        let incompleteTasks = tasks.filter { !$0.isCompleted }

        if incompleteTasks.isEmpty {
            print("📭 Brak niewykonanych zadań.")
            return
        }

        printTaskTable(incompleteTasks)
    }

    // MARK: - Filtrowanie po kategorii
    func filterByCategory(_ category: String) {
         
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        let filteredTasks = tasks.filter {
            $0.category.lowercased() == trimmedCategory.lowercased()
        }

        if filteredTasks.isEmpty {
            print("❌ Brak zadań w kategorii: \(trimmedCategory)")
            return
        }

        printTaskTable(filteredTasks)
    }

    // MARK: - Zapis do JSON
    private func saveToFile() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(tasks)
            try data.write(to: fileURL)
        } catch {
            print("❌ Błąd zapisu do pliku JSON: \(error.localizedDescription)")
        }
    }

    // MARK: - Odczyt z JSON
    private func loadFromFile() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            tasks = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            tasks = try decoder.decode([Task].self, from: data)
        } catch {
            print("❌ Błąd odczytu pliku JSON: \(error.localizedDescription)")
            tasks = []
        }
    }
    // MARK: - Sortowanie po tytule
    func showTasksSortedByTitle() {
        if tasks.isEmpty {
            print("Brak zadań.")
            return
        }

        let sortedTasks = tasks.sorted {
            $0.title.lowercased() < $1.title.lowercased()
        }

        print("📌 Zadania posortowane po tytule:")
        printTaskTable(sortedTasks)
    }
    // MARK: - Sortowanie po kategorii
    func showTasksSortedByCategory() {
        if tasks.isEmpty {
            print("📭 Brak zadań.")
            return
        }

        let sortedTasks = tasks.sorted {
            $0.category.lowercased() < $1.category.lowercased()
        }

        print("📌 Zadania posortowane po kategorii:")
        printTaskTable(sortedTasks)
    }

    // MARK: Sortowanie po statusie
    func showTasksSortedByStatus() {
        if tasks.isEmpty {
            print("📭 Brak zadań.")
            return }

        let sortedTasks = tasks.sorted {
            if $0.isCompleted == $1.isCompleted {
                return $0.title.lowercased() < $1.title.lowercased()
            }
            return $0.isCompleted == false && $1.isCompleted == true }

        print("📌 Zadania posortowane po statusie:")
        
        printTaskTable(sortedTasks)
            print("\n📊 Liczba zadań: \(tasks.count)")
    }

    private func pad(_ text: String, to length: Int) -> String {
        if text.count >= length {
            return String(text.prefix(length - 1)) + "…"
        }

        return text + String(repeating: " ", count: length - text.count)
    }

    private func printTaskTable(_ tasksToPrint: [Task]) {
        print(
            pad("ID", to: 5) +
            pad("STATUS", to: 10) +
            pad("TYTUŁ", to: 35) +
            pad("KATEGORIA", to: 18) +
            pad("PRIORYTET", to: 12)
        )

    print(String(repeating: "-", count: 80))

    for task in tasksToPrint {
        let status = task.isCompleted ? "OK" : "NIE"

        print(
            pad(String(task.id), to: 5) +
            pad(status, to: 10) +
            pad(task.title, to: 35) +
            pad(task.category, to: 18) +
            pad(task.priority.rawValue, to: 12)
        )
    }
    }

    
}
