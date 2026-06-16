import Foundation
//Klasa TaskManager jest centralnym elementem aplikacji. Zarządza listą zadań, odpowiada za ich przechowywanie, zapis do pliku JSON oraz odczyt po ponownym uruchomieniu programu. 
// Konstruktor przygotowuje ścieżkę do pliku tasks.json i automatycznie ładuje wcześniej zapisane dane. Funkcja getStats() zwraca liczbę wszystkich i wykonanych zadań, natomiast showStatistics() prezentuje użytkownikowi pełne statystyki aplikacji.
class TaskManager {
    // Tablica przechowująca wszystkie zadania w pamięci programu.
    // Każdy element tablicy jest obiektem typu Task.
    private var tasks: [Task] = []// private oznacza, że dostęp do niej jest możliwy tylko wewnątrz klasy.
    
    private let fileURL: URL // Adres pliku tasks.json używanego do trwałego zapisu danych. => Dzięki temu zadania nie znikają po zamknięciu programu.

     // Konstruktor klasy wykonywany przy utworzeniu obiektu TaskManager.
    init() {
         // Pobranie aktualnego katalogu roboczego programu.
        let currentDirectory = FileManager.default.currentDirectoryPath

        // Utworzenie pełnej ścieżki do pliku tasks.json.
        self.fileURL = URL(fileURLWithPath: currentDirectory)
            .appendingPathComponent("tasks.json")// Utworzenie pełnej ścieżki do pliku tasks.json.
        // Wczytanie wcześniej zapisanych zadań z pliku JSON.
        loadFromFile()

        // Informacja diagnostyczna pokazująca lokalizację pliku.
        print("Plik JSON: \(fileURL.path)")

        // Wyświetlenie liczby zadań po uruchomieniu programu.
        print("\n📊 Liczba zadań: \(tasks.count)")}

    // Licznik zadań wyświetlany nad menu głównym. Funkcja zwraca dwie wartości
    func getStats() -> (completed: Int, total: Int) {// Liczbę wykonanych zadań && całkowitą liczbę zadań.
        // Filtrowanie tablicy i zliczanie tylko wykonanych zadań.
        let completed = tasks.filter { $0.isCompleted }.count // filter przechodzi po wszystkich elementach tablicy i wybiera tylko te, które spełniają określony warunek.
        // $0 oznacza:pierwszy parametr przekazany do closure
        // $0? Swift pozwala skrócić zapis funkcji anonimowych (closures).
        // Normalny zapis: tasks.filter { task in task.isCompleted}
        // pierwszy element $0 = [Task(id: 1, title: "Swift", isCompleted: true), ... ] sprawdza: $0.isCompleted wynik: true zadanie zostaje.
        // .count? Po odfiltrowaniu wykonanych zadań Swift liczy ich ilość
        let total = tasks.count // Liczba wszystkich zadań.
        return (completed, total)} // Zwrócenie obu wartości jako krotki (tuple).
        
        // Wyświetla pełne statystyki zadań.=>  Statystyki Nr 5 Menu glowne 
    func showStatistics() {

        let total = tasks.count // Łączna liczba zadań.
        let completed = tasks.filter { $0.isCompleted }.count // Liczba wykonanych zadań.
        let incomplete = total - completed // Liczba niewykonanych zadań

        // Czytelny raport wyświetlany użytkownikowi.
        print("""
        ------------------------------
        STATYSTYKI
        ------------------------------
        Wszystkie zadania: \(total)
        Wykonane: \(completed)
        Niewykonane: \(incomplete)
        ------------------------------
        """)}
        // MARK: 1-Funkcja odpowiedzialna za utworzenie nowego zadania.
        // Przyjmuje dane podane przez użytkownika:|- tytuł zadania |- opis zadania | - kategorię | - priorytet
    func addTask(title: String, description: String, category: String, priority: Priority) {
        
        // Usunięcie zbędnych spacji oraz znaków nowej linii | z początku i końca tekstu.
        // Dzięki temu użytkownik nie może wpisać np. samych spacji.
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
      
        // guard=> Nie pozwól przejść dalej, jeśli tytuł jest pusty => sprawdza warunek | Walidacja tytułu.
        //użytkownik wpisał: title=""=>Po przycięciu spacji: trimmedTitle="" => Sprawdzenie: trimmedTitle.isEmpty => wynik: true => Ale w kodzie jest => !trimmedTitle.isEmpty <=> !true => false => Ponieważ warunek jest fałszywy, Swift przechodzi do: 'else { print(" Tytuł nie może być pusty.") return}'
        guard !trimmedTitle.isEmpty else { // Jeżeli tytuł jest pusty, funkcja kończy działanie.
            print("❌ Tytuł nie może być pusty.") 
            return
            }
            
        // Walidacja opisu. | Zadanie musi posiadać opis.
        guard !trimmedDescription.isEmpty else { 
            print("❌ Opis nie może być pusty.") 
            return
            }

        // Walidacja kategorii. | Każde zadanie musi należeć do określonej kategorii.
        guard !trimmedCategory.isEmpty else {
            print("❌ Kategoria nie może być pusta.") 
            return
            }

        // Wygenerowanie nowego identyfikatora zadania.
        // tasks.map { $0.id } | pobiera wszystkie istniejące identyfikatory.
        let newId = (tasks.map { $0.id }.max() ?? 0) + 1 // .max() wyszukuje największe ID.
          // ?? 0 | jeśli lista jest pusta, przyjmuje wartość 0.
           // + 1 | tworzy kolejne unikalne ID.

        // ponieważ nowe zadanie nie jest jeszcze wykonane.  
        // Utworzenie nowego obiektu Task. 
        let newTask = Task(
            id: newId,
            title: trimmedTitle,
            description: trimmedDescription,
            isCompleted: false, // Status początkowy ustawiany jest na false,
            category: trimmedCategory,
            priority: priority
        )
        tasks.append(newTask) // Dodanie zadania do tablicy przechowującej wszystkie zadania.
        
        saveToFile() // Zapis aktualnej listy zadań do pliku JSON. | Dzięki temu dane pozostaną dostępne po ponownym uruchomieniu programu.
        print("✅ Dodano nowe zadanie.") // Informacja dla użytkownika o poprawnym wykonaniu operacji.
    }
    // Metoda addTask() odpowiada za dodawanie nowych zadań | Najpierw usuwa zbędne spacje z danych wejściowych, następnie sprawdza poprawność tytułu, opisu i kategorii przy pomocy instrukcji guard. 
    // Jeżeli dane są poprawne, program generuje nowe unikalne ID, tworzy obiekt Task, dodaje go do tablicy zadań oraz zapisuje całą listę do pliku JSON | Na końcu użytkownik otrzymuje komunikat o poprawnym dodaniu zadania.

    // MARK: 2-Wyświetlanie wszystkich zadań 
        //Tutaj przekazywana jest cała tablica:
        func showAllTasks() {// Funkcja odpowiedzialna za pokazanie wszystkich zadań | znajdujących się aktualnie w pamięci programu.
            if tasks.isEmpty { print("📭 Brak zadań.") 
            return
            }// Sprawdzenie czy tablica zadań jest pusta.|Jeśli nie ma żadnych rekordów, nie ma sensu wyświetlać tabeli.
        printTaskTable(tasks)// Jeżeli zadania istnieją, przekazaną cała tablica do funkcji, która odpowiada za wyświetlenie tabeli.
        }
    
    // MARK: 3-Funkcja wyświetla pełne informacje o jednym konkretnym zadaniu.
    func showTaskDetails(id: Int) {// Parametr: id - identyfikator zadania podany przez użytkownika.
        // Wyszukanie pierwszego zadania, którego identyfikator jest równy podanemu ID.
        guard let task = tasks.first(where: { $0.id == id })//  first(where:) przechodzi po wszystkich zadaniach i zatrzymuje się po znalezieniu pierwszego pasującego.| $0 oznacza aktualnie sprawdzane zadanie. 
        // first(where:) zwraca: Task czyli cały obiekt.
        else { print("❌ Nie znaleziono zadania.") 
        return 
        }

        // W tym miejscu jest pewność, że zmienna task zawiera znalezione zadanie.
        print("---------------")
        print("ID: \(task.id)")
        print("Tytuł: \(task.title)")
        print("Opis: \(task.description)")
        print("Kategoria: \(task.category)")
        // Jeżeli zadanie jest ukończone → Wykonane | Jeżeli nie → Niewykonane
        print("Status: \(task.isCompleted ? "Wykonane" : "Niewykonane")")
        // rawValue pobiera tekstową wartość enuma Priority.
        print("Priorytet: \(task.priority.rawValue)")
        print("---------------")
    }
    // MARK: 4-Funkcja zmienia status zadania ? Oznacz : 'odznacz jako wykonane'
    // Jeżeli zadanie było niewykonane -> staje się wykonane.
    // Jeżeli było wykonane => staje się niewykonane.
    func toggleTaskCompletion(id: Int) {
         // Wyszukanie indeksu zadania w tablicy.
       
        guard let index = tasks.firstIndex(where: { $0.id == id })// firstIndex(where:) zwraca pozycję elementu,a nie sam obiekt Task.=>  Pozwala na Późniejszą modyfikację => konkretny element tablicy.
        else {
            print("❌ Nie znaleziono zadania.") 
            return 
            }

    // toggle() odwraca wartość logiczną ? 'true : false' : 'false -> true'
    // Pozwala jednym wywołaniem oznaczać i odznaczać zadanie.    
        tasks[index].isCompleted.toggle()
        saveToFile() // Zapis aktualnego stanu do pliku JSON.

        // Ustawienie warunku ternarnego => komunikatu dla użytkownika.
        let status = tasks[index].isCompleted ? "wykonane" : "niewykonane"
        print("✅ Zadanie oznaczono jako \(status).")
    }
    // MARK: 5-Usuwanie zadania | Funkcja usuwa zadanie o wskazanym identyfikatorze.
    func deleteTask(id: Int) {
        // Wyszukanie pozycji zadania w tablicy.
        guard let index = tasks.firstIndex(where: { $0.id == id })// firstIndex(where:) zwraca pozycję elementu,a nie sam obiekt Task.
        else {
            print("❌ Nie znaleziono zadania.") 
            return
            }
        tasks.remove(at: index) // Usunięcie elementu z tablicy.
    // remove(at:) => usuwa element znajdujący się pod podanym indeksem.
        saveToFile()
        print("✅ Usunięto zadanie.")  // Aktualizacja pliku JSON po usunięciu zadania.
    }

    // MARK: 6-Edycja zadania | Funkcja odpowiedzialna za aktualizację istniejącego zadania.
    func editTask(
        id: Int,                // id - identyfikator zadania do edycji         
        newTitle: String,       // newTitle - nowy tytuł  
        newDescription: String, // newDescription - nowy opis
        newCategory: String,    // newCategory - nowa kategoria
        newPriority: Priority?  // newPriority - nowy priorytet | zmienna może zawierać wartość typu Priority albo nie zawierać żadnej wartości (nil) | bo w Task.swift enum Priority {case low  case medium case high }
        
        ) {
    guard let index = tasks.firstIndex(where: { $0.id == id }) else {
        print("❌ Nie znaleziono zadania.")
        return
        }
    // Usunięcie zbędnych spacji,  z początku i końca tekstu.
    // Dzięki temu użytkownik nie może | przypadkowo nadpisać pola samymi spacjami.
    let trimmedTitle = 
        newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedDescription = 
        newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedCategory = 
        newCategory.trimmingCharacters(in: .whitespacesAndNewlines)

    // Aktualizacja tytułu.
    if !trimmedTitle.isEmpty {            // Jeżeli użytkownik pozostawił pole puste  
        tasks[index].title = trimmedTitle // stara wartość pozostaje bez zmian.
        }
    // Aktualizacja opisu.    
    if !trimmedDescription.isEmpty { 
        tasks[index].description = trimmedDescription
        }
    // Aktualizacja kategorii.    
    if !trimmedCategory.isEmpty { 
        tasks[index].category = trimmedCategory
        }
    // Aktualizacja priorytetu.
    // newPriority jest typu Optional |     if let sprawdza czy zawiera wartość.    
    if let newPriority = newPriority {      // Jeżeli wartość istnieje,
        tasks[index].priority = newPriority // zostaje przypisana do zadania.
        }
    saveToFile() // Zapis zmian do pliku JSON.
    print("✅ Zadanie zostało zaktualizowane.")
}
    // MARK: 7-Funkcja wyświetlająca wszystkie wykonane zadania
    func showCompletedTasks() {
        // Metoda filter() przechodzi przez wszystkie elementy tablicy tasks | i zwraca nową tablicę zawierającą tylko zadania spełniające warunek.
        let completedTasks = tasks.filter { $0.isCompleted }// $0 oznacza aktualnie analizowany obiekt Task.
        
        // Właściwość isEmpty zwraca true, gdy tablica nie zawiera żadnych elementów
        if completedTasks.isEmpty {
            print("📭 Brak wykonanych zadań.")
            return
            }
            // Wyświetlenie wszystkich wykonanych zadań
    // w formie tabeli przy pomocy funkcji printTaskTable()
        printTaskTable(completedTasks)}

    // MARK: 8-Tylko niewykonane
    func showIncompleteTasks() {
    // Metoda filter() przechodzi przez wszystkie elementy tablicy tasks
    // i zwraca nową tablicę zawierającą tylko zadania niespełniające warunku isCompleted.
        let incompleteTasks = tasks.filter { !$0.isCompleted }

        // Właściwość isEmpty zwraca true, gdy tablica nie zawiera żadnych elementów
        if incompleteTasks.isEmpty {
            print("📭 Brak niewykonanych zadań.")
            return
            }
        // Przekazanie przefiltrowanej tablicy do funkcji odpowiedzialnej
        // za wyświetlenie danych w formie tabeli
        printTaskTable(incompleteTasks)
        }

    // MARK: 9-Filtrowanie zadań według kategorii
    func filterByCategory(_ category: String) {
        // Usunięcie spacji i znaków nowej linii z początku oraz końca tekstu 
        // wprowadzonego przez użytkownika   
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        // Przejście przez wszystkie zadania i utworzenie nowej tablicy
        // zawierającej wyłącznie zadania należące do podanej kategorii. 
        let filteredTasks = tasks.filter {
            $0.category.lowercased() == trimmedCategory.lowercased() // lowercased() zamienia tekst na małe litery, dzięki czemu: |"Praca", "praca" oraz "PRACA" są traktowane tak samo.
            }
        // Sprawdzenie, czy po filtrowaniu znaleziono jakiekolwiek zadania
        if filteredTasks.isEmpty {
            // Wyświetlenie komunikatu informującego,|  że w podanej kategorii nie znaleziono żadnych zadań
            print("❌ Brak zadań w kategorii: \(trimmedCategory)")
            return
            }
            // Przekazanie przefiltrowanej tablicy do funkcji | odpowiedzialnej za wyświetlenie tabeli zadań
        printTaskTable(filteredTasks)}

    // MARK: 10-Zapis zadań do pliku JSON
    private func saveToFile() {
        // Blok do-catch służy do obsługi operacji, które mogą zgłosić błąd (throw)
        do {
            // Utworzenie obiektu odpowiedzialnego, za konwersję danych Swift do formatu JSON
            let encoder = JSONEncoder()

            // Ustawienie formatowania pliku JSON:
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]// prettyPrinted - czytelne wcięcia i przejrzysty układ | sortedKeys - sortowanie kluczy alfabetycznie

            // Zamiana tablicy tasks na dane typu Data | gotowe do zapisania w pliku JSON
            let data = try encoder.encode(tasks)

            // Zapis zakodowanych danych do pliku | wskazywanego przez adres fileURL
            try data.write(to: fileURL)
        } catch {
            print("❌ Błąd zapisu do pliku JSON: \(error.localizedDescription)")
            }
        }

    // MARK: 11-Odczyt z JSON
    private func loadFromFile() {
        // Sprawdzenie, czy plik JSON istnieje pod wskazaną ścieżką.
        guard FileManager.default.fileExists(atPath: fileURL.path) 
        else {
            tasks = [] // Jeżeli plik nie istnieje, tworzona zostaje pusta tablica zadań
            return     // i kończy działanie funkcji.
            }
        // Blok do-catch służy do obsługi operacji, | które mogą zgłosić błąd (throw)
        do {
            // Odczytanie zawartości pliku JSON do obiektu typu Data
            let data = try Data(contentsOf: fileURL)

            // Utworzenie obiektu odpowiedzialnego | za konwersję danych JSON na obiekty Swift
            let decoder = JSONDecoder()

            tasks = try decoder.decode(
                [Task].self, // Zamiana danych JSON na tablicę obiektów typu Task 
                from: data)  // i zapisanie wyniku do tablicy tasks
        } catch {
            print("❌ Błąd odczytu pliku JSON: \(error.localizedDescription)")
            // Dla błędu ustawiona pustą tablica | aby program mógł działać dalej
            tasks = [] 
        }}

    // MARK: 12-Sortowanie zadań według tytułu
    func showTasksSortedByTitle() {
    // Sprawdzenie, czy tablica zadań jest pusta.
    // Jeżeli nie ma żadnych rekordów, nie ma czego sortować ani wyświetlać.
        if tasks.isEmpty {
            print("Brak zadań.")
            return
            }
        // Utworzenie nowej tablicy zawierającej zadania posortowane
        // alfabetycznie według pola title.
        
        let sortedTasks = tasks.sorted {
            // lowercased() powoduje ignorowanie wielkości liter,
            // dzięki czemu "Swift" i "swift" są traktowane jednakowo.
            $0.title.lowercased() < $1.title.lowercased()}

        print("📌 Zadania posortowane po tytule:")
        // Przekazanie posortowanej tablicy do funkcji
        // odpowiedzialnej za wyświetlenie danych w formie tabeli
        printTaskTable(sortedTasks)
        }

    // MARK: 13-Sortowanie zadań według kategorii
    func showTasksSortedByCategory() {
        // Sprawdzenie, czy tablica zadań zawiera jakiekolwiek elementy.
        // Jeżeli nie ma żadnych zadań, nie ma czego sortować.
        if tasks.isEmpty {
            print("📭 Brak zadań.")
            return
            }
    // Utworzenie nowej tablicy zawierającej zadania posortowane | alfabetycznie według pola category.
        let sortedTasks = tasks.sorted {
            // lowercased() powoduje ignorowanie wielkości liter podczas porównywania.
            $0.category.lowercased() < $1.category.lowercased()
            }
        print("📌 Zadania posortowane po kategorii:")
        printTaskTable(sortedTasks)
    }
    // MARK: 14-Sortowanie po statusie
    func showTasksSortedByStatus() {
        // Sprawdzenie, czy tablica zadań zawiera jakiekolwiek elementy.
        // Jeżeli jest pusta, nie ma czego sortować ani wyświetlać.
        if tasks.isEmpty {
            print("📭 Brak zadań.")
            return 
            }
        // Utworzenie nowej tablicy zawierającej zadania
        // posortowane według statusu wykonania.
        let sortedTasks = tasks.sorted {
            // Sortowanie pomocnicze po tytule A-Z
            if $0.isCompleted == $1.isCompleted {
                // Zadania niewykonane (false) mają być wyświetlane
                // przed zadaniami wykonanymi (true)
                return $0.title.lowercased() < $1.title.lowercased()
                }
            // Zadania niewykonane (false) mają być wyświetlane
            // przed zadaniami wykonanymi (true)
            return $0.isCompleted == false && $1.isCompleted == true } // Umieść zadanie niewykonane przed wykonanym.

        // Informacja o zastosowanym sposobie sortowania
        print("📌 Zadania posortowane po statusie:") 

        // Wyświetlenie posortowanej tabeli
        printTaskTable(sortedTasks)
            // Wyświetlenie całkowitej liczby zadań
            print("\n📊 Liczba zadań: \(tasks.count)")
            }

    // MARK: 15-Wyrównywanie tekstu w kolumnach tabeli
    private func pad(_ text: String, to length: Int) -> String {

        // Jeżeli tekst jest dłuższy lub równy szerokości kolumny
        if text.count >= length { // Czy tekst zmieści się w kolumnie?
            // Skrócenie tekstu i dodanie wielokropka aby nie rozjechać układu tabeli
            return String(text.prefix(length - 1)) + "…"
            }
        // Jeżeli tekst jest krótszy od szerokości kolumny,
        // dodaj odpowiednią liczbę spacji na końcu
        return text + String(repeating: " ", count: length - text.count)
        }

    private func printTaskTable(_ tasksToPrint: [Task]) {
    // Wyświetlenie nagłówka tabeli.
    // Funkcja pad() wyrównuje szerokość poszczególnych kolumn,
    // dzięki czemu tabela zachowuje czytelny układ.
        print(
            pad("ID", to: 5) +
            pad("STATUS", to: 10) +
            pad("TYTUŁ", to: 35) +
            pad("KATEGORIA", to: 18) +
            pad("PRIORYTET", to: 12)
            )
        // Wyświetlenie linii oddzielającej nagłówek od danych
        print(String(repeating: "-", count: 80))

        // Przejście przez wszystkie zadania przekazane do funkcji
        for task in tasksToPrint {

            // Zamiana wartości Bool na bardziej czytelny tekst
            // true  -> "OK" | false -> "NIE"
            let status = task.isCompleted ? "OK" : "NIE"

            // Wyświetlenie jednego wiersza tabeli
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
