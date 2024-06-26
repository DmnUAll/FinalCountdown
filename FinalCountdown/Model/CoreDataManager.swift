import UIKit
import CoreData

// MARK: - CoreDataManager
struct CoreDataManager {

    static var shared = CoreDataManager()
    // swiftlint:disable force_cast
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast
    var events = [Event]()

    mutating func addEvent(name: String, description: String, date: Date) {
        if let index = events.firstIndex(where: {$0.name == name}) {
            deleteEvent(at: index)
        }
        let newEvent = Event(context: context)
        newEvent.name = name
        newEvent.descript = description
        newEvent.date = date
        newEvent.state = date > Date() ? State.willBe.rawValue : State.passed.rawValue
        events.append(newEvent)
        saveItems()
    }

    mutating func deleteEvent(at indexPath: Int) {
        context.delete(events[indexPath])
        events.remove(at: indexPath)
    }

    func resetDate(from oldDate: Date?, by range: DateRange) -> Date {
        var dateComponent = DateComponents()
        switch range {
        case .day:
            dateComponent.day = 1
        case .month:
            dateComponent.month = 1
        case .year:
            dateComponent.year = 1
        }
        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: oldDate ?? Date()),
              futureDate > Date() else {
            return Calendar.current.date(byAdding: dateComponent, to: Date()) ?? Date()
        }
        return futureDate
    }

    mutating func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving cintext: \(error)")
        }
        loadItems()
    }

    mutating func loadItems(with request: NSFetchRequest<Event> = Event.fetchRequest(),
                            sortedBy sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    ) {
        request.sortDescriptors = [sortDescriptor]
        do {
            events = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }

    func calculateTimeLeft(due dueDate: Date?) -> String {
        if let dueDate = dueDate {
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
            dateComponentsFormatter.maximumUnitCount = 3
            dateComponentsFormatter.unitsStyle = .brief
            return dateComponentsFormatter.string(from: Date(), to: dueDate) ?? "Error"
        }
        return "Error"
    }
}
