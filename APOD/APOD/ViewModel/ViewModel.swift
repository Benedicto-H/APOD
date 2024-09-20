//
//  ViewModel.swift
//  APOD
//
//  Created by 홍진표 on 9/15/24.
//

import Foundation
import UIKit

// MARK: - ViewModel
/// `ViewModel`은 `바인딩을 통해 UI를 갱신한다.`
/// 따라서, `View`와 `ViewModel`은 `N:1 관계` 성립
///
/// 바인딩을 구현할 수 있는 기술들
/// - KVO, NotificationCenter, Delegation Pattern, Property Observers, Custom Observable, Closure, etc.
final class ViewModel {
    
    // MARK: - Properties
    /// Observables: 값을 방출
    var apod: Observable<Apod?> = Observable<Apod?>(nil)
    var cacheImage: Observable<UIImage?> = Observable<UIImage?>(nil)
    var loadingTime: Observable<Int?> = Observable<Int?>(nil)
    var isLoading: Observable<Bool> = Observable<Bool>(false)
    
    private var count: Int = 0
    private var timer: Timer?
    
    // MARK: - Methods
    init() {}
    
    private func startTimer() {
        
        isLoading.value = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let `self`: ViewModel = self else { return }
            
            self.count += 1
            self.loadingTime.value = self.count
        }
    }
    
    func stopTimer() {
        
        isLoading.value = false
        count = 0
        timer?.invalidate()
        timer = nil
    }
    
    func fetchData() -> Void {
        
        startTimer()
        
        DispatchQueue.global(qos: .userInteractive).async {
            APICaller.shared.fetchApod { [weak self] result in
                guard let `self`: ViewModel = self else { return }
                
                switch result {
                case .success(let apod):
                    print("========== Successfully fetched data ==========")
                    
                    loadImage(with: apod) {
                        DispatchQueue.main.async {
                            self.stopTimer()
                        }
                    }
                    break;
                case .failure(let error):
                    self.apod.value = nil
                    print(error.localizedDescription)
                    break;
                }
            }
        }
    }
    
    private func loadImage(with apod: Apod, completion: @escaping () -> Void) -> Void {
        
        ImageCacheManager.loadImage(from: apod.url ?? "") { [weak self] result in
            guard let `self`: ViewModel = self else { return }
            
            switch result {
            case .success(let image):
                print("========== Successfully loaded image ==========")
                
                self.cacheImage.value = image
                self.apod.value = apod
                
                completion()
                break;
            case .failure(let error):
                self.cacheImage.value = nil
                print(error.localizedDescription)
                break;
            }
        }
    }
    
    func clear() -> Void {
        
        self.apod.value = nil
        self.cacheImage.value = nil
        self.loadingTime.value = 0
    }
}
