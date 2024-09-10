# APOD

## 🎯 개요
**NASA Open APIs를 활용한 1일 1천문학 정보**
> ref. [NASA Open APIs](https://api.nasa.gov)

<br>

## 📖 학습 포인트
- URLSession
- NSCache (Memory Cache)
- GCD (Grand Central Dispatch)
- Cocoa MVC

<br>

## 📱 결과
<img src="https://github.com/user-attachments/assets/0fde64c2-96d4-4af8-8355-717b36d1efde" width="50%" height="50%">

<br>

###  NSCache simulation
|No Cache|Using Cache|
|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/0980e419-d6e0-4009-a49f-0a0dd1ad6021">|<img src="https://github.com/user-attachments/assets/5d1d3cde-398a-4fa9-aba1-a0778e22449e">|

> 0.1초마다 1씩 증가하는 타이머를 통해 최초 이미지를 불러올 때, 2.8초의 시간이 소요되나 NSCache를 사용하여 이미지를 캐싱하였을 때, 0.2초만에 이미지를 불러오는 것을 확인할 수 있다.

<br>

## 🧐 고민한 점
- **closures 기반의 UI components를 구성할 때, `let` 또는 `lazy var`를 사용하는 것에 대한 고민**
  - UILabel, UIButton, UIScrollView 등과 같은 View들은 초기화 작업이 무겁지 않은 뷰 (즉, 화면에 즉시 표시되거나, 인스턴스가 인스턴스화되자마자 필요한 경우)이기 때문에, `let`을 사용
  - 네트워킹을 통한 API 호출로 인해 View가 그려지는 UIImageView는 이미지가 준비되면 초기화할 수 있도록 (즉, 성능 최적화를 위해 이미지가 필요한 시점까지 초기화를 지연) `lazy var`를 사용
    
    > 일반적으로 _'네트워크 지연시간 (Latency)'_, _'비동기 처리'_, _'자원 소모'_, _'네트워크 오류 처리'_, _'UI 블로킹 방지'_ 등의 이유로 네트워킹 작업은 무거운 작업으로 간주됨.
    <br>
    
- **escaping closures에서 self를 강한 참조하지 않도록 [weak self]를 사용**
  - escaping closures에서 `self` 키워드를 사용하면 closures의 context 수명 동안에는 `self (ViewController)`에 대해 closure와 `Strong Reference Cycles (강한 참조 사이클)`이 발생하여, 서로간의 Reference Count를 1 증가.
  - closure 실행이 끝나면, closure가 들고 있던 `self`에 대한 강한 참조가 해제되면서, `self`의 RC 가 1 감소.
  - API에 대한 응답이 정상적으로 돌아오지 않는다면, closure와 `self` 사이의 강한 순환 참조가 해결되지 않아 Memory Leaks가 발생.

    > 강한 순환 참조를 방지하기 위해, closure에서 [weak self]를 선언해 `self`의 RC 가 올라가지 않도록 구현
    
  ```swift
  @objc private func loadButtonPressed() -> Void {
      //  생략...
      DispatchQueue.global(qos: .userInteractive).async {
          APICaller.shared.fetchApod { [weak self] result in
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
            //  생략...
          }
      }
  }
  ```

<br>

## 💣 문제점
- **Cocoa MVC의 문제점**
  ![RealCocoaMVC](https://github.com/user-attachments/assets/6e025a87-34e4-4d9c-be09-8847d11ec080)
  - Controller가 View의 Life Cycle과 밀접하게 연관되어 있음. (e.g. viewDidLoad())
  - Model에게 맞지 않는 모든 비즈니스 로직 (e.g. Event 처리, Auto Layout 설정 등)이 ViewController에게 집중되어 있어, ViewController가 **Massive한 특성을 갖게됨.**
  - View와 Controller는 의존관계로 강하게 결합됨.
 
<br>

## 💡 개선할 점
- **Cocoa MVC의 문제점을 MVP -> MVVM의 순서로 리팩토링**
- **GCD to Swift Concurrency**
- **이미지를 다시 로드할 때, 메모리 캐시로부터 데이터를 요청 -> (실패) -> 디스크 캐시로부터 메모리 요청 -> (실패) -> API를 통해 데이터 요청이 되도록 리팩토링**
