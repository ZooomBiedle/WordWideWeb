# Table of Contents
1. [Description](#description)
2. [Timeline](#timeline)
3. [Demo](#demo)
4. [Features](#features)
5. [Requirements](#requirements)
6. [Stacks](#stacks)
7. [ProjectStructure](#projectStructure)
8. [Developer](#developer)

# WWW : Word Wide Web

// logo 이미지 추가



## Description

단어로 연결된 세계.
따로 또 같이 공부하는 커뮤니티 사전검색 단어장! 
맞다이로 들어와.. 


(사전 검색 단어로 나만의 단어장을 만들거나, 
초대한 or 초대받은 친구들과 공유된 테스트 단어장으로 게임하듯 공부할 수 있습니다.)


## Timeline

<details>
   <summary>24.05.13</summary>
    <pre>● Project 아이디어 회의
    ○ 컨셉 논의, 역할 분담, 와이어프레임 구성

</details>

<details>
    <pre>● 소셜 로그인 페이지 구현
    ○ Sign in / Sign up 기능 및 페이지 구현

<details>
   <summary>24.05.15</summary>
    <pre>● 계정 정보 저장(backend) 기능 구현
● Firebase 구축
    </pre>
</details>

<details>
   <summary>24.05.16</summary>
   <pre>● 전체적인 Flow 및 핵심 기능 확정

   </pre>
</details>

<details>
   <summary>24.05.17</summary>
   <pre>● 친구 초대 페이지 생성
● 친구 초대 페이지 생성
   </pre>
</details>

<details>
   <summary>24.05.18</summary>
   <pre>● 단어장에 친구 초대 기능 구현
    ● 전체적인 디자인 및 컬러 변경
   </pre>
</details>    

<details>
   <summary>24.05.21</summary>
   <pre>● 단어 테스트 기능 구현 
      ● 네트워크 매니저 구현
      ● API 호출 결과 바인팅
   </pre>
</details>    

<details>
   <summary>24.05.22</summary>
   <pre>● 네트워크 매니저 구현
      ● API 호출 결과 바인딩
   </pre>
</details>    

<details>
   <summary>24.05.23</summary>
   <pre>● 초대 요청을 받은 친구 알람 기능 구현
   </pre>
</details>   

<details>
   <summary>24.05.24</summary>
   <pre>● 최종 점검 (UI 디테일 및 파일명, 디자인 패턴 점검 등)
● ReadMe 작성
   </pre>
</details> 

## Demo
// 모든 화면 이미지 캡처 추가 예정
<p float="left">
<img src="img src="/github.com/ZooomBiedle/WordWideWeb/assets/155615768/74f27121-738d-4e7e-9f7e-08ff9a34a236" width="200" height="430">




## Features
### 소셜 로그인
- sign in / sign up with Google & Apple


### Dictionary API
- 사전 검색 정보 네트워크 연결


### 홈 화면
- 내가 만들었거나 소속된 단어장 선택
- 선택한 단어장의 단어 리스트 및 단어의 사전적 정의 확인


### 내 정보 기능
- 프로필 세팅
- 로그아웃
- 단어장 생성 및 관리
- 닉네임 및 프로필 이미지 수정


### 단어장 생성
- 원하는 단어장 컬러 선택
- public 또는 private 옵션 설정 
- 단어장으로 친구 초대
- 단어 테스트 시간 : deadLine 세팅
  

### 사전에서 단어 검색
- 궁금한 단어를 search bar에 입력
- 단어의 정의와 발음 확인


### 단어장에 단어 추가
- 검색한 단어를 단어장에 추가


### 친구 초대
- Test List 
- Reject or Accept


### 단어 테스트
- 정해진 시간 동안 정해진 단어의 퀴즈를 테스트하는 기능


### 단어 테스트 결과
- 맞춘 단어와 틀린 단어의 결과 안내 기능


## Requirements
- App requires **iOS 17.4 or above**

## Stacks
- **Environment**

    <img src="https://img.shields.io/badge/-Xcode-147EFB?style=flat&logo=xcode&logoColor=white"/> <img src="https://img.shields.io/badge/-git-F05032?style=flat&logo=git&logoColor=white"/> <img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black"/> <img src="https://img.shields.io/badge/Adobe InDesign-FF3366?style=flat-square&logo=Adobe InDesign&logoColor=white"/>


- **Language**

    <img src="https://img.shields.io/badge/-swift-F05138?style=flat&logo=swift&logoColor=white"/> 

- **API**

    한국 기초 사전 API (국립 국어원 제작)

- **Communication**

    <img src="https://img.shields.io/badge/-Slack-4A154B?style=flat&logo=Slack&logoColor=white"/> <img src="https://img.shields.io/badge/-Notion-000000?style=flat&logo=Notion&logoColor=white"/> <img src="https://img.shields.io/badge/-Figma-F24E1E?style=flat&logo=Figma&logoColor=white"/> 

## Project Structure

```markdown
WWW
├── Model
│   ├── NetworkManager
│   ├── RemoteDictionary
│   ├── MyPage
│   └── InvitationData
│
├── View
│   ├── DictionaryTableViewCell
│   ├── TestFriendViewCell
│   ├── TestResultView
│   ├── TestView
│   ├── TestIntroView
│   ├── CarouselLayout
│   ├── DefaultTableViewCell
│   ├── ExpandableTableViewCell
│   └── InvitedFriendCell
│
│
├── Controller
│   ├── TabBarController
│   ├── MyPageVC
│   ├── MyPageCollectionViewCell
│   ├── MyPageWordViewController
│   ├── MyPageModalViewController
│   ├── PlayingListViewController
│   ├── DictionaryVC
│   ├── InvitingVC
│   ├── MyInfoViewController
│   ├── WordbookCell
│   ├── AddWordBookVC
│   ├── RadioButton
│   ├── ProfileVC
│   ├── ProfileViewModel
│   ├── TestIntroViewController
│   ├── TestResultViewController
│   ├── TestViewController
│   └── EmptyCollectionViewCell
│
│
├── Component
│   ├── AppDelegate
│   ├── SceneDelegate
│   └── ViewController
│
│
├── Extension
│   ├── UIFont+Ext
│   ├── UIColor+Ext
│   ├── NotificationExtensions
│   ├── Formatter
│   ├── Numeric
│   ├── MyPage+Ext
│   └── CollectionView+Ext
└ 
```

## Developer (가나다 순)
*  **박준영** ([labydin](https://github.com/labydin))
    - 사전 API 네트워크 연결, 단어장 내 단어 추가 및 파일 구조 관리 전반

*  **신지연** ([JiYeonDu](https://github.com/JiYeonDu))
    - 단어 테스트 및 예약 알람, 결과 기록 저장 등 단어 테스트 전반

*  **장진영** ([mgynsz](https://github.com/mgynsz))
    - Apple, Google 로그인 관리 및 친구 초대를 위한 backend 전반

*  **채나연** ([Nayeon Chae](https://github.com/NY-Chae))
    - 홈 화면 및 단어장 캐로셀, 단어 상세페이지 등 UI Design 전반 
