//
//  ViewController.swift
//  APOD
//
//  Created by 홍진표 on 9/8/24.
//

import UIKit
import SwiftUI

// MARK: - View+Controller
class ViewController: UIViewController {
    
    // MARK: - Property
    lazy var viewModel: ViewModel = ViewModel()
    
    // MARK: - Views
    /// 인디케이터 뷰
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.gray
        
        return indicator
    }()
    
    /// 이미지 뷰
    private lazy var apodImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    /// 제목 레이블
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .dynamicTextColor
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 25)
        
        return label
    }()
    
    /// 날짜 레이블
    private let dateLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .dynamicTextColor
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 15)
        
        return label
    }()
    
    /// 스크롤 뷰
    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    /// 스크롤 뷰에 올려질 컨텐트 뷰
    private let contentView: UIView = {
        let view: UIView = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    /// 설명 레이블
    private let explanationLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .dynamicTextColor
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 15)
        
        return label
    }()
    
    /// 이미지 불러오기 버튼
    private let loadButton: UIButton = {
        let button: UIButton = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Load Picture", for: .normal)
        button.setTitleColor(.dynamicTextColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(loadButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    /// 초기화 버튼
    private let clearButton: UIButton = {
        let button: UIButton = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.dynamicTextColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray
        button.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    /// 시간초 레이블
    private let timeLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .dynamicTextColor
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    /// loadButton과 clearButton을 StackView로 관리
    private var hStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    // MARK: - Methods (View Life cycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        applyConstraints()
        
        bindUI()
    }
    
    // MARK: - Custom Methods (UI Setup, AutoLayout, Binding)
    /// Setup Views
    private func setupUI() -> Void {
        
        view.backgroundColor = .systemBackground
        
        /// hStackView에 뷰 추가
        _ = [loadButton, clearButton, timeLabel].map { hStackView.addArrangedSubview($0) }
        
        /// scrollView에 뷰 추가
        scrollView.addSubview(contentView)
        
        /// contentVIew에 explanationLabel 추가
        contentView.addSubview(explanationLabel)
        
        /// 모든 뷰 추가
        [activityIndicator, apodImageView, titleLabel, dateLabel, scrollView, hStackView].forEach { self.view.addSubview($0) }
    }
    
    /// AutoLayout
    private func applyConstraints() -> Void {
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(contentsOf: [
            /// activityIndicator Constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            /// apodImageView Constraints
            apodImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            apodImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            apodImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            apodImageView.heightAnchor.constraint(equalToConstant: (view.safeAreaLayoutGuide.layoutFrame.height / 2) - 50),
            
            /// titleLabel Constraints
            titleLabel.leadingAnchor.constraint(equalTo: apodImageView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: apodImageView.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: apodImageView.bottomAnchor, constant: 20),
            
            /// dateLabel Constraints
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            /// scrollView Constraints
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: hStackView.topAnchor, constant: -20),
            
            /// contentView Constraints
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            /// explanationLabel Constraints
            explanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            explanationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            explanationLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            explanationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            /// loadButton Constraint
            loadButton.widthAnchor.constraint(equalToConstant: 100),
            
            /// clearButton Constraint
            clearButton.widthAnchor.constraint(equalToConstant: 80),
            
            /// hStackView Constraints
            hStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            hStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            hStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Binding
    private func bindUI() {
        
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let `self`: ViewController = self else { return }

            DispatchQueue.main.async {
                if (isLoading == true) {
                    self.activityIndicator.startAnimating()
                    self.timeLabel.isHidden = false
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.loadingTime.bind { [weak self] time in
            guard let `self`: ViewController = self else { return }
            
            DispatchQueue.main.async {
                self.timeLabel.text = "Loading Time: \(time ?? 0)"
            }
        }
        
        viewModel.cacheImage.bind { [weak self] image in
            guard let `self`: ViewController = self else { return }
            
            DispatchQueue.main.async {
                self.apodImageView.image = image
            }
        }
        
        viewModel.apod.bind { [weak self] apod in
            guard let `self`: ViewController = self else { return }
            
            DispatchQueue.main.async {
                self.titleLabel.text = apod?.title
                self.dateLabel.text = apod?.date
                self.explanationLabel.text = apod?.explanation
            }
        }
    }

    
    // MARK: - Actions (Event Handler)
    /// loadButton Action
    @objc private func loadButtonPressed() -> Void {
        
        viewModel.fetchData()
    }
    
    /// clearButton Action
    @objc private func clearButtonPressed() -> Void {
        
        viewModel.clear()
        timeLabel.isHidden = true
    }


}

//#Preview(body: {
//    ViewController()
//})

