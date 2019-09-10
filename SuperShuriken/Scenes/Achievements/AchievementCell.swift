//
//  AchievementCell.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/29/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import GameKit

class AchievementCell: UITableViewCell {
    var achievement: Achievement? {
        willSet {
            guard let newValue = newValue else { return }
            
            titleLabel.text = newValue.details?.title
            descriptionLabel.text = newValue.achievement?.isCompleted ?? false ? newValue.details?.achievedDescription : newValue.details?.unachievedDescription
            achievementImage.image = UIImage(named: "ic_shuriken3")
            checkmarkImage.isHidden = newValue.achievement?.isCompleted ?? true
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    lazy var achievementImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        return image
    }()
    
    lazy var checkmarkImage: UIImageView = {
        let image = UIImageView(image: UIImage.init(named: "checkmark")?.withRenderingMode(.alwaysTemplate))
        image.contentMode = .scaleAspectFill
        image.tintColor = .green
        
        return image
    }()
    
    lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        return stack
    }()
    
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [achievementImage, verticalStack, checkmarkImage])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        
        checkmarkImage.snp.makeConstraints({ make in
            make.width.height.equalTo(30)
        })
        
        achievementImage.snp.makeConstraints({ make in
            make.width.height.equalTo(40)
        })
        
        return stack
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
