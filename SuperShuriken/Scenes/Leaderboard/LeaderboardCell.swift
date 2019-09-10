//
//  LeaderboardCell.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/17/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import GameKit

class LeaderboardCell: UITableViewCell {
    lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    lazy var container: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rankLabel, nameLabel, scoreLabel])
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        
        return stack
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var score: GKScore? {
        willSet {
            guard let value = newValue else {return}
            
            self.nameLabel.text = value.player?.displayName
            self.scoreLabel.text = value.formattedValue
            self.rankLabel.text = "\(value.rank)."
        }
    }
}
