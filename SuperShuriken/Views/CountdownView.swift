//
//  CountdownNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/5/19.
//  Copyright © 2019 MP. All rights reserved.
//

import SpriteKit

class CountdownView: UIView {
    var counterLabel: UILabel = {
        let counter = UILabel()
        
        counter.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        counter.textColor = .white

        return counter
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(counterLabel)
        counterLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCounting(completion: @escaping ()->()) {
        pulse(counter: 3, completion: completion)
    }
    
    func pulse(counter: Int, completion: @escaping ()->()) {
        if counter <= 0 {
            counterLabel.alpha = 0
            completion()
            return
        }
        
        counterLabel.alpha = 0
        counterLabel.text = "\(counter)"
        counterLabel.transform = .identity
        UIView.animate(withDuration: 1, animations: {
            self.counterLabel.alpha = 1
            self.counterLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
        }) { [weak self] completed in
            guard let self = self else {
                completion()
                return
            }
            self.pulse(counter: counter - 1, completion: completion)
        }
    }
}
