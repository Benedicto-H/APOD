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

**++ 📺 2024.10.01 새롭게 추가한 WKWebView**
|WKWebView|JSON|
|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/db4d1036-84e3-44f0-9e7b-6f329207bf0e">|<img src="https://github.com/user-attachments/assets/fd230da1-3aa2-4e27-a06b-9c4078899693" width="50%" height="50%">|

> APOD의 media_type이 video인 경우, url의 값으로 YouTube 동영상 링크를 제공하기에, WebKit framework의 WKWebView를 구성하고 미디어 타입에 따른 enum을 구현하여 video인 경우와 image인 경우 view를 다르게 구현함

```swift
//  생략..
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
//  생략..
```

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

## 💡 개선한 점
- **Cocoa MVC의 문제점을 MVP -> MVVM의 순서로 리팩토링 ✅**
  - MVP: [develop_mvp](https://github.com/Benedicto-H/APOD/tree/develop_mvp)
    
  - MVVM: [develop_mvvm](https://github.com/Benedicto-H/APOD/tree/develop_mvvm)
  > 상태관리를 위한 ReactorKit 도입 [develop_reactorkit](https://github.com/Benedicto-H/APOD/tree/develop_reactorkit)

  <br>
  
- **Testable한 URLSession 설계를 목표로, 기본 라이브러리 사용으로 Network Layer 추상화 모듈 구현 ✅**
  |네트워크 레이어 추상화 다이어그램|
  |:---:|
  |<img src="https://github.com/user-attachments/assets/7ae53ee8-2825-440e-9322-8d1de598c37b">|

  - 네트워크의 핵심 모듈
    - Endpoint: path, queryParameters, bodyParameters 등의 데이터 객체
    - Provider: URLSession, dataTask()를 이용하여 network 호출이 이루어지는 곳

  - Endpoint는 Requestable, Responsable 프로토콜을 준수하는 상태
    > Requestable에는 baseURL, path, method, parameters, 등과 같은 정보가 존재
    
  - Responsable은 Request하는 곳인, Provider에서 Response 타입을 알아야 Generics를 적용할 수 있는데, Endpoint 객체 하나만 넘기면 따로 request할 때, Response 타입을 넘기지 않아도 되게끔 설계

  ```swift
  protocol Responsable {
      associatedtype Response
  }

  //    Endpoint 객체를 만들때 Response타입을 명시
  class Endpoint<R>: RequestResponsable {
      typealias Response = R
      ...
  }

  //    Provider에서 Endpoint객체를 받으면 따로 Response 타입을 넘기지 않아도 되도록 설계
  protocol Provider {
      
      //    R은 Decodable 해야하고, Endpoint의 Response 타입과 일치해야하며 E는 Endpoint 조건을 만족해야한다.
      func request<R, E>(with endpoint: E, completion: @escaping (Result<R, Error>) -> Void) -> Void where R: Decodable, R == E.Response, E: RequestResponsable

      func request<R, E>(with endpoint: E) async throws -> R where R: Decodable, R == E.Response, E: RequestResponsable
      ...
  }
  ```
  
  - 사용하는 쪽
    ```swift
    struct APIEndpoints {
        static func getApod(with request: APIKeyProvider) -> Endpoint<ApodResponseDTO> {
            return Endpoint(baseURL: "https://api.nasa.gov/",
                        path: "planetary/apod",
                        method: .get,
                        queryParams: request,
                        sampleData: JSONLoader.getDataFromFileURL(fileName: "MockData")
            )
        }
        ...
    }
    ```
    
    > APIEndpoints를 정의하여 도메인에 종속된 baseURL, path등을 정의하고, 요청 / 응답에 주고받는 데이터를 DTO (Data Transfer Object, 데이터 전송 객체) 개념을 적용하여 Entity와 분리하여 관리

  - URLProtocol을 사용한 네트워크 요청을 가로채기 (실제 네트워크에 의존하지 않는 네트워크 Unit Tests를 위함)
    ```swift
    protocol URLSessionable {
        //    URLSession의 dataTask(with:completion:)를 그대로 정의
        func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask

        //    URLSession의 data(for:)를 정의
        func data(for request: URLRequest) async throws -> (Data, URLResponse)

        /**
        Sendable: Data Races의 리스크 없이, 임의의 동시 context에서 값을 안전하게 사용할 수 있게 해주는 `Thread-Safe`한 유형의 Protocol

        Functions 및 Closures에서는 `@Sendable`로 표시하며, 함수나 클로저가 캡처하는 모든 값은 sendable이어야 한다.
        또한, sendable 클로저는 `값 캡처 (by-value capture)`만을 사용해야 하며, 캡처된 값은 sendable 유형이어야 한다.

        ///    `Race Condition`: Multi-Threading 환경에서 공유 리소스에 동시에 접근하여 결과가 예측할 수 없게되는 상황
            - 작업의 `순서에 중점`을 두고, 작업을 처리하는 순서가 예기치 못한 결과를 초래할 수 있다는 점에 초점을 맞춤

        ///    `Data Races`: Multi-Threading 환경에서 동기화 작업 없이 공유 리소스에 동시에 접근하여 문제가 발생하는 상황
            - `동기화 작업이 없다`는 것은 리소스를 수정하는 과정에서 순서가 보장되지 않음을 뜻함
            - (즉, `순서가 보장되지 않으면 리소스는 안전하게 처리될 수 없음`)
     
            - Data Races의 해결법: `동기화`-> 동기화 작업에는 뮤텍스, 세마포어, 읽기-쓰기 잠금, etc.
            - ('동기화 메커니즘' or 작업 큐와 같은 '작업 처리 방안'을 사용)
     
        ///    `Thread-Safe`: 여러 스레드가 동시에 하나에 자원을 사용할 때, 그 자원이 안전하게 처리될 수 있도록 보장하는 상태
            - (즉, 동기화를 통해 Data Race의 문제를 해결한 것)
     
        ///    `Data Races` ⊂ `Race Condition` (-> Data Races는 Race Condition의 부분집합)
        */
    }

    extension URLSession: URLSessionable { }
    ```
    
    ```swift
    //    ProviderImpl
    final class APIProvider: Provider {
    
        static let shared: APIProvider = APIProvider()
        private let session: URLSessionable
    
        /// URLSession을 주입받음.
        /// 테스트 시 MockURLSession을 주입.
        init(session: URLSessionable = URLSession.shared) {
            self.session = session
        }
        ...
    }
    ```
    
    <br>
    
- **GCD to Swift Concurrency ✅**
  |completionHandler|async / await|
  |:---:|:---:|
  |<img src="https://github.com/user-attachments/assets/eb720804-c794-4a00-8371-335123c26891">|<img src="https://github.com/user-attachments/assets/6c42cf95-ccb0-4bc9-afd9-ecdf101e3fc1">|

  기존의 @escaping 키워드를 사용한 함수 타입의 Closure를 통한 비동기 처리의 단점은 코드가 장황하고(verbose), 복잡하고(complex), 부정확(incorrect) 해졌고, 오류처리가 어려웠음.
  > 클로저가 중첩될수록 (Deeply-nested closures) call-back 지옥에 빠지기도 쉬웠다. (이를 파멸의 피라미드 (Pyramid of Doom) 라고 한다.)
  
  이를, Swift 5.5부터 새롭게 도입된 Swift Concurrency의 async / await 키워드를 사용함으로써, 명시적인 스레드 관리 없이 비동기 처리를 구현하고, 코드의 가독성을 향상 (straight-line code로 처리할 수 있게됨)

  - async / await를 사용하는 쪽
    ```swift
    //    ViewController.swift
    Task(priority: .utility) {
        let endpoint = APIEndpoints.getApod(with: ApodRequestDTO())
            
        let apod = try await APIProvider.shared.request(with: endpoint).toDomain()
        print("========== Successfully fetched data ========== \n\(apod) \n")
        self.apod = apod
        
        guard let apod = self.apod, let mediaType = MediaType(from: self.apod?.url ?? "") else { return }
        updateUI(with: apod, mediaType: mediaType)
    }

    //    ImageCacheManager.swift
    func getImage(with url: String) async throws -> UIImage {
        
        guard let url = URL(string: url) else { throw ImageCacheManagerError.invalidURL }
        
        let cacheKey = url.lastPathComponent
        
        do {
            print("1. 메모리 캐시 검사")
            return try await checkMemoryCache(with: cacheKey)
        } catch {
            print("1. (실패)")
            do {
                print("2. 디스크 캐시 검사")
                return try await checkDiskCache(with: cacheKey)
            } catch {
                print("2. (실패)")
                print("3. 메모리/디스크 캐시에 각각 데이터 추가 후 반환")
                return try await Task(priority: .utility) {
                    return try await saveImage(with: url, key: cacheKey)
                }.value
            }
        }
    }
    ```

    > 메서드 시그니처 뒤에 async 키워드로 비동기 함수임을 나타내고, 호출할 때에는 await 키워드로 호출한다. <br>
    async 메서드는 동시 컨텍스트 (Concurrent Context) 내부 즉, 다른 async 함수 내부 또는 Task 내부에서 사용 가능하다.

    <br>
    
- **디스크 캐싱 추가 ✅**
  |Using Memory Cache / Disk Cache|ImageCache Directory|
  |:---:|:---:|
  |<img src="https://github.com/user-attachments/assets/afd98a05-134e-4114-aab3-e88c88d39b09">|<img src="https://github.com/user-attachments/assets/41a23dbe-c8c3-4a47-99cf-a2058061f5d2">|
  <img src="https://github.com/user-attachments/assets/0808264e-1818-4eaf-ab96-bcc1ca0d0d53">

  > NASA Open APIs의 APOD 데이터는 UTC-4 (Eastern Time) 00:00를 기준으로 업데이트 되기에, 캐시를 무효화하여 최신화 된 데이터 이외에는 모두 삭제되게 구현함으로써, 앱이 백그라운드 상태에서 foreground 상태로 변경될 때 디스크 캐시를 사용
  >
  > ref: [nasa/apod-api issue #26: Missing info: at what time "today's" image is created? ](https://github.com/nasa/apod-api/issues/26)
  <br>
  
  위와 같이 최신 데이터를 얻고자 캐시를 무효화 시키는 작업에는 몇가지 문제점이 발생하게 됨.
  
  - 메모리 캐시의 비효율적 처리
    ```swift
    imageCache.removeAllObjects()
    ```
    문제점: loadImage()가 호출될 때 마다, clearCache()로 인해 매번 메모리 캐시를 비우고, 최신화가 되지 않은 데이터를 디스크 캐시에서 삭제하기 때문에 재사용성이 감소와 CPU 및 메모리 사용량이 증가함.
    
  - 디스크 캐시 정리의 비효율성
    ```swift
    if (fileURL.lastPathComponent != key) {
        try? FileManager.default.removeItem(at: fileURL)
    }
    ```
    문제점: 디스크 캐시 내의 모든 파일을 삭제하는 불필요한 I/O 작업으로 성능을 저하시킴.
    
    <br>
    
    **++ 🪛 2024.10.02 캐싱 개선**
    |디스크 캐시 만료정책|메모리 캐시 만료정책|
    |:---:|:---:|
    |<img src="https://github.com/user-attachments/assets/fda4a867-f91f-4daa-a050-f2a972662abe">|<img src="https://github.com/user-attachments/assets/4053a05f-c44a-4d62-8064-49f3d40f4b7d">|
 
    - APOD 데이터가 업데이트 되는 서버 시간과 상관없이 디스크 캐시에 시간을 기준으로한 캐시 만료정책을 통해, 디스크 캐시에 저장된 이미지 파일의 속성 중 수정날짜를 추출하여 과거의 수정된 시간이 현재시간을 기준으로 24시간이 지났다면 디스크 캐시에서 삭제되도록 구현
      
    - NSCache의 totalCostLimit를 적용하여 10MB만을 메모리 캐시로 사용하도록 구현
      > NSCache의 countLimit와 totalCostLimit를 설정하지 않으면 기본값 0임과 동시에 limit가 없기 때문에, 메모리에 모든것을 계속 저장하게 된다.
      >
      > -> NSCache가 자동으로 메모리를 관리하는 기법에는 자체 클래스에 적용된 LFU와 LRU 기법을 통해 이루어진다.
      >   - LRU (Least Recently Used): 가장 최근에 사용되지 않은 데이터를 우선적으로 제거하는 알고리즘
      >   - LFU (Least Frequently Used): 가장 적게 사용된 데이터를 우선적으로 제거하는 알고리즘
