<div align="center">

<!-- TODO: docs/logo.png 추가 후 아래 주석 해제 -->
<!-- <img src="docs/logo.png" width="120" alt="Codive logo" /> -->

# Codive

**나만의 옷장과 코디를 기록하고, 사람들과 공유하는 iOS 앱**

[![iOS](https://img.shields.io/badge/iOS-16.0+-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-1F88E5?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Tuist](https://img.shields.io/badge/Tuist-4.65-7B61FF)](https://tuist.io)

<a href="https://apps.apple.com/kr/app/codive/id6756431150">
  <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="48" alt="Download on the App Store" />
</a>

</div>

---

## 📱 About Codive

Codive는 **매일의 코디를 기록하고, 옷장을 정리하고, 다른 사람들의 스타일을 둘러볼 수 있는** 패션 라이프로그 앱입니다.
가지고 있는 옷을 디지털 옷장에 등록하고, 룩북으로 코디를 조합하고, 날씨에 맞는 옷을 추천받고, 피드에서 다른 유저와 코디를 공유해보세요.

<br/>

## ✨ Features

- 👕 **옷장 (Closet)** — 가진 옷을 카테고리·태그별로 등록하고 관리
- 📒 **룩북 (LookBook)** — 옷장 아이템으로 나만의 코디 조합 저장
- 📸 **기록 (Feed)** — 매일의 착장을 사진과 메모로 기록
- 🌦 **날씨 기반 코디 추천** — 현재 위치의 날씨에 어울리는 옷 추천
- ❤️ **피드 · 좋아요 · 댓글** — 다른 유저의 코디를 둘러보고 소통
- 👤 **프로필 · 팔로우** — 마음에 드는 유저를 팔로우하고 캘린더로 기록 열람
- 🔔 **알림 · 검색 · 신고** — 활동 알림, 유저/태그 검색, 안전한 커뮤니티
- 🔐 **소셜 로그인** — 카카오 · Apple 로그인

<br/>

## 🛠 Tech Stack

| Category | Stack |
| --- | --- |
| **Language** | Swift 6.0 |
| **UI** | SwiftUI · Combine |
| **Architecture** | MVVM + Clean Architecture |
| **Concurrency** | Swift Concurrency (`async`/`await`) |
| **Build** | [Tuist](https://tuist.io) 4.65 |
| **Networking** | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) · Moya |
| **Image** | [Kingfisher](https://github.com/onevcat/Kingfisher) |
| **Auth** | KakaoSDK · Sign in with Apple |
| **Analytics / Crash** | Firebase Analytics · Crashlytics |
| **CI / Deploy** | Fastlane · `match` |

<br/>

## 🏗 Architecture

Codive는 **MVVM + Clean Architecture**를 기반으로, Feature 단위로 모듈을 분리하고 각 모듈 내부를 **Domain / Data / Presentation** 3계층으로 구성합니다.
의존성은 항상 안쪽(Domain)을 향하며, **DIContainer**로 객체 생성을 중앙에서 관리하고, 화면 전환은 **Router 패턴**으로 View에서 분리되어 있습니다.

```
Presentation (SwiftUI View · ViewModel)
        │  uses
        ▼
   Domain (Entity · UseCase · Repository Interface)
        ▲  implements
        │
     Data (Repository · DataSource · DTO)
```

> 📖 자세한 레이어 규칙·DI·Router 동작은 [`ARCHITECTURE.md`](./ARCHITECTURE.md)에서 확인할 수 있습니다.

<br/>

## 📂 Project Structure

```
Codive/
├── Application/      # 앱 진입점, 전역 설정
├── Core/             # 공용 유틸 / 리소스
├── Features/         # 기능별 모듈 (Domain · Data · Presentation 3계층)
│   ├── Auth/
│   ├── Home/
│   ├── Feed/
│   ├── Closet/
│   ├── LookBook/
│   ├── Profile/
│   ├── Search/
│   ├── Notification/
│   ├── Report/
│   └── ...
├── Shared/           # DesignSystem · Extensions · Network · Storage 등
├── DIContainer/      # 의존성 주입 컨테이너
├── Router/           # 내비게이션 / 화면 전환
└── Resources/        # Assets · Fonts · Colors · xcconfig
```

<br/>

## 👥 Team

| iOS | iOS | iOS |
| :---: | :---: | :---: |
| <a href="https://github.com/Hrepay"><img src="https://avatars.githubusercontent.com/u/137605270?v=4" width="100" /></a> | <a href="https://github.com/Funital"><img src="https://avatars.githubusercontent.com/u/152842614?v=4" width="100" /></a> | <a href="https://github.com/taebin2"><img src="https://avatars.githubusercontent.com/u/109895271?v=4" width="100" /></a> |
| **황상환**<br/>[@Hrepay](https://github.com/Hrepay) | **한금준**<br/>[@Funital](https://github.com/Funital) | **taebin2**<br/>[@taebin2](https://github.com/taebin2) |

---

<div align="center">

Made with ❤️ by **Clokey-dev**

<a href="https://apps.apple.com/kr/app/codive/id6756431150">
  <img src="https://img.shields.io/badge/Download-App_Store-0D96F6?logo=appstore&logoColor=white&style=for-the-badge" alt="Download on the App Store" />
</a>

</div>
