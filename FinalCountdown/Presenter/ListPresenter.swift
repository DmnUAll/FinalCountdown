import UIKit
import CoreData

// MARK: - ListPresenter
final class ListPresenter {

    // MARK: - Properties and Initializers
    weak var viewController: ListController?
    private var timer = Timer()

    init(viewController: ListController) {
        self.viewController = viewController
        viewController.listView.delegate = self
    }
}

// MARK: - Helpers
extension ListPresenter {

    func returnNumberOfEvents() -> Int {
        return CoreDataManager.shared.events.count
    }

    func configureCell(forIndexPath indexPath: IndexPath, atTable tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCell",
                                                       for: indexPath) as? ListViewCell else {
            return UITableViewCell()
        }
        cell.eventNameLabel.text = CoreDataManager.shared.events[indexPath.row].name
        cell.eventDescriptionLabel.text = CoreDataManager.shared.events[indexPath.row].descript

        if let date = CoreDataManager.shared.events[indexPath.row].date {
            cell.eventDateLabel.text = date.formatted(date: .numeric, time: .shortened)
            if CoreDataManager.shared.events[indexPath.row].state == State.done.rawValue {
                cell.timeLeftLabel.text = "Done"
                cell.timeLeftLabel.textColor = .green
            } else if date >= Date() {
                cell.timeLeftLabel.text = CoreDataManager.shared.calculateTimeLeft(due: date)
                cell.timeLeftLabel.textColor = .white
            } else {
                CoreDataManager.shared.events[indexPath.row].state = State.passed.rawValue
                CoreDataManager.shared.saveItems()
                cell.timeLeftLabel.text = "Passed"
                cell.timeLeftLabel.textColor = .red
            }
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = .fcCream
        cell.selectedBackgroundView = bgColorView
        return cell
    }

    func setTimer() {
        timer.invalidate()
        viewController?.listView.tableView.reloadData()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.viewController?.listView.tableView.reloadData()
        })
    }

    func checkTimerState() -> Bool {
        return timer.isValid
    }

    func disableTimer() {
        timer.invalidate()
    }

    func prepareData(forSelectedRow rowIndex: Int) -> Event {
        return CoreDataManager.shared.events[rowIndex]
    }

    func updateDate(at indexPath: IndexPath, by dateRange: DateRange) {
        let date = CoreDataManager.shared.resetDate(from: CoreDataManager.shared.events[indexPath.row].date,
                                                    by: dateRange)
        CoreDataManager.shared.events[indexPath.row].state = State.willBe.rawValue
        CoreDataManager.shared.addEvent(name: CoreDataManager.shared.events[indexPath.row].name ?? "",
                                        description: CoreDataManager.shared.events[indexPath.row].descript ?? "",
                                        date: date)
        viewController?.listView.segmentedControl.selectedSegmentIndex = 0
        viewController?.listView.tableView.reloadData()
        setTimer()
    }

    func searchEvent(withName eventName: String?) {
        guard let eventName = eventName,
              let segmentIndex = viewController?.listView.segmentedControl.selectedSegmentIndex else { return }
        let eventState = segmentIndex == 1 ? State.passed.rawValue : segmentIndex == 2 ? State.done.rawValue : "e"
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let mainPredicate = NSPredicate(format: "name CONTAINS[cd] %@", eventName)
        let categoryPredicate = NSPredicate(format: "state CONTAINS %@", eventState)
        let combinedPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and,
                                                    subpredicates: [mainPredicate, categoryPredicate])
        request.predicate = combinedPredicate
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)

        CoreDataManager.shared.loadItems(with: request, sortedBy: sortDescriptor)
        viewController?.listView.tableView.reloadData()
    }

    func setToDone(itemAtIndex index: Int) {
        CoreDataManager.shared.events[index].state = State.done.rawValue
        CoreDataManager.shared.events[index].date = Date()
        CoreDataManager.shared.saveItems()
    }
}

// MARK: - ListViewDelegate
extension ListPresenter: ListViewDelegate {
    func segmentedControlDidChangeValue(to selectedSegment: Int) {
        timer.invalidate()
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        if selectedSegment == 1 {
            CoreDataManager.shared.loadItems()
            request.predicate = NSPredicate(format: "state MATCHES %@", State.passed.rawValue)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            CoreDataManager.shared.loadItems(with: request, sortedBy: sortDescriptor)
        } else if selectedSegment == 2 {
            request.predicate = NSPredicate(format: "state MATCHES %@", State.done.rawValue)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            CoreDataManager.shared.loadItems(with: request, sortedBy: sortDescriptor)
        } else {
            setTimer()
            CoreDataManager.shared.loadItems()
        }
        viewController?.listView.tableView.reloadData()
    }
}
