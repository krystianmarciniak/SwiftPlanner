import Foundation

func showMenu(completed: Int, total: Int) {
    print("""
    
    \(CLIColor.cyan)╔════════════════════════════════════════════╗
    ║\(CLIColor.bold)              TASK MANAGER CLI             \(CLIColor.reset)\(CLIColor.cyan)║
    ╠════════════════════════════════════════════╣\(CLIColor.reset)
    ║  📊 Zadania: \(CLIColor.yellow)\(total)\(CLIColor.reset)
    ║  ✅ Ukończone: \(CLIColor.green)\(completed)/\(total)\(CLIColor.reset)
    \(CLIColor.cyan)╠════════════════════════════════════════════╣\(CLIColor.reset)
    ║  \(CLIColor.yellow)1.\(CLIColor.reset) 📋 Przegląd zadań
    ║  \(CLIColor.yellow)2.\(CLIColor.reset) ➕ Dodaj nowe zadanie
    ║  \(CLIColor.yellow)3.\(CLIColor.reset) ✏️  Edytuj zadanie
    ║  \(CLIColor.yellow)4.\(CLIColor.reset) 🗑️  Usuń zadanie
    ║  \(CLIColor.yellow)5.\(CLIColor.reset) 📈 Statystyki
    ║  \(CLIColor.red)0.\(CLIColor.reset) 🚪 Wyjście
    \(CLIColor.cyan)╚════════════════════════════════════════════╝\(CLIColor.reset)
    
    \(CLIColor.bold)Wybierz opcję:\(CLIColor.reset)
    """)
}

func showTaskViewMenu() {
    print("""
    -------------------------------
    PRZEGLĄD ZADAŃ
    -------------------------------
    1. Wyświetl wszystkie zadania
    2. Wyświetl szczegóły zadania
    3. Wyświetl tylko wykonane
    4. Wyświetl tylko niewykonane
    5. Oznacz zadanie jako wykonane
    6. Sortuj zadania
    7. Filtruj po kategorii
    0. Powrót do menu głównego
    -------------------------------
    Wybierz opcję:
    """)
}

func selectCategory() -> String {
    print("""
    ------------------------------
    WYBIERZ KATEGORIĘ
    ------------------------------
    1. Nauka
    2. Praca
    3. Prywatne
    4. Zakupy
    5. Inne
    0. Wpisz własną kategorię
    ------------------------------
    Wybierz opcję:
    """)

    guard let input = readLine(), let option = Int(input) else {
        return "Inne"
    }

    switch option {
    case 1:
        return "Nauka"
    case 2:
        return "Praca"
    case 3:
        return "Prywatne"
    case 4:
        return "Zakupy"
    case 5:
        return "Inne"
    case 0:
        print("Podaj własną kategorię:")
        return readLine() ?? "Inne"
    default:
        return "Inne"
    }
}

func showSortMenu() {
    print("""
    ------------------------------
    SORTOWANIE ZADAŃ
    ------------------------------
    1. Sortuj po Tytule
    2. Sortuj po Kategorii
    3. Sortuj po Statusie
    0. Powrót
    ------------------------------
    Wybierz opcję:
    """)
}