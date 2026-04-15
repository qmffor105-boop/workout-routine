# PROGRESS

Ralph 루프가 iteration 마다 최상단에 블록을 덧붙인다.

## 2026-04-15 iter-1
- 검증: `currentGoal` 과 `currentWeek` 는 이미 `localStorage` 로 저장/복원되고 있음 (index.html L572-573, `switchGoal`·`switchWeek` 내부).
- BACKLOG v1.1 첫 두 항목 체크.
- 다음: 체크 상태는 현재 `goal × week × day` 까지만 키잉 되고 카드 **인덱스** 기반이라 셔플 시 어긋남. iter-2 에서 운동명 기반 stable key 로 마이그레이션.

<!-- 예시 포맷:
## 2026-04-15 iter-1
- localStorage 에 goal 저장/복원 구현
- PRD v1.1 첫 항목 해소
- 다음: week 저장 구현 시 key 네이밍 규칙 정립 필요
-->
