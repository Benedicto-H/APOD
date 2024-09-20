# APOD

## 🎯 개요
**NASA Open APIs를 활용한 1일 1천문학 정보**
> ref. [NASA Open APIs](https://api.nasa.gov)

<br>

## 📖 학습 포인트
- Cocoa MVC -> **MVP**

<br>

## ✅ 개선한 점
|Real CocoaMVC|MVP|
|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/580d7c69-59bd-45ec-9374-5e4298d4b725">|<img src="https://github.com/user-attachments/assets/6d6c2489-4bdb-433a-92ff-b3c64b3b6172">|

Cocoa MVC 패턴을 사용했을 때 ViewController (View + Controller)가 Massive해지는 문제를 MVP 패턴을 사용하여 해결
> 즉, MVC의 ViewController의 책임을 분산하여 ViewController가 UI만을 관리하고, Presenter를 통해 비즈니스 로직을 처리

|View (UIViewController)|Presenter|
|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/514f2731-5e14-4480-a881-238d90c58efa">|<img src="https://github.com/user-attachments/assets/042bfb26-2ad0-41be-9be0-281eff28c33f">|

- Model: 서비스에 사용되어지는 원천 (source) 데이터
  
- View: Controller와 View (Button, Label 등)를 하나의 View로 취급함
  > View = UIView (Button, label etc.) + UIViewController
  
- Presenter: View와 Model의 중재자 역할로서, View의 Life Cycle에 관여하지 않음.
  > Presenter = UI와는 관련이 없는, UI를 관리하는 요소
  <br>
  
**MVP Flow**: _View가 이벤트를 받으면 -> 반드시 Presenter에게 알림 -> Presenter는 Model과 소통하여 action에 대한 로직을 처리 -> View에게 그려야 될 요소들을 알려줌._
> 이 때, Presenter가 View와 인터랙션하는 방법은 주로 protocol을 통해 알려준다.
<br>

- Presenter.swift
  ```swift
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
    
      /// 뷰 그리기
      func display(with apod: Apod, image: UIImage)
    
      /// 뷰 초기화
      func clear()
  }
  ```
  <br>

- ViewController.swift (Extension)
  ```swift
  // MARK: - Extension ViewController
  /// `Presenter`로부터 Output을 받아 View를 그리는 작업에만 집중
  extension ViewController: PresenterDelegate {
    
      func startLoading() -> Void {
          activityIndicator.startAnimating()
      }
    
      func stopLoading() -> Void {
          activityIndicator.stopAnimating()
      }
    
      func updateTimer(count: Int) {
          self.timeLabel.text = "Loading Time: \(count)"
      }
    
      func display(with apod: Apod, image: UIImage) {
  
          self.apodImageView.image = image
          self.titleLabel.text = apod.title
          self.dateLabel.text = apod.date
          self.explanationLabel.text = apod.explanation
      }
    
      func clear() -> Void {
        
          timeLabel.text = nil
          apodImageView.image = nil
          titleLabel.text = nil
          dateLabel.text = nil
          explanationLabel.text = nil
      }
  }
  ```
  <br>

## 💣 문제점
- **View**와 **Presenter**의 관계
  
  <img src="https://github.com/user-attachments/assets/64c0cce7-eb04-4341-8f42-7395078319cf" width="50%" height="50%">
  
  - **View**와 **Presenter**가 **1:1 관계**로, View가 여러개라면 매번 Presenter를 만들어주어야 함! (-> 이 문제를 MVVM으로 해결할 수 있음)
    
    > 이미지 출처: https://github.com/iamchiwon/RxSwift_In_4_Hours
