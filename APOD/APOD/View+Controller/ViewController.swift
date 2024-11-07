//
//  ViewController.swift
//  APOD
//
//  Created by 홍진표 on 9/8/24.
//

import UIKit
import SwiftUI
import WebKit

// MARK: - View+Controller
class ViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Properties
    /// Behavioral Pattern: `Observer`
    private var apod: Apod? {
        willSet {}
        didSet { print("DidSet: \(String(describing: oldValue)) \n") }
    }
    
    /// Counter
    private var count: Int = 0
    
    /// Timer
    private var timer: Timer?
    
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
    
    /// 웹 뷰
    private lazy var apodWebView: WKWebView = {
        let webView: WKWebView = WKWebView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.contentMode = .scaleAspectFit
        
        return webView
    }()
    
    /// 웹 뷰 인디케이터
    private let webViewIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.color = UIColor.gray
        
        return indicator
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
    }
    
    // MARK: - Custom Methods (UI Setup, AutoLayout)
    /// Setup Views
    private func setupUI() -> Void {
        
        view.backgroundColor = .systemBackground
        
        apodWebView.navigationDelegate = self
        
        /// hStackView에 뷰 추가
        _ = [loadButton, clearButton, timeLabel].map { hStackView.addArrangedSubview($0) }
        
        /// scrollView에 뷰 추가
        scrollView.addSubview(contentView)
        
        /// contentVIew에 explanationLabel 추가
        contentView.addSubview(explanationLabel)
        
        /// 웹 뷰 숨김
        apodWebView.isHidden = true
        
        /// 모든 뷰 추가
        [activityIndicator, apodImageView, apodWebView, webViewIndicator, titleLabel, dateLabel, scrollView, hStackView].forEach { self.view.addSubview($0) }
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
            
            /// apodWebView Constraints
            apodWebView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            apodWebView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            apodWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            apodWebView.heightAnchor.constraint(equalToConstant: (view.safeAreaLayoutGuide.layoutFrame.height / 2) - 50),
            
            /// webViewIndicator Constraints
            webViewIndicator.centerXAnchor.constraint(equalTo: apodWebView.centerXAnchor),
            webViewIndicator.centerYAnchor.constraint(equalTo: apodWebView.centerYAnchor),
            
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
    
    // MARK: - Actions (Event Handler)
    /// loadButton Action
    @objc private func loadButtonPressed() -> Void {
        
        activityIndicator.startAnimating()
        
        /// 시간초 증가 (타이머 시작)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self: ViewController = self else { return }
            
            /// 0.1초마다 1씩 증가
            self.count += 1
            
            DispatchQueue.main.async {
                self.timeLabel.text = "Loading Time: \(self.count)"
            }
        }
        
        /// `QoS (Quality of Service)`
        /// ref. https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html
        /// ref. https://unnnyong.com/2020/05/14/ios-thread-queue-gcd-qos/
        DispatchQueue.global(qos: .userInteractive).async {
            NetworkManager.shared.fetchApod { [weak self] result in
                /// `[weak self]`로 fetchApod()의 escaping closure (completion)가 ViewController를 약하게 참조 (Memory Leaks 방지)
                
                guard let `self`: ViewController = self else { return }
                /// weak self 사용으로 인해 self (ViewController) 가 옵셔널이 되므로, 옵셔널 바인딩을 통해 클로저 시작 시, self 에 대한 임시 강한 참조 생성
                /// 즉, closure 내부에서 self (ViewController)가 유효한지 확인하는 과정
                
                switch result {
                case .success(let apod):
                    print("========== Successfully fetched data ========== \n\(apod) \n")
                    self.apod = apod
                    break;
                case .failure(let error):
                    print(error.localizedDescription)
                    break;
                }
                
                /// fetchApod의 escaping closure로 데이터를 잘 받아왔다면 계속 진행, 아니면 return / url을 통해 mediaType 결정
                guard let apod: Apod = self.apod,
                      let mediaType: MediaType = MediaType(from: self.apod?.url ?? "") else { return }
                
                /// mediaType의 경우에 따라
                switch mediaType {
                    /// 1. 이미지인 경우
                case .image(_):
                    ImageCacheManager.loadData(from: apod.url ?? "") { [weak self] result in
                        guard let `self`: ViewController = self else { return }
                        
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                /// UI 업데이트 및 타이머 중지
                                self.apodImageView.image = image
                                
                                self.activityIndicator.stopAnimating()
                                self.timer?.invalidate()
                                self.timer = nil
                                
                                self.titleLabel.text = apod.title
                                self.dateLabel.text = apod.date
                                self.explanationLabel.text = apod.explanation
                            }
                            break;
                        case .failure(let error):
                            print(error.localizedDescription)
                            break;
                        }
                    }
                    break;
                    
                    /// 2. 비디오인 경우
                case .video(let videoURL):
                    DispatchQueue.main.async {
                        /// 비디오면 이미지 뷰를 숨기고 웹 뷰 활성화
                        self.apodWebView.isHidden = false
                        self.apodImageView.isHidden = true
                        
                        guard let absoluteURL: URL = URL(string: videoURL.absoluteString) else { return }
                        let request: URLRequest = URLRequest(url: absoluteURL)
                        
                        self.apodWebView.load(request)
                        
                        self.activityIndicator.stopAnimating()
                        self.timer?.invalidate()
                        self.timer = nil
                        
                        self.titleLabel.text = apod.title
                        self.dateLabel.text = apod.date
                        self.explanationLabel.text = apod.explanation
                    }
                    break;
                }
            }
        }
    }
    
    /// clearButton Action
    @objc private func clearButtonPressed() -> Void {
        
        count = 0
        timeLabel.text = nil
        apodImageView.image = nil
        apodWebView.isHidden = true
        titleLabel.text = nil
        dateLabel.text = nil
        explanationLabel.text = nil
    }
    
    // MARK: - WKNavigationDelegate Methods
    /// webView에 로딩 중일 때 인디케이터 활성화
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.webViewIndicator.startAnimating()
        self.webViewIndicator.isHidden = false
    }
    
    /// webView에 로딩이 완료시, 인디케이터 비활성화
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webViewIndicator.stopAnimating()
        self.webViewIndicator.isHidden = true
    }
    
    /// webView에 로딩 실패 시, 인디케이터 비활성화
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        self.webViewIndicator.stopAnimating()
        self.webViewIndicator.isHidden = true
    }
    
    
}

#Preview(body: {
    ViewController()
})

