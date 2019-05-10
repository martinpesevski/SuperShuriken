//
//  EndGameMenu.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/27/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

protocol EndGameDelegate: class {
    func onRetry()
    func onMenu()
}

class EndGameMenu: UIView {
    weak var delegate: EndGameDelegate?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Game Over"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Your total score is \(GameManager.sharedInstance.score)"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    lazy var retryButton: MenuButton = {
        let button = MenuButton()
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(onRetryTap), for: .touchUpInside)
        
        return button
    }()
    
    lazy var menuButton: MenuButton = {
        let button = MenuButton()
        button.setTitle("Menu", for: .normal)
        button.addTarget(self, action: #selector(onMenuTap), for: .touchUpInside)
        
        return button
    }()
    
    lazy var content: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, retryButton, menuButton])
        stack.spacing = 30
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalCentering

        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.orange
        layer.cornerRadius = 10
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 5
        layer.masksToBounds = false;
        layer.shadowOffset = CGSize(width: 15,height: 20);
        layer.shadowRadius = 5;
        layer.shadowOpacity = 0.5;
        
        addSubview(content)

        content.snp.makeConstraints { make in
            make.width.equalTo(340)
            make.center.edges.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onMenuTap() {
        delegate?.onMenu()
    }
    
    @objc func onRetryTap() {
        delegate?.onRetry()
    }
}
