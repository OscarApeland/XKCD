//
//  WelcomeViewController.swift
//  XKCD
//
//  Created by Oscar Apeland on 11/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
        
    
    // MARK: Outlets
    
    let titleLabel = UILabel()
    
    let continueButton = UIButton()
    
    let stackView = UIStackView()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 40.0, weight: .bold)
        titleLabel.text = NSLocalizedString("XKCD Viewer by Oscar Apeland", comment: "")
        titleLabel.textColor = .label

        continueButton.backgroundColor = .label
        continueButton.titleLabel?.font = .title
        continueButton.setTitleColor(.systemBackground, for: .normal)
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 100.0, left: 0, bottom: 100.0, right: 0)
        scrollView.showsVerticalScrollIndicator = false
        
        stackView.alignment = .top
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        [scrollView, continueButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.sidePadding),
            continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .sidePadding),
            continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -.sidePadding),
            continueButton.heightAnchor.constraint(equalToConstant: 50.0),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .sidePadding),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -.sidePadding),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -.viewSpacing),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(.sectionSpacing, after: titleLabel)
        
        [
            (title: "View XKCDs", detail: "Scroll comics in a clean and familiar layout."),
            (title: "Context Menus Are Cool", detail: "Long press on a comic to save, share or get an explanation."),
            (title: "Keep Your Favorites", detail: "Saved posts are easily accessible from the heart button."),
            (title: "Find That Relevant One", detail: "Search by any term or comic number to get your relevant XKCD."),
            (title: "Browse Anywhere", detail: "Every comic you see is saved offline for later viewing."),
            (title: "Completely Private", detail: "Zero tracking, analytics or cloud data."),
        ].forEach { text in
            let titleLabel = UILabel()
            titleLabel.text = text.title
            titleLabel.textColor = .label
            titleLabel.numberOfLines = 0
            titleLabel.font = .systemFont(ofSize: 16.0, weight: .bold)
            
            let detailLabel = UILabel()
            detailLabel.text = text.detail
            detailLabel.textColor = .label
            detailLabel.numberOfLines = 0
            detailLabel.font = .systemFont(ofSize: 16.0, weight: .regular)
            
            stackView.addArrangedSubview(titleLabel)
            stackView.setCustomSpacing(.viewSpacing, after: titleLabel)
            
            stackView.addArrangedSubview(detailLabel)
            stackView.setCustomSpacing(.sectionSpacing, after: detailLabel)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Self.hasSeenWelcome = true
    }
    
    
    // MARK: Actions
    
    @objc func continuePressed() {
        dismiss(animated: true)
    }
    
    static var hasSeenWelcome: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasSeenWelcome")
        }
        set {
            UserDefaults.standard.setValue(true, forKey: "hasSeenWelcome")
        }
    }
}
