# Architecture Documentation

이 문서는 **Codive-iOS** 프로젝트의 아키텍처 및 디자인 패턴에 대한 개요를 제공합니다.
이 프로젝트는 **SwiftUI**를 기반으로 하며, **MVVM (Model-View-ViewModel)** 패턴과 **Clean Architecture** 원칙을 따르고 있습니다. 또한 **DI Container**를 통한 의존성 주입과 **Router** 패턴을 통한 화면 전환 처리를 적용하여 모듈 간의 결합도를 낮추고 유지보수성을 높였습니다.

---

## 🏗 Architectural Overview

전체적인 구조는 **Clean Architecture**의 계층화된 접근 방식을 따르며, 데이터의 흐름은 단방향으로 관리됩니다.

### Core Principles
1.  **관심사의 분리 (Separation of Concerns):** 각 레이어는 명확한 역할을 가지며 서로 독립적으로 동작합니다.
2.  **의존성 규칙 (Dependency Rule):** 의존성은 항상 **안쪽(Domain Layer)**을 향해야 합니다. Presentation이나 Data 레이어는 Domain 레이어를 알지만, Domain 레이어는 외부 레이어를 알지 못합니다.
3.  **테스트 용이성 (Testability):** 비즈니스 로직(Domain)은 UI나 프레임워크와 분리되어 있어 독립적으로 테스트가 가능합니다.

---

## 📂 Layer Structure (계층 구조)

각 Feature(기능)는 다음과 같은 3개의 주요 레이어로 구성됩니다.

### 1. Domain Layer (Inner Circle)
가장 안쪽에 위치하며, 비즈니스 로직을 담당합니다. 외부 라이브러리나 UI 프레임워크(SwiftUI, UIKit 등)에 의존하지 않는 순수 Swift 코드로 작성됩니다.
*   **Entities:** 앱의 핵심 데이터 모델.
*   **UseCases:** 비즈니스 로직을 실행하는 단위. Repository Interface를 사용하여 데이터를 요청합니다.
*   **Interfaces (Repository Protocols):** Data Layer에서 구현해야 할 Repository의 추상화된 정의.

### 2. Data Layer (Outer Circle)
실제 데이터 처리를 담당합니다. API 통신, 로컬 DB 접근 등을 수행하며 Domain Layer의 Repository Interface를 구현합니다.
*   **Repositories (Implementation):** Domain Layer의 Repository Interface를 실제로 구현한 클래스.
*   **DataSources:** Remote(API) 또는 Local(DB, UserDefaults) 데이터 소스.
*   **DTOs (Data Transfer Objects):** API 응답 모델 (Domain Entity로 매핑되어 사용됨).

### 3. Presentation Layer (Outer Circle)
사용자에게 데이터를 보여주고 입력을 받는 UI 계층입니다.
*   **Views (SwiftUI):** UI를 구성하고 사용자의 입력을 받습니다. 비즈니스 로직을 직접 처리하지 않고 ViewModel에 위임합니다.
*   **ViewModels:** View의 상태(State)를 관리하고, UseCase를 실행하여 데이터를 처리합니다. `@Published` 속성을 통해 View와 바인딩됩니다.

---

## 🧩 Modularization (Folder Structure)

프로젝트는 기능(Feature) 단위로 그룹화되어 있으며, 각 기능 내부는 Clean Architecture 레이어로 나뉩니다.

```
Codive/
├── Application/        # 앱 진입점 및 초기 설정 (AppConfigurator, AppRootView)
├── Features/           # 기능별 모듈
│   ├── Auth/
│   │   ├── Domain/     # Entity, UseCase, Repository Interface
│   │   ├── Data/       # Repository Impl, DTO, API Service
│   │   └── Presentation/ # View, ViewModel
│   ├── Feed/
│   ├── Home/
│   └── ...
├── Shared/             # 공통 사용 모듈 (DesignSystem, Extensions, Network, Storage)
├── DIContainer/        # 의존성 주입 컨테이너
└── Router/             # 화면 전환 및 내비게이션 로직
```

---

## 🔌 Dependency Injection (DI)

의존성 주입은 **DIContainer** 패턴을 사용하여 중앙에서 관리합니다.
*   **AppDIContainer:** 앱 전체의 최상위 컨테이너로, 각 Feature의 DIContainer를 생성하고 관리합니다.
*   **FeatureDIContainer (e.g., AuthDIContainer):** 각 기능 모듈에 필요한 UseCase, Repository, ViewModel 등의 인스턴스를 생성하고 주입합니다.
*   이를 통해 객체 간의 결합도를 낮추고 테스트 시 Mock 객체 주입을 용이하게 합니다.

---

## 🚦 Navigation (Router Pattern)

화면 전환 로직은 View에서 분리되어 **Router**와 **ViewFactory**가 담당합니다.
*   **Router:** 내비게이션 스택을 관리하고 화면 전환을 수행합니다 (`AppRouter`, `NavigationRouter`).
*   **ViewFactory:** 특정 화면(View)을 생성할 때 필요한 의존성(ViewModel 등)을 조립하여 View를 반환합니다.
*   View는 `Router`를 통해 "어디로 갈지"만 요청하며, 실제 "어떻게 화면을 띄울지"는 Router가 처리합니다.

---

## 🛠 Tech Stack & Tools

*   **Language:** Swift 6.0+
*   **UI Framework:** SwiftUI
*   **Architecture:** MVVM + Clean Architecture
*   **Build Tool:** Tuist
*   **Networking:** CodiveAPI (swift-openapi-generator)
*   **Reactive Programming:** Combine / Swift Concurrency (async/await)
