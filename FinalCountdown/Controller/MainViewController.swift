//
//  MainViewController.swift
//  FinalCountdown
//
//  Created by Илья Валито on 07.09.2022.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    var center = UNUserNotificationCenter.current()
    var appLogic = AppLogic()
    private var timer = Timer()
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        appLogic.loadItems()
        
        // Dismiss the keyboard when user touches anywhere
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        setTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewEvent" {
            let destinationVC = segue.destination as! EventInfoViewController
            if let indexPath = tableView.indexPathForSelectedRow?.row {
                destinationVC.fillUI(eventName: appLogic.events[indexPath].name,
                                     eventDescription: appLogic.events[indexPath].descript,
                                     date: appLogic.events[indexPath].date)
            }
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            timer.invalidate()
            // Create a search request
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            request.predicate = NSPredicate(format: "state MATCHES %@", State.passed.rawValue)
            
            // Create a sorting descript that will apply to our requeest
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            
            // Sending the request
            appLogic.loadItems(with: request, sortedBy: sortDescriptor)
            tableView.reloadData()
        } else if sender.selectedSegmentIndex == 2 {
            timer.invalidate()
            // Create a search request
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            request.predicate = NSPredicate(format: "state MATCHES %@", State.done.rawValue)
            
            // Create a sorting descript that will apply to our requeest
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            
            // Sending the request
            appLogic.loadItems(with: request, sortedBy: sortDescriptor)
            tableView.reloadData()
        } else {
            setTimer()
            appLogic.loadItems()
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindToFirstScreen(_ segue: UIStoryboardSegue) {
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func setTimer() {
        timer.invalidate()
        tableView.reloadData()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.tableView.reloadData()

        })
    }
    
    private func updateDate(at indexPath: IndexPath, by dateRange: DateRange) {
        appLogic.events[indexPath.row].state = State.willBe.rawValue
        self.appLogic.addEvent(name: appLogic.events[indexPath.row].name ?? "",
                               description: appLogic.events[indexPath.row].descript ?? "",
                               date: appLogic.resetDate(from: self.appLogic.events[indexPath.row].date, by: dateRange))
        segmentedControl.selectedSegmentIndex = 0
        tableView.reloadData()
        setTimer()
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appLogic.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        cell.eventNameLabel.text = appLogic.events[indexPath.row].name
        cell.eventDescriptionLabel.text = appLogic.events[indexPath.row].descript ?? "No Description"
        
        if let date = appLogic.events[indexPath.row].date {
            cell.eventDateLabel.text = date.formatted(date: .numeric, time: .shortened)
            if appLogic.events[indexPath.row].state == State.done.rawValue {
                cell.timeLeftLabel.text = "Done"
                cell.timeLeftLabel.textColor = .green
            } else if date >= Date() {
                cell.timeLeftLabel.text = appLogic.calculateTimeLeft(due: date)
                cell.timeLeftLabel.textColor = .white
            } else {
                appLogic.events[indexPath.row].state = State.passed.rawValue
                appLogic.saveItems()
                cell.timeLeftLabel.text = "Passed"
                cell.timeLeftLabel.textColor = .red

            }
        }
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteButton = UIContextualAction(style: .destructive, title: "Remove") { _, _, _ in
            self.appLogic.deleteEvent(at: indexPath.row)
            tableView.reloadData()
            self.setTimer()
        }
        deleteButton.backgroundColor = .systemRed
        deleteButton.image = UIImage(systemName: "trash")
        
        let resetButton = UIContextualAction(style: .normal, title: "Re-set") { _, _, _ in
            let alertController = UIAlertController(title: "Re-set an event", message: "Update the due date/time of the event.", preferredStyle: .actionSheet)
            
            let dayAction = UIAlertAction(title: "To next day", style: .default) { _ in
                self.updateDate(at: indexPath, by: .day)
            }
            alertController.addAction(dayAction)
            
            let monthAction = UIAlertAction(title: "To next month", style: .default) { _ in
                self.updateDate(at: indexPath, by: .month)
            }
            alertController.addAction(monthAction)
            
            let yearAction = UIAlertAction(title: "To next year", style: .default) { _ in
                self.updateDate(at: indexPath, by: .year)
            }
            alertController.addAction(yearAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        resetButton.backgroundColor = .systemOrange
        resetButton.image = UIImage(systemName: "arrow.clockwise")
        
        let config = UISwipeActionsConfiguration(actions: [deleteButton, resetButton])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneButton = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            self.appLogic.events[indexPath.row].state = State.done.rawValue
            self.appLogic.events[indexPath.row].date = Date()
            self.appLogic.saveItems()
            self.segmentedControl.selectedSegmentIndex = 0
            tableView.reloadData()
            self.setTimer()
        }
        doneButton.backgroundColor = .systemGreen
        doneButton.image = UIImage(systemName: "checkmark.circle")
        
        let config = UISwipeActionsConfiguration(actions: [doneButton])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    // Stops a timer if cell swiping action have began
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if timer.isValid {
            timer.invalidate()
        }
    }
   
    // Starts a timer if cell swiping action was canceled
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if segmentedControl.selectedSegmentIndex == 0 {
            setTimer()
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
            return
        }
        
        // Create a search request
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let mainPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        let categoryPredicate = NSPredicate(format: "state CONTAINS %@",
                                            segmentedControl.selectedSegmentIndex == 1 ? State.passed.rawValue : segmentedControl.selectedSegmentIndex == 2 ? State.done.rawValue : "e")
        let combinedPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [mainPredicate, categoryPredicate])
        request.predicate = combinedPredicate
        
        // Create a sorting descript that will apply to our requeest
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        // Sending the request
        appLogic.loadItems(with: request, sortedBy: sortDescriptor)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Will load the whole [Item] because of loadItems() default input
        if searchBar.text?.count == 0 {
            segmentedControl.selectedSegmentIndex = 0
            appLogic.loadItems()
            tableView.reloadData()
        }
    }
}
