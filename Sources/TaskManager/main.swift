import Foundation

// Utworzenie obiektu klasy TaskManager.
// Konstruktor init() zostanie wykonany automatycznie,
// a wraz z nim m.in. wczytanie zapisanych zadań z pliku JSON.
let manager = TaskManager()

// Flaga sterująca działaniem programu.
// Dopóki ma wartość true, menu będzie wyświetlane w pętli.
var isRunning = true

// Główna pętla programu.
// Program działa tak długo, jak długo isRunning == true.
while isRunning {

    // Pobranie aktualnych statystyk zadań
    // (np. liczba wykonanych i wszystkich zadań)
    let stats = manager.getStats()

    // Wyświetlenie menu głównego wraz ze statystykami
    showMenu(completed: stats.completed, total: stats.total)
    
    // Odczyt danych wpisanych przez użytkownika.
    // readLine() zwraca tekst (String?).
    // Int(input) próbuje zamienić tekst na liczbę całkowitą.
    guard let input = readLine(), let option = Int(input) else {

        // Jeżeli użytkownik podał niepoprawne dane,
        // wyświetlany jest komunikat błędu.
        print("\(CLIColor.red)❌ Nieprawidłowy wybór.\(CLIColor.reset)")

        // continue przerywa aktualną iterację pętli
        // i wraca do początku menu.
        continue
    }

    switch option {
case 1:
    showTaskViewMenu()

    if let input = readLine(), let taskViewOption = Int(input) {
        switch taskViewOption {
        case 1:
            manager.showAllTasks()
        case 2:
            print("Podaj ID zadania:")
            if let input = readLine(), let id = Int(input) {
                manager.showTaskDetails(id: id)
            } else {
                print("\(CLIColor.red)❌ Nieprawidłowe ID.\(CLIColor.reset)")
            }
        case 3:
            manager.showCompletedTasks()
        case 4:
            manager.showIncompleteTasks()
        case 5:
            print("Podaj ID zadania:")
            if let input = readLine(), let id = Int(input) {
                manager.toggleTaskCompletion(id: id)
            } else {
                print("\(CLIColor.red)❌ Nieprawidłowe ID.\(CLIColor.reset)")
            }
        case 6:
            showSortMenu()

            if let input = readLine(), let sortOption = Int(input) {
                switch sortOption {
                case 1:
                    manager.showTasksSortedByTitle()
                case 2:
                    manager.showTasksSortedByCategory()
                case 3:
                    manager.showTasksSortedByStatus()
                case 0:
                    print("↩️ Powrót do menu głównego.")
                default:
                    print("\(CLIColor.red)❌ Nieprawidłowa opcja sortowania.\(CLIColor.reset)")
                }
            }
        case 7:    
            print("Podaj kategorię: 1. Nauka || Praca || Prywatne || Zakupy || Inne")
            let category = readLine() ?? ""
            manager.filterByCategory(category)
        case 0:
            print("↩️ Powrót do menu głównego.")
        default:
            print("\(CLIColor.red)❌ Nieprawidłowa opcja.\(CLIColor.reset)")
        }
    }

case 2:
    print("Podaj tytuł zadania:")
    let title = readLine() ?? ""

    print("Podaj opis zadania:")
    let description = readLine() ?? ""

    let category = selectCategory()

    print("Podaj priorytet (low / medium / high):")
    let priorityInput = readLine()?.lowercased() ?? ""

    let priority: Priority

    switch priorityInput {
    case "low":
        priority = .low
    case "medium":
        priority = .medium
    case "high":
        priority = .high
    default:
        priority = .medium
    }

    manager.addTask(
        title: title,
        description: description,
        category: category,
        priority: priority
    )
    print("\(CLIColor.green)✅ Zadanie dodane pomyślnie.\(CLIColor.reset)")
case 3:
    print("Podaj ID zadania do edycji:")

    if let input = readLine(), let id = Int(input) {
        print("Podaj nowy tytuł (Enter = bez zmiany):")
        let newTitle = readLine() ?? ""

        print("Podaj nowy opis (Enter = bez zmiany):")
        let newDescription = readLine() ?? ""

        print("Czy chcesz zmienić kategorię? (t/n)")
        let changeCategory = readLine()?.lowercased() ?? "n"

        let newCategory: String

        if changeCategory == "t" {
             newCategory = selectCategory()
        } else {
            newCategory = ""
        }

        print("Podaj nowy priorytet (low / medium / high, Enter = bez zmiany):")
        let priorityInput = readLine()?.lowercased() ?? ""

        var newPriority: Priority? = nil

        switch priorityInput {
        case "low":
            newPriority = .low
        case "medium":
            newPriority = .medium
        case "high":
            newPriority = .high
        default:
            break
        }

        manager.editTask(
            id: id,
            newTitle: newTitle,
            newDescription: newDescription,
            newCategory: newCategory,
            newPriority: newPriority
        )
    } else {
        print("\(CLIColor.red)❌ Nieprawidłowe ID.\(CLIColor.reset)")
    }

case 4:
    print("Podaj ID zadania do usunięcia: ")
    if let input = readLine(), let id = Int(input) {
        manager.deleteTask(id: id)
    } else {
        print("\(CLIColor.red)❌ Nieprawidłowe ID.\(CLIColor.reset)")
    }
case 5:
    manager.showStatistics()

case 0:
    print("\(CLIColor.green)👋 Zamykanie programu...\(CLIColor.reset)")
    isRunning = false

default:
    print("\(CLIColor.red)❌ Nieprawidłowa opcja.\(CLIColor.reset)")
}

    print("")
}