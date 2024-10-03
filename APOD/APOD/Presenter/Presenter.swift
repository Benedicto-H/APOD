//
//  Presenter.swift
//  APOD
//
//  Created by 홍진표 on 9/13/24.
//

import Foundation
import UIKit

// MARK: - PresenterView Pr
/// Abstract the View behind a Protocol
/// `View`에서 구현되어야 할 메서드를 정의
protocol PresenterDelegate: AnyObject {
    
    /// 인디케이터 실행
    func startLoading()
    
    /// 인디케이터 종료
    func stopLoading()
    
    /// timeLabel 설정
    func updateTimer(count: Int)
    
    /// 뷰 그리기 (-> 이미지)
    func displayImage(withApod apod: Apod, image: UIImage)
    
    /// 뷰 그리기 (-> 비디오)
    func displayVideo(withApod apod: Apod, video: URLRequest)
    
    /// 뷰 초기화
    func clearUI()
}

// MARK: - Presenter
/// `Model`과 `View` 사이의 중재자
/// `View`로부터 들어온 Input에 대한 로직 처리 (-> `화면이랑은 상관없게 됨`)
final class Presenter {
    
    // MARK: - Properties
    /// Behavioral Pattern: `Observer`
    private var apod: Apod? {
        willSet {}
        didSet { print("didSet: \(String(describing: oldValue)) \n") }
    }
    
    /// Counter
    private var count: Int = 0
    
    /// Timer
    private var timer: Timer?
    
    /// ViewController에 대한 참조를 제공
    private weak var delegate: PresenterDelegate?
    
    // MARK: - Methods
    init(delegate: PresenterDelegate) {
        self.delegate = delegate
    }
    
    /// loadButton Action 처리
    func didTapLoadButton() -> Void {
        fetchData()
    }
    
    /// clearButton Action 처리
    func didTapClearButton() -> Void {
        clearData()
    }
    
    func fetchData() -> Void {
        
        self.delegate?.startLoading()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let `self`: Presenter = self else { return }
            
            self.count += 1
            
            DispatchQueue.main.async {
                self.delegate?.updateTimer(count: self.count)
            }
        })
        
        DispatchQueue.global(qos: .userInteractive).async {
            APICaller.shared.fetchApod { [weak self] result in
                guard let `self`: Presenter = self else { return }
                
                switch result {
                case .success(let apod):
                    print("========== Successfully fetched data ========== \n\(apod) \n")
                    
                    self.apod = apod
                    break;
                case .failure(let error):
                    print(error.localizedDescription)
                    break;
                }
                
                guard let apod: Apod = self.apod,
                      let mediaType: MediaType = MediaType(from: apod.url ?? "") else { return }
                
                switch mediaType {
                case .image(_):
                    loadImage(with: apod)
                    break;
                case .video(_):
                    loadVideo(with: apod)
                    break;
                }
            }
        }
    }
    
    private func loadImage(with apod: Apod) -> Void {
        
        ImageCacheManager.loadData(from: apod.url ?? "") { [weak self] result in
            guard let `self`: Presenter = self else { return }
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.delegate?.displayImage(withApod: apod, image: image)
                    self.delegate?.stopLoading()
                    self.timer?.invalidate()
                    self.timer = nil
                }
                break;
            case .failure(let error):
                print(error.localizedDescription)
                break;
            }
        }
    }
    
    private func loadVideo(with apod: Apod) -> Void {
        
        DispatchQueue.main.async {
            
            guard let absoluteURL: URL = URL(string: apod.url ?? "") else { return }
            let request: URLRequest = URLRequest(url: absoluteURL)
            
            self.delegate?.displayVideo(withApod: apod, video: request)
            self.delegate?.stopLoading()
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func clearData() -> Void {
        
        self.count = 0
        self.delegate?.clearUI()
    }
}
