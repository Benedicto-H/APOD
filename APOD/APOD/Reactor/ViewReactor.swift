//
//  ViewReactor.swift
//  APOD
//
//  Created by 홍진표 on 10/15/24.
//

import Foundation

import ReactorKit
import RxSwift

// MARK: - Reactor
/// Reactor는 `Business Logic`을 담당
/// `View`에서 전달받은 `Action`에 따라 로직 수행
/// 로직 수행 결과에 따라서 상태를 관리하고 상태가 변경되면 `View`에 전달
///
/// 대부분의 `View`는 대응되는 `Reactor`를 가짐 (즉, 1:1 대응)
/// Reactor는 상태 관리를 위한 ViewModel
final class ViewReactor: Reactor {
    
    let initialState: State
    
    init() {
        self.initialState = .init()
    }
    
    // MARK: - Action: 추상화된 사용자 입력
    enum Action {
        case fetchApod
    }
    
    // MARK: - Mutation: State를 변경하는 가장 작은 단위
    enum Mutation {
        case setApod(Apod?)
    }
    
    // MARK: - State: 추상화된 View 상태
    struct State {
        var apod: Apod?
    }
    
    /// mutate()는 Action을 수신하고, Observable<Mutation>을 생성함
    /// 비동기 작업 및 API 호출과 같은 Side-Effect는 mutate()에서 처리함
    ///
    /// (즉, Action 스트림을 Mutation 스트림으로 변환하고, 변환된 Mutation 스트림은 reduce() 함수로 전달)
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .fetchApod:
            /// `Side-Effect`
            return APICaller.shared.fetchApodRx()
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .utility))
                .flatMap { apod -> Observable<Mutation> in
                    return Observable.just(Mutation.setApod(apod))
                }
            
            /// `subscribe(on:)`: Data Sequence를 `어떤 Scheduler에서 방출할 것인지`를 결정
            /// (-> 즉, Observable이 작동할 Scheduler (= Thread)를 지정함)
            /// 기본적으로 Observable은 `subscribe()`를 호출한 Thread에서 생성됨
            /// ref. https://reactivex.io/documentation/operators/subscribeon.html
            ///
            /// `flatMap(_:)`을 통해 Observable<Apod> 데이터 스트림이 emit하는 값을 기반으로 새로운 Observable을 생성하여 Observable<Mutation> 스트림으로 변환
            /// (-> 즉, Observable을 변환하여 새로운 Observable을 반환할 때 사용)
        }
    }
    
    ///  이전 State와 Mutation을 활용하여 새로운 State를 반환
    ///  State를 View에서 구독을 하고 있었다면, State가 변경됨에 따라서, UI가 업데이트 됨
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState: State = state
        
        switch mutation {   
        case .setApod(let apod):
            newState.apod = apod
        }
        
        return newState
    }
    
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
    ///     [특징]: 사용자 정의 큐 사용 가능, 다양한 작업 환경에 맞게 설정 가능
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
    ///
    /// * 일반적으로 `subscribe(on:)은 Background Thread`에서, `observe(on:)은 Main Thread`에서 사용
}
