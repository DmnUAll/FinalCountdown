import UIKit
import CoreData

// MARK: - EventPresenter
final class EventPresenter {

    // MARK: - Properties and Initializers
    weak var viewController: EventController?
    private let sectionHeaders = ["Event Info", "Event Date"]
    private let sectionsContent = [["eventNameCell", "eventDescriptionCell"], ["calendarCell"]]
    var eventName: String {
        guard let cell = viewController?.eventView.tableView.visibleCells[0] as? EventNameCell,
              let text = cell.textField.text else { return "" }
        return text
    }
    var eventDescription: String {
        guard let cell = viewController?.eventView.tableView.visibleCells[1] as? EventDescriptionCell,
              let text = cell.textField.text else { return "" }
        return text
    }
    var eventDate: Date {
        guard let cell = viewController?.eventView.tableView.visibleCells[2] as? CalendarCell else { return Date() }
        return cell.datePicker.date
    }

    init(viewController: EventController) {
        self.viewController = viewController
        addSaveButton()
    }
}

// MARK: - Helpers
extension EventPresenter {

    @objc private func checkEventName() {
        viewController?.updateSaveButtonState()
    }

    private func addSaveButton() {
        let saveButton = UIBarButtonItem(title: "Save", primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            if self.eventName != "" {
                let eventDescription = self.eventDescription == "" ? "No Description" : self.eventDescription
                CoreDataManager.shared.addEvent(name: self.eventName,
                                                description: eventDescription,
                                                date: self.eventDate)
            } else {
                self.showAlert(withTitle: "No event name given", andMessage: "You should enter an event name!")
            }

            self.viewController?.navigationController?.popToRootViewController(animated: true)
        }))
        viewController?.navigationItem.rightBarButtonItem = saveButton
        viewController?.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func checkForEventData(_ eventData: Event?) {
        guard let eventData = eventData,
              let cells = viewController?.eventView.tableView.visibleCells else { return }
        (cells[0] as? EventNameCell)?.textField.text = eventData.name
        (cells[1] as? EventDescriptionCell)?.textField.text = eventData.descript
        (cells[2] as? CalendarCell)?.datePicker.date = eventData.date ?? Date()
    }

    func checkEventNameLength(forText text: String?,
                              inRange range: NSRange,
                              andReplacementString replacementString: String
    ) -> Bool {
        guard let text = text,
              let stringRange = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: stringRange, with: replacementString)
        if updatedText.count == 30 {
            showAlert(withTitle: "Maximum characters in name",
                      andMessage: "You're reached the maximum of 30 characters for event name!")
        }
        return updatedText.count <= 30
    }

    func returnSectionsCount() -> Int {
        return sectionHeaders.count
    }

    func  returnRowsCountFor(_ section: Int) -> Int {
        return sectionsContent[section].count
    }

    func returnHeaderFor(_ section: Int) -> String {
        return sectionHeaders[section]
    }

    func configureCell(forIndexPath indexPath: IndexPath, atTable tableView: UITableView) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                guard let castedCell = tableView.dequeueReusableCell(withIdentifier: "eventNameCell",
                                                                     for: indexPath) as? EventNameCell else {
                    return cell
                }
                castedCell.textField.delegate = viewController
                castedCell.textField.addTarget(self, action: #selector(checkEventName), for: .editingChanged)
                cell = castedCell
            } else {
                guard let castedCell = tableView.dequeueReusableCell(withIdentifier: "eventDescriptionCell",
                                                                     for: indexPath) as? EventDescriptionCell else {
                    return cell
                }
                cell = castedCell
            }
        case 1:
            guard let castedCell = tableView.dequeueReusableCell(withIdentifier: "calendarCell",
                                                                 for: indexPath) as? CalendarCell else { return cell }
            castedCell.delegate = self
            cell = castedCell
        default:
            return UITableViewCell()
        }
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }

    private func showAlert(withTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        viewController?.present(alertController, animated: false)
    }
}

// MARK: - CalendarCellDelegate
extension EventPresenter: CalendarCellDelegate {

    func checkSelectedDate() {
        if eventDate < Date() {
            showAlert(withTitle: "Wrong date", andMessage: "Date must be in future!")
            guard let cell = viewController?.eventView.tableView.visibleCells[2] as? CalendarCell else { return }
            cell.datePicker.date = Date()
        }
    }
}
