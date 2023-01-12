import UIKit

// MARK: - EventNameCell
final class EventNameCell: UITableViewCell {

    // MARK: - Properties and Initializers
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.toAutolayout()
        textField.layer.cornerRadius = 5
        textField.backgroundColor = .fcGrayLight
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: "Event name (30 characters max)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        return textField
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
extension EventNameCell {

    private func addSubviews() {
        addSubview(textField)
    }

    private func setupConstraints() {
        let constraints = [
            textField.heightAnchor.constraint(equalToConstant: 36),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
