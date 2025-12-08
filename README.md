# 🐻 Bear's Kitchen (곰이의 주방)

> **단국대학교 학식 정보 통합 및 AI 기반 스마트 메뉴 추천 플랫폼** > *2025-2 오픈소스SW기초 1분반 8조 프로젝트*

<br>

## 📖 프로젝트 소개 (About)
**Bear's Kitchen**은 교내에 파편화된 학식 정보를 한곳에 모아 제공하고, **생성형 AI(Google Gemini)**를 활용하여 학생들의 메뉴 선택 고민을 해결해 주는 모바일 애플리케이션입니다.

기존의 번거로운 정보 확인 절차를 간소화하고, **AI 리뷰 요약**과 **개인화 메뉴 추천** 기능을 통해 더 스마트하고 만족스러운 식사 경험을 제공합니다.

<br>

## ✨ 주요 기능 (Key Features)

### 1. 📋 실시간 학식 메뉴 조회
* 교내 모든 식당의 메뉴, 가격, 운영 정보를 한눈에 확인할 수 있습니다.
* 식당별, 코너별 직관적인 UI를 제공합니다.

### 2. ✍️ 신뢰할 수 있는 리뷰 시스템
* 실제 이용자들의 별점과 텍스트 리뷰를 통해 메뉴 실패 확률을 줄입니다.
* 데이터가 축적될수록 더욱 신뢰도 높은 맛 지표를 제공합니다.

### 3. 🤖 AI 리뷰 요약 (Gemini Powered)
* 수많은 리뷰를 일일이 읽을 필요 없이, **LLM(Gemini)**이 핵심 내용만 요약해 줍니다.
* "양이 많아요", "매콤해요" 등 주요 키워드와 한 줄 평을 제공합니다.

### 4. 🍽️ AI 맞춤 메뉴 추천
* 사용자의 취향과 검색 패턴을 분석하여 현재 판매 중인 메뉴 중 최적의 메뉴를 추천합니다.
* 결정 장애를 해소하고 식사 만족도를 높입니다.

### 5. 🔍 상세 필터링 및 정렬
* **필터**: 가격대 설정, 특정 식당 선택, 최소 별점 제한
* **정렬**: 가격순, 별점순, 리뷰 많은 순 등 다양한 기준 제공

<br>

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 (Technology) | 설명 |
| :---: | :--- | :--- |
| **Frontend** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white) | Cross-platform App Dev (Provider/Riverpod 상태관리) |
| **Backend** | ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black) | Authentication, Cloud Firestore (NoSQL) |
| **AI / LLM** | ![Google Gemini](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=flat&logo=google&logoColor=white) | Firebase Vertex AI (Gemini API) |
| **Collaboration** | ![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white) ![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white) | Version Control |

<br>

## ⚡ 시작 가이드 (Getting Started)

이 프로젝트를 로컬 환경에서 실행하려면 Flutter SDK가 설치되어 있어야 합니다.

### 설치 및 실행
1. 레포지토리를 클론합니다.
   ```bash
   git clone [https://github.com/your-username/bears-kitchen.git](https://github.com/your-username/bears-kitchen.git)
2. 프로젝트 폴더로 이동하여 의존성 패키지를 설치합니다.
    ```cd bears-kitchen
    flutter pub get
3. firebase_options.dart 등 환경 설정을 확인합니다. (본인의 Firebase 프로젝트 연동 필요
4. 앱을 실행합니다.
