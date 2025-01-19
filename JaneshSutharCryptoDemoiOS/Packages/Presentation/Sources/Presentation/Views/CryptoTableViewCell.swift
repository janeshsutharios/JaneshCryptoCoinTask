//
//  CryptoTableViewCell.swift
//  CryptoCoin
//
//  Created by Janesh Suthar.
//

import UIKit
import Common

class CryptoTableViewCell: UITableViewCell {
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let rightImageView = UIImageView()
    private let newTagLabel = UILabel()  // New Tag Label
    
    //MARK: - Initialization Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup Methods
    private func setupUI() {
        // Configure titleLabel
        titleLabel.font = UIFont.systemFont(ofSize: LayoutConstants.defaultFontSize, weight: .bold)
        titleLabel.textColor = .black
        
        // Configure subtitleLabel
        subtitleLabel.font = UIFont.systemFont(ofSize: LayoutConstants.mediumFontSize, weight: .regular)
        subtitleLabel.textColor = .darkGray
        
        // Configure rightImageView
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.clipsToBounds = true
        
        // Configure newTagLabel (for "New" tag)
        newTagLabel.isHidden = true // Initially hidden
        newTagLabel.text = "NEW"
        newTagLabel.textColor = .white
        newTagLabel.font = UIFont.systemFont(ofSize: LayoutConstants.samllFontSize, weight: .bold)
        newTagLabel.backgroundColor = .systemGreen
        newTagLabel.translatesAutoresizingMaskIntoConstraints = false // Disable autoresizing mask translation to constraints
        newTagLabel.transform = CGAffineTransform(rotationAngle: .pi / 4) // 45 degrees
        newTagLabel.textAlignment = .center // This will ensure that text remains centered after rotation
        newTagLabel.adjustsFontSizeToFitWidth = true // Optional: To make sure text is not clipped

        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(rightImageView)
        contentView.addSubview(newTagLabel) // Add the "New" tag
        
        // Set constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        newTagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.defaultMargin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.mediumMargin),
            titleLabel.trailingAnchor.constraint(equalTo: newTagLabel.leadingAnchor, constant: -LayoutConstants.mediumMargin),
            
            // Subtitle Label Constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.defaultMargin),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutConstants.smallMargin),
            subtitleLabel.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -LayoutConstants.mediumMargin),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -LayoutConstants.mediumMargin),
            
            // Right ImageView Constraints
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.defaultMargin),
            rightImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightImageView.widthAnchor.constraint(equalToConstant: 50),
            rightImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // New Tag Label Constraints
            newTagLabel.widthAnchor.constraint(equalToConstant: 50), // Set width
            newTagLabel.heightAnchor.constraint(equalToConstant: 12), // Set height
            newTagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15), // Position on the right
            newTagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5) // Position at the top
            
        ])
    }
    
    // MARK: - Configure Cell
    func configure(title: String, subtitle: String, image: UIImage?, isNew: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        rightImageView.image = image
        newTagLabel.isHidden = !isNew
    }
}
