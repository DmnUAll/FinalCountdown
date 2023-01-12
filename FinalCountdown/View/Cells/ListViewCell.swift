import UIKit

// MARK: - ListViewCell
final class ListViewCell: UITableViewCell {

    // MARK: - Properties and Initializers
    lazy var eventNameLabel: UILabel = {
        makeLabel(withText: "Event Name", fontWeight: .bold, color: .fcCream, andSize: 15)
    }()

    lazy var eventDescriptionLabel: UILabel = {
        makeLabel(withText: "Event Description", fontWeight: .regular, color: .fcGrayLight)
    }()

    lazy var eventDateLabel: UILabel = {
        let label = makeLabel(withText: "Event Date", fontWeight: .regular, color: .black)
        label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        return label
    }()

    lazy var timeLeftLabel: UILabel = {
        let label = makeLabel(withText: "Time Left", fontWeight: .regular, color: .black)
        label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        return label
    }()

    private lazy var topStackView: UIStackView = {
        makeStackView(withAxis: .horizontal, alignment: .leading)
    }()

    private lazy var bottomStackView: UIStackView = {
        makeStackView(withAxis: .horizontal, alignment: .trailing)
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = makeStackView(withAxis: .vertical, andDistribution: .fillEqually)
        stackView.toAutolayout()
        return stackView
    }()

    private lazy var cellView: UIView = {
        let view = UIView()
        view.toAutolayout()
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .fcGreenDark
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        backgroundColor = .fcGreenLight
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Helpers
extension ListViewCell {

    private func addSubviews() {
        topStackView.addArrangedSubview(eventNameLabel)
        topStackView.addArrangedSubview(eventDateLabel)
        bottomStackView.addArrangedSubview(eventDescriptionLabel)
        bottomStackView.addArrangedSubview(timeLeftLabel)
        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(bottomStackView)
        cellView.addSubview(mainStackView)
        addSubview(cellView)
    }

    private func setupConstraints() {
        let constraints = [
            cellView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            cellView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            cellView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            cellView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            mainStackView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 18),
            mainStackView.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 6),
            mainStackView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -18),
            mainStackView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -6)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func makeLabel(withText text: String,
                           fontWeight: UIFont.Weight,
                           color: UIColor,
                           andSize size: CGFloat = 12
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: size, weight: fontWeight)
        label.textColor = color
        return label
    }

    private func makeStackView(withAxis axis: NSLayoutConstraint.Axis,
                               alignment: UIStackView.Alignment = .fill,
                               andDistribution distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = 0
        return stackView
    }
}
