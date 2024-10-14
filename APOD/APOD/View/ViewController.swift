//
//  ViewController.swift
//  APOD
//
//  Created by 홍진표 on 9/8/24.
//

import UIKit
import SwiftUI
import WebKit

import RxSwift

// MARK: - View
class ViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Property
    lazy var viewModel: ViewModel = ViewModel()
    
    var disposeBag: DisposeBag = DisposeBag()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        APICaller.shared.fetchApodRx()
        /// `subscribe(on:)`: Observable이 작동할 Scheduler (Thread)를 지정 (즉, 특정 Scheduler에서 작업을 수행하도록 Observable에게 지시)
        /// 기본적으로 Observable은 subscribe()를 호출한 Thread에서 생성됨
        /// ref. https://reactivex.io/documentation/operators/subscribeon.html
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        /// `observe(on:)`: Observer가 Observable을 관찰할 Scheduler를 지정
        /// ref. https://reactivex.io/documentation/operators/observeon.html
            .observe(on: MainScheduler.instance)
            .subscribe { apod in
                // MARK: - Observation here
                print(apod)
            } onError: { error in
                // MARK: - Observation here
                print("***** error: \(error) *****")
            } onCompleted: {
                print("***** completed *****")
            }.disposed(by: disposeBag)
        
        /// * 일반적으로 `subscribeOn(_:)은 Background Thread`에서, `observeOn(_:)은 Main Thread`에서 사용
        
        // MARK: - Scheduler의 종류
        /// - `MainScheduler`
        ///     [설명]: 메인 스레드에서 작업 실행
        ///     [용도]: UI 업데이트와 같이 메인 스레드에서 실행해야 하는 작업에 적합
        ///     [특징]: 모든 작업이 순차적으로 실행되므로, 스레드 안전성이 보장 (Thread-safe)
        ///
        /// - `ConcurrentMainScheduler`
        ///     [설명]: 메인 스레드에서 비동기적으로 작업 실행
        ///     [용도]: 비동기적으로 작업을 처리해야 하지만, 메인 스레드에서 실행해야 하는 경우에 사용
        ///     [특징]: 병렬 처리 가능성이 있으므로, UI 업데이트에는 주의가 필요
        ///
        /// - `SerialDispatchQueueScheduler`
        ///     [설명]: 디스패치 큐에서 순차적으로 작업 실행
        ///     [용도]: 동시성을 피하고, 순차적으로 실행해야 하는 작업에 적합
        ///     [특징]: 사용자 정의 큐를 사용 가능, 다양한 작업 환경에 맞게 설정 가능
        ///
        /// - `ConcurrentDispatchQueueScheduler`
        ///     [설명]: 디스패치 큐에서 비동기적으로 작업 실행
        ///     [용도]: 여러 작업을 동시에 실행해야 할 때 유용
        ///     [특징]: 큐의 특성에 따라 동시 실행이 가능하므로, 멀티스레딩 환경에서 유용
        ///
        /// - `OperationQueueScheduler`
        ///     [설명]: OperationQueue에서 작업을 실행
        ///     [용도]: OperationQueue의 다양한 기능을 활용하여, 의존성 관리나 취소 기능이 필요한 작업에 적합
        ///     [특징]: 작업의 우선순위를 지정할 수 있고, 작업의 취소나 의존성을 설정할 수 있음
        ///
        /// - `TestScheduler`
        ///     [설명]: 테스트 환경에서 사용되는 스케줄러
        ///     [용도]: 비동기 코드의 테스트를 쉽게 수행할 수 있게 해줌
        ///     [특징]: 시간이 지연된 작업을 제어할 수 있어, 특정 시간에 발생하는 이벤트를 테스트 할 수 있음
    }
    
    // MARK: - Custom Methods (UI Setup, AutoLayout, Binding)
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
        
        viewModel.media.bind { [weak self] value in
            guard let `self`: ViewController = self else { return }
            
            if let image: UIImage = value as? UIImage {
                DispatchQueue.main.async {
                    self.apodImageView.image = image
                }
            } else if let videoURLRequest: URLRequest = value as? URLRequest {
                DispatchQueue.main.async {
                    
                    self.apodWebView.load(videoURLRequest)
                    self.apodWebView.isHidden = false
                    self.apodImageView.isHidden = true
                }
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
        loadButton.isHidden = true
    }
    
    /// clearButton Action
    @objc private func clearButtonPressed() -> Void {
        
        viewModel.clear()
        timeLabel.isHidden = true
        
        if (viewModel.media.value == nil) {
            apodImageView.image = nil
            apodWebView.isHidden = true
        }
        
        loadButton.isHidden = false
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

