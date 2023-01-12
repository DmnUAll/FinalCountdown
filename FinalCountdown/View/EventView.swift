import UIKit

// MARK: - EventView
final class EventView: UIView {

    // MARK: - Properties and Initializers
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.toAutolayout()
        tableView.register(EventNameCell.self, forCellReuseIdentifier: "eventNameCell")
        tableView.register(EventDescriptionCell.self, forCellReuseIdentifier: "eventDescriptionCell")
        tableView.register(CalendarCell.self, forCellReuseIdentifier: "calendarCell")
        tableView.backgroundColor = .fcGreenDark
        tableView.allowsSelection = false
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .fcGreenLight
        toAutolayout()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
extension EventView {

    private func addSubviews() {
        addSubview(tableView)
    }

    private func setupConstraints() {
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
