//
//  DemoBannerCell.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class DemoBannerCell: TFYSwiftPagerViewCell {
    
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    var onActionTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        actionButton.setTitle("立即查看", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = .systemRed
        actionButton.layer.cornerRadius = 16
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        
        let gradient = UIView()
        gradient.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(gradient)
        contentView.addSubview(titleLabel)
        contentView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradient.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.35),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -10),
            
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 110),
            actionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(imageName: String, title: String) {
        coverImageView.image = DemoImages.image(named: imageName)
        titleLabel.text = title
    }
    
    @objc private func handleAction() {
        onActionTap?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onActionTap = nil
        coverImageView.image = nil
        titleLabel.text = nil
    }
}
