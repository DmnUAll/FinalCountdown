import UIKit

// MARK: - CalendarCellDelegate protocol
protocol CalendarCellDelegate: AnyObject {
    func checkSelectedDate()
}

// MARK: - CalendarCell
final class CalendarCell: UITableViewCell {

    weak var delegate: CalendarCellDelegate?

    // MARK: - Properties and Initializers
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.toAutolayout()
        datePicker.tintColor = .fcGreenDark
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        return datePicker
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .fcGreenLight
        addSubviews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Helpers
extension CalendarCell {

    @objc private func dateSelected() {
        delegate?.checkSelectedDate()
    }

    private func addSubviews() {
        addSubview(datePicker)
    }

    private func setupConstraints() {
        let constraints = [
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            datePicker.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
