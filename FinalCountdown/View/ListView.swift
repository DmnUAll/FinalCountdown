import UIKit

// MARK: - ListViewDelegate protocol
protocol ListViewDelegate: AnyObject {
    func segmentedControlDidChangeValue(to selectedSegment: Int)
}

// MARK: - ListView
final class ListView: UIView {

    // MARK: - Properties and Initializers
    weak var delegate: ListViewDelegate?

    // MARK: - Properties and Initializers
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["All", "Passed", "Done"])
        segmentedControl.toAutolayout()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .fcGrayLight
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.fcGrayLight], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        return segmentedControl
    }()

    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.toAutolayout()
        searchBar.barTintColor = .fcGreenDark
        searchBar.searchTextField.backgroundColor = .fcGreenLight
        searchBar.searchTextField.tintColor = .fcGreenDark
        searchBar.searchTextField.textColor = .fcGrayLight
        return searchBar
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.toAutolayout()
        tableView.register(ListViewCell.self, forCellReuseIdentifier: "listCell")
        tableView.backgroundColor = .fcGreenLight
        tableView.separatorStyle = .none
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        toAutolayout()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
extension ListView {

    @objc private func segmentDidChange() {
        delegate?.segmentedControlDidChangeValue(to: segmentedControl.selectedSegmentIndex)
    }

    private func addSubviews() {
        addSubview(segmentedControl)
        addSubview(searchBar)
        addSubview(tableView)
    }

    private func setupConstraints() {
        let constraints = [
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
