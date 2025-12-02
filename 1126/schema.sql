-- AI Mood Player: Postgres schema (Supabase 호환)

-- 사용자 정보
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), -- Supabase: pgcrypto or extension
  name text,
  email text UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 재생 기록 (playedTracks)
CREATE TABLE IF NOT EXISTS played_tracks (
  id bigserial PRIMARY KEY,
  mood text NOT NULL,
  playlist_id text,
  time timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_played_tracks_mood ON played_tracks (mood);
CREATE INDEX IF NOT EXISTS idx_played_tracks_time ON played_tracks (time DESC);

-- 좋아요 트랙 / 플레이리스트 (likedTracks)
CREATE TABLE IF NOT EXISTS liked_tracks (
  id bigserial PRIMARY KEY,
  mood text,
  playlist_id text,
  title text,
  time timestamptz NOT NULL DEFAULT now(),
  UNIQUE (playlist_id) -- 같은 플레이리스트 중복 좋아요 방지 (필요시 제거)
);
CREATE INDEX IF NOT EXISTS idx_liked_tracks_time ON liked_tracks (time DESC);
CREATE INDEX IF NOT EXISTS idx_liked_tracks_mood ON liked_tracks (mood);

-- 감정 기록 타임라인 (emotionHistory)
CREATE TABLE IF NOT EXISTS emotion_history (
  id bigserial PRIMARY KEY,
  emotion text,        -- raw emotion 키 (e.g. happiness, sadness)
  mood text,           -- 매핑된 무드 (happy, sad...)
  confidence numeric,  -- 0..1 값
  time timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_emotion_history_time ON emotion_history (time DESC);
CREATE INDEX IF NOT EXISTS idx_emotion_history_mood ON emotion_history (mood);

-- 알림 (notifications)
CREATE TABLE IF NOT EXISTS notifications (
  id bigserial PRIMARY KEY,
  type text,           -- like, analysis, info 등
  message text,
  time timestamptz NOT NULL DEFAULT now(),
  unread boolean NOT NULL DEFAULT true
);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications (unread);

-- 사용자별 선호(prefs) - 플레이리스트별 like/skip 집계
CREATE TABLE IF NOT EXISTS prefs (
  playlist_id text PRIMARY KEY,
  likes integer NOT NULL DEFAULT 0,
  skips integer NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 간단한 트리거: prefs.updated_at 자동 갱신 (옵션)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prefs_updated_at ON prefs;
CREATE TRIGGER trg_prefs_updated_at
BEFORE UPDATE ON prefs
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- 샘플 데이터 (선택)
-- INSERT INTO users (name, email) VALUES ('테스트 사용자', 'user@example.com');
-- INSERT INTO played_tracks (mood, playlist_id) VALUES ('happy','37i9dQZF1DXdPec7aLTmlC');
-- INSERT INTO liked_tracks (mood, playlist_id, title) VALUES ('happy','37i9dQZF1DXdPec7aLTmlC','Happy Playlist');
-- INSERT INTO emotion_history (emotion, mood, confidence) VALUES ('happiness','happy',0.92);
-- INSERT INTO notifications (type, message) VALUES ('info','테스트 알림입니다.');

-- 권장: Supabase 사용 시, 익명(anon) 키의 RLS 정책(또는 테이블 권한)을 적절히 설정하세요.
