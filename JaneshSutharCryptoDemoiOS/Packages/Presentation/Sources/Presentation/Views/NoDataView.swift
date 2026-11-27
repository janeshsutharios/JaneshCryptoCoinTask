//
//  NoDataView.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import UIKit
import Common

class NoDataView: UIView {

    private let iconImageView: UIImageView
    private let messageLabel: UILabel

    // MARK: - Initialization Methods
    override init(frame: CGRect) {
        iconImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        messageLabel = UILabel()
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupUI() {
        messageLabel.text = Localization.localizedString(
            for: "no_crypto_coins_available",
            defaultValue: "No crypto coins available at the moment."
        )
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: LayoutConstants.largeFontSize, weight: .medium)
        messageLabel.numberOfLines = 0

        iconImageView.tintColor = .gray
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.iconHeight).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.iconHeight).isActive = true

        let stackView = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        stackView.axis = .vertical
        stackView.spacing = Spacing.smallVerticalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstants.defaultMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstants.defaultMargin)
        ])
    }
}
