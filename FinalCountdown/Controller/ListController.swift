import UIKit

// MARK: - ListController
final class ListController: UIViewController {

    // MARK: - Properties and Initializers
    private var presenter: ListPresenter?
    lazy var listView: ListView = {
        let listView = ListView()
        return listView
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fcGreenDark
        view.addSubview(listView)
        setupConstraints()
        listView.searchBar.delegate = self
        listView.tableView.dataSource = self
        listView.tableView.delegate = self
        presenter = ListPresenter(viewController: self)
        view.addKeyboardHiddingFeature()
        CoreDataManager.shared.loadItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listView.tableView.reloadData()
        presenter?.setTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.disableTimer()
    }
}

// MARK: - Helpers
extension ListController {

    private func setupConstraints() {
        let constraints = [
            listView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UISearchBarDelegate
extension ListController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.resignFirstResponder()
            return
        }
        presenter?.searchEvent(withName: searchBar.text)
        searchBar.resignFirstResponder()
        presenter?.disableTimer()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            listView.segmentedControl.selectedSegmentIndex = 0
            CoreDataManager.shared.loadItems()
            listView.tableView.reloadData()
        }
    }
}

// MARK: - UITAbleViewDataSource
extension ListController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfEvents = presenter?.returnNumberOfEvents() else { return 0 }
        return numberOfEvents
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = presenter?.configureCell(forIndexPath: indexPath, atTable: tableView) else {
            return UITableViewCell()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITableViewDelegate
extension ListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = presenter?.prepareData(forSelectedRow: indexPath.row) else { return }
        navigationController?.pushViewController(EventController(eventData: data), animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteButton = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, _  in
            guard let self = self else { return }
            CoreDataManager.shared.deleteEvent(at: indexPath.row)
            tableView.reloadData()
            self.presenter?.setTimer()
        }
        deleteButton.backgroundColor = .systemRed
        deleteButton.image = UIImage(systemName: "trash")
        let resetButton = UIContextualAction(style: .normal, title: "Re-set") { [weak self]_, _, _ in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "Re-set an event",
                                                    message: "Update the due date/time of the event.",
                                                    preferredStyle: .actionSheet)
            let dayAction = UIAlertAction(title: "To next day", style: .default) { _ in
                self.presenter?.updateDate(at: indexPath, by: .day)
            }
            alertController.addAction(dayAction)
            let monthAction = UIAlertAction(title: "To next month", style: .default) { _ in
                self.presenter?.updateDate(at: indexPath, by: .month)
            }
            alertController.addAction(monthAction)
            let yearAction = UIAlertAction(title: "To next year", style: .default) { _ in
                self.presenter?.updateDate(at: indexPath, by: .year)
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

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let doneButton = UIContextualAction(style: .destructive, title: "Done") { [weak self] _, _, _ in
            guard let self = self  else { return }
            self.presenter?.setToDone(itemAtIndex: indexPath.row)
            self.listView.segmentedControl.selectedSegmentIndex = 0
            tableView.reloadData()
            self.presenter?.setTimer()
        }
        doneButton.backgroundColor = .systemGreen
        doneButton.image = UIImage(systemName: "checkmark.circle")
        let config = UISwipeActionsConfiguration(actions: [doneButton])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        guard let timerIsWorking = presenter?.checkTimerState() else { return }
        if timerIsWorking {
            presenter?.disableTimer()
        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if listView.segmentedControl.selectedSegmentIndex == 0 {
            presenter?.setTimer()
        }
    }
}
