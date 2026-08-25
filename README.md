# PortWatch

개발하다 보면 AI가 서버를 껐다 켰다 하면서 백그라운드에 좀비 서버가 남아 메모리·배터리를 몰래 잡아먹는 경우가 있습니다.
PortWatch는 현재 열려 있는 TCP/UDP 포트와 점유 프로세스를 한눈에 보여주고, 필요 없는 프로세스를 바로 종료할 수 있는 macOS 앱입니다.

## 기능

- TCP(LISTEN) / UDP 포트를 점유 중인 프로세스 목록 (포트, 주소, PID, 프로세스명)
- 3초마다 자동 새로고침 + 수동 새로고침
- 기본적으로 크롬 같은 브라우저/시스템 데몬은 제외하고 개발 서버로 보이는 프로세스만 표시 ("모두 보기" 토글로 전체 확인 가능)
- 항목별 종료(kill) 버튼

## 설치

1. [Releases](../../releases)에서 `PortWatch.dmg` 다운로드
2. dmg를 열고 `PortWatch.app`을 Applications 폴더로 드래그
3. 첫 실행 시 서명되지 않은 앱 경고가 뜨면: 우클릭 → 열기, 또는 시스템 설정 > 개인정보 보호 및 보안에서 허용

## 빌드

Xcode Command Line Tools (Swift 5.9+)만 있으면 됩니다. 별도 의존성 없음.

```bash
git clone https://github.com/tpgusgh/server_port.git
cd server_port
./scripts/build_dmg.sh
```

`dist/PortWatch.dmg`가 생성됩니다. `swift run`으로 앱만 바로 실행해볼 수도 있습니다.

## 동작 원리

내부적으로 `lsof`를 실행해 열려 있는 소켓 목록을 파싱합니다. 종료 버튼은 해당 PID에 `SIGTERM`을 보냅니다.
