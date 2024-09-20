# APOD

## 🎯 개요
**NASA Open APIs를 활용한 1일 1천문학 정보**
> ref. [NASA Open APIs](https://api.nasa.gov)

<br>

## 📖 학습 포인트
- MVP -> **MVVM**

<br>

## ✅ 개선한 점
|MVP|MVVM|
|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/45b61459-5e7f-4f92-80a0-caf53ee597d7">|<img src="https://github.com/user-attachments/assets/f7521118-8f5a-4fbb-b766-ee7ba21e9cc6">|

MVP에서는 View (UIViewController)와 Presenter가 1:1 관계를 가짐으로써, 하나의 View에 매번 하나의 Presenter를 만들어주어야 했음. 이 문제를 ViewModel이라는 개념을 통해 해결
> 즉, Presenter가 가지는 비즈니스 로직을 ViewModel을 통해 공통으로 처리하면서, ViewModel은 View에 보여지는 데이터 요소만을 가지고 있음

|View (UIViewController)|ViewModel|
|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/8762ba87-e941-4c1e-a651-8422669978b1">|<img src="https://github.com/user-attachments/assets/b202d109-b1e8-4890-bd66-af895d6cbba8">|

- Model: 서비스에 사용되어지는 원천 (source) 데이터
  
- View: Controller와 View (Button, Label 등)를 하나의 View로 취급함
  > View = UIView (Button, label etc.) + UIViewController
  
- ViewModel: View와 Model의 중재자 역할로서, View의 Life Cycle에 관여하지 않음.
  <br>
  
**MVVM Flow**: _View가 이벤트를 받으면 -> 이벤트가 뷰모델로 전달되어 상태를 변경 -> 자신의 상태를 View에게 알림 -> 바인딩을 통해 UI를 갱신_
> 이 때, View가 ViewModel로부터 UI를 갱신하는 과정에서 **바인딩 (Binding)** 의 개념이 도입됨
>
> 즉, ViewModel은 View가 그려야 할 데이터를 갖고 있으면서 이를 Observable (방출)하고, View는 ViewModel의 상태를 지켜본다 (Observed, 관찰)
<br>

- iOS 환경에서 바인딩을 구현할 수 있는 기술들
  - KVO Key-Value Observing)
  - NotificationCenter
  - Delegation Pattern
  - Property Observers
  - Custom Observable
  - Closure
  - etc.
  <br>

- Observable.swift
  ```swift
  // MARK: - Custom Observable
  /// Generic 타입 T를 통해 어떠한 데이터 타입도 저장 되도록 함
  final class Observable<T> {
   
      // MARK: - Properties
      /// Behavioral Pattern: `Observer`
      var value: T {
          didSet {
              /// listener를 통해 새로운 값을 전달
              listener?(value)
          }
      }
    
      private var listener: ((T) -> Void)?
  
      // MARK: - Methods
      init(_ value: T) {
          self.value = value
      }
  
      /// 외부에서 전달된 closure를 listener로 설정
      func bind(_ closure: @escaping ((T) -> Void)) -> Void {
    
          closure(value)
          listener = closure
      }
  }
  ```
  <br>

- ViewModel.swift
  ```swift
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
      //  생략..
  ```
  <br>

- ViewController.swift
  ```swift
  class ViewController: UIViewController {
  
      // MARK: - Property
      lazy var viewModel: ViewModel = ViewModel()

      //  생략..
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
  ```
  <br>

## 💣 문제점
- **ViewModel 관리** + **바인딩의 불편함** + **상태관리의 어려움**
  
  <img src="https://github.com/user-attachments/assets/3f9fd5b7-7be8-419c-8f39-7b01b5996ee0" width="50%" height="50%">
  
  > 이미지 출처: https://github.com/iamchiwon/RxSwift_In_4_Hours
  
  - **ViewModel**은 **여러 Views에서 재사용 (공유)되어질 데이터와 비즈니스 로직을 갖고 있기 때문에** VM이 너무 많은 책임을 지게 되면, 비대해지고 유지보수가 어려워짐.
    
    > 💡 Presenter vs ViewModel
    > 
    > : **Presenter는** View와 1:1 대응관계로 **View를 참조**하지만, **ViewModel**은 View와 N:1 대응관계를 가지면서 **View를 참조하지 않음!**

  - KVO, Property Observers, Closures, Custom Observable, NotificationCenter 등은 바인딩이라고 표현하기에는 애매한 감이 있고 사용법 또한 불편함. (-> 이를 RxSwift나 Combine Framework와 같은 **Reactive Programming** 으로 해결할 수 있음.)
 
  - 만약, UI의 상태를 관리하는 ViewModel이 복잡한 상태관리를 필요로 한다면 상태를 관리하는 과정이 복잡해질 수도 있음. (-> 이를 ReactorKit (UIKit) 또는 TCA (SwiftUI)로 해결 가능)
