import UIKit
import Common

class FilterView: UIView {

    private let applyButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private var buttons: [UIButton] = []
    let noOfOptionsInRow: Int = 3
    var selectedFilters: Set<FilterOption> = []

    var onApplyFilters: ((Set<FilterOption>) -> Void)?
    var onCancelFilters: (() -> Void)?

    // MARK: - Initialization Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI Methods
    private func setupUI() {
        backgroundColor = .lightGray
        layer.cornerRadius = LayoutConstants.defaultCornerRadius
        clipsToBounds = true

        let buttonTitles = [
            FilterOption.activeCoins.rawValue, FilterOption.inactiveCoins.rawValue, FilterOption.onlyCoins.rawValue,
            FilterOption.onlyTokens.rawValue, FilterOption.newCoins.rawValue
        ]

        for title in buttonTitles {
            let buttonHeight: CGFloat = 30
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
            button.layer.cornerRadius = buttonHeight / 2
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.addTarget(self, action: #selector(toggleFilterSelection(_:)), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: LayoutConstants.samllFontSize)
            buttons.append(button)
        }

        applyButton.setTitle(Localization.localizedString(for: "apply", defaultValue: "Apply"), for: .normal)
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: LayoutConstants.defaultFontSize)
        applyButton.layer.cornerRadius = LayoutConstants.buttonHeight / 2
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight).isActive = true

        cancelButton.setTitle(Localization.localizedString(for: "cancel", defaultValue: "Cancel"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelFilter), for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: LayoutConstants.defaultFontSize)
        cancelButton.layer.cornerRadius = LayoutConstants.buttonHeight / 2
        cancelButton.backgroundColor = .systemGray
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight).isActive = true

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = Spacing.defaultVerticalSpacing
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        var rowStackViews: [UIStackView] = []
        var rowButtons: [UIButton] = []

        for (index, button) in buttons.enumerated() {
            rowButtons.append(button)
            if rowButtons.count == noOfOptionsInRow || index == buttons.count - 1 {
                let rowStackView = UIStackView(arrangedSubviews: rowButtons)
                rowStackView.axis = .horizontal
                rowStackView.spacing = Spacing.smallHorizontalSpacing
                rowStackView.alignment = .center
                rowStackView.distribution = .fillEqually
                rowStackViews.append(rowStackView)
                rowButtons = []
            }
        }

        for rowStackView in rowStackViews {
            mainStackView.addArrangedSubview(rowStackView)
        }

        let actionButtonStackView = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        actionButtonStackView.axis = .horizontal
        actionButtonStackView.spacing = Spacing.smallHorizontalSpacing
        actionButtonStackView.alignment = .fill
        actionButtonStackView.distribution = .fillEqually
        mainStackView.addArrangedSubview(actionButtonStackView)

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: LayoutConstants.defaultMargin),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstants.defaultMargin),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstants.defaultMargin),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.defaultMargin)
        ])
    }

    func updateButtonStates() {
        for button in buttons {
            guard let title = button.title(for: .normal),
                  let option = FilterOption(rawValue: title) else { continue }
            if selectedFilters.contains(option) {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.systemBlue, for: .normal)
            }
        }
    }

    // MARK: - Private Methods
    @objc private func toggleFilterSelection(_ sender: UIButton) {
        guard let tagValue = sender.title(for: .normal),
              let option = FilterOption(rawValue: tagValue) else { return }
        sender.layer.borderColor = UIColor.systemBlue.cgColor

        if selectedFilters.contains(option) {
            selectedFilters.remove(option)
            sender.backgroundColor = .white
            sender.setTitleColor(.systemBlue, for: .normal)
        } else {
            selectedFilters.insert(option)
            sender.backgroundColor = .systemBlue
            sender.setTitleColor(.white, for: .normal)
        }
    }

    @objc private func applyFilters() {
        onApplyFilters?(selectedFilters)
    }

    @objc private func cancelFilter() {
        onCancelFilters?()
    }
}
