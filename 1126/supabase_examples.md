# Supabase 사용 예제 (REST / GraphQL)

## 전제
- supabase 프로젝트 URL: https://<PROJECT>.supabase.co
- anon key: <ANON_KEY>
- 클라이언트 인증(로그인) 후 발급되는 JWT: <ACCESS_TOKEN>
- RLS는 위 정책( user_id = auth.uid() )이 적용되어 있어야 함

---

## REST API: 기본 헤더 (모든 요청에 사용)
헤더:
- apikey: <ANON_KEY>
- Authorization: Bearer <ACCESS_TOKEN>
- Accept: application/json
- Content-Type: application/json (POST/PUT)

예: curl 공통 옵션
curl -H "apikey: <ANON_KEY>" -H "Authorization: Bearer <ACCESS_TOKEN>" "https://<PROJECT>.supabase.co/rest/v1/..."

---

## 1) 내 재생 기록 조회 (played_tracks)
GET
```
curl -s -X GET "https://<PROJECT>.supabase.co/rest/v1/played_tracks?select=*&order=time.desc" \
  -H "apikey: <ANON_KEY>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```
(정책이 user_id = auth.uid()이면, 해당 JWT 사용자 소유의 행만 반환됩니다.)

---

## 2) 좋아요 추가 (liked_tracks)
POST
```
curl -s -X POST "https://<PROJECT>.supabase.co/rest/v1/liked_tracks" \
  -H "apikey: <ANON_KEY>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "playlist_id": "37i9dQZF1DXdPec7aLTmlC",
    "mood": "happy",
    "title": "Happy Playlist",
    "user_id": "<옵션 - 클라이언트가 넣지 않아도 됨>"
  }'
```
- 권장: 클라이언트는 user_id를 직접 넣지 않고, 서버측 RPC(또는 DB DEFAULT/Trigger)로 user_id를 채우는 것이 안전합니다.
- 위 정책은 WITH CHECK (user_id = auth.uid()) 이므로 user_id가 JWT의 uid와 일치해야 삽입이 허용됩니다.

---

## 3) 알림 조회 (notifications, 미확인만)
GET
```
curl -s -X GET "https://<PROJECT>.supabase.co/rest/v1/notifications?select=*&unread=eq.true" \
  -H "apikey: <ANON_KEY>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## GraphQL 예제
GraphQL 엔드포인트: `https://<PROJECT>.supabase.co/graphql/v1`

### 1) 내 좋아요 목록 쿼리
Request (POST JSON)
```
POST https://<PROJECT>.supabase.co/graphql/v1
Headers:
  apikey: <ANON_KEY>
  Authorization: Bearer <ACCESS_TOKEN>
Body:
{
  "query": "query MyLikes { liked_tracks(order_by: {time: desc}) { id mood playlist_id title time } }"
}
```
- RLS로 인해 현재 JWT 사용자 소유의 liked_tracks만 반환됩니다.

### 2) 좋아요 추가 (Mutation) - GraphQL
```
{
  "query": "mutation InsertLike($playlist_id: String!, $mood: String!, $title: String!) { insert_liked_tracks_one(object: {playlist_id: $playlist_id, mood: $mood, title: $title}) { id playlist_id } }",
  "variables": {
    "playlist_id": "37i9dQZF1DXdPec7aLTmlC",
    "mood": "happy",
    "title": "Happy Playlist"
  }
}
```
- GraphQL mutation도 REST와 동일하게 RLS에 의해 소유자만 삽입이 허용됩니다(혹은 서버 측에 user_id를 채우는 트리거 필요).

---

## 권장 워크플로우
1. 클라이언트는 Supabase Auth로 로그인/회원가입 -> JWT 수신.  
2. 모든 데이터 요청은 JWT를 Authorization 헤더에 포함.  
3. DB는 RLS(auth.uid())로 소유권 보장. 클라이언트는 가능한 한 user_id를 직접 설정하지 않고, 서버 RPC 또는 DB 트리거로 user_id를 채우는 방식 권장.

---

궁금한 점
- `prefs`를 사용자별 테이블로 쓸지, 전역 집계로 쓸지 결정해주시면 `prefs`용 정책(복수 PK 포함)도 구체적으로 제공하겠습니다.
- 사용자 생성 자동화(가입 시 users 테이블에 레코드 생성) 트리거를 활성화할지 알려주시면 관련 스크립트를 활성화 버전으로 적용해 드립니다.
