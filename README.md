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
  ![RealCocoaMVC](https://github.com/user-attachments/assets/580d7c69-59bd-45ec-9374-5e4298d4b725)
  
  - Controller가 View의 Life Cycle과 밀접하게 연관되어 있음.
    > e.g. viewDidLoad()
    
  - Model에게 맞지 않는 모든 비즈니스 로직이 ViewController에게 집중되어 있어, ViewController가 **Massive한 특성을 갖게됨.**
    > e.g. target-action의 event 처리, AutoLayout 등
    
  - View와 Controller는 의존관계로 강하게 결합됨.

<br>

- **Caching 처리의 문제점** : _Caching의 문제를 Disk Caching을 통해 해결!_
  |Using Cache|
  |:---:|
  |<img src="https://github.com/user-attachments/assets/1a9d8b5f-7031-44d5-9b0a-b50d8bf55416">|

  이미지 캐싱을 위해 사용한 NSCache는 **Memory Cache**로서, 앱이 사용중인 메모리의 일부분을 캐시 메모리로 사용하면서 앱이 백그라운드로 전환될 때, 시스템은 앱이 사용하는 메모리를 줄이기 위해 최적화를 수행한다.
  > NSCache에 저장된 이미지와 같은 객체도 포함!
 
<br>

## 💡 개선할 점
- **Cocoa MVC의 문제점을 MVP -> MVVM의 순서로 리팩토링**
  
- **GCD to Swift Concurrency**
  
- **디스크 캐싱 추가 ✅**
  |Using Memory Cache / Disk Cache|ImageCache Directory|
  |:---:|:---:|
  |<img src="https://github.com/user-attachments/assets/afd98a05-134e-4114-aab3-e88c88d39b09">|<img src="https://github.com/user-attachments/assets/41a23dbe-c8c3-4a47-99cf-a2058061f5d2">|

  > NASA Open APIs의 APOD 데이터는 UTC-4 (Eastern Time) 00:00를 기준으로 업데이트 되기에, 캐시를 무효화하여 최신화 된 데이터 이외에는 모두 삭제되게 구현함으로써, 앱이 백그라운드 상태에서 foreground 상태로 변경될 때 디스크 캐시를 사용
  >
  > ref: [nasa/apod-api issue #26: Missing info: at what time "today's" image is created? ](https://github.com/nasa/apod-api/issues/26)

  ```swift
  // MARK: - ImageCacheManager
  final class ImageCacheManager {
    //  생략...

    /// for `Disk Cache`
    static let diskCacheDirectory: URL = {
        /// 캐시 디렉토리 경로 설정
        guard let path: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("캐시 디렉토리를 찾을 수 없음.")
        }

        /// Caches의 ImageCache 서브폴더 생성
        let directory: URL = URL(fileURLWithPath: path).appendingPathComponent("ImageCache")

        /// 캐시 디렉토리가 없으면 생성
        if (!FileManager.default.fileExists(atPath: directory.path)) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("디스크 캐시 디렉토리 생성 실패: \(error.localizedDescription)")
            }
        }

        return directory
    }()
  }
  ```

  > FileManager를 통해 이미지를 file로 관리하면서 Caches 폴더의 서브폴더를 생성하여 이미지들을 관리
  
  - **Caching Flow**: _메모리 캐시로부터 데이터 확인 -> (실패) -> 디스크 캐시로부터 데이터 확인 -> (실패) -> API를 통해 얻은 데이터를 Memory Cache와 Disk Cache에 각각 추가_
