-- Supabase RLS 템플릿: user_id 기반 소유권 정책 및 간단한 auth.users -> public.users 트리거
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS id uuid PRIMARY KEY DEFAULT gen_random_uuid();
ALTER TABLE IF EXISTS users ALTER COLUMN created_at SET DEFAULT now();

-- Add user_id columns if missing
ALTER TABLE IF EXISTS played_tracks  ADD COLUMN IF NOT EXISTS user_id uuid;
CREATE INDEX IF NOT EXISTS idx_played_tracks_user_id ON played_tracks(user_id);

ALTER TABLE IF EXISTS liked_tracks    ADD COLUMN IF NOT EXISTS user_id uuid;
CREATE INDEX IF NOT EXISTS idx_liked_tracks_user_id ON liked_tracks(user_id);

ALTER TABLE IF EXISTS emotion_history ADD COLUMN IF NOT EXISTS user_id uuid;
CREATE INDEX IF NOT EXISTS idx_emotion_history_user_id ON emotion_history(user_id);

ALTER TABLE IF EXISTS notifications   ADD COLUMN IF NOT EXISTS user_id uuid;
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);

ALTER TABLE IF EXISTS prefs ADD COLUMN IF NOT EXISTS user_id uuid;
CREATE INDEX IF NOT EXISTS idx_prefs_user_id ON prefs(user_id);

-- Enable RLS and create owner-only policies
ALTER TABLE IF EXISTS users ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS users_owner_select ON users FOR SELECT USING ( id = auth.uid() );
CREATE POLICY IF NOT EXISTS users_owner_insert ON users FOR INSERT WITH CHECK ( id = auth.uid() );
CREATE POLICY IF NOT EXISTS users_owner_update ON users FOR UPDATE USING ( id = auth.uid() ) WITH CHECK ( id = auth.uid() );
CREATE POLICY IF NOT EXISTS users_owner_delete ON users FOR DELETE USING ( id = auth.uid() );

-- played_tracks
ALTER TABLE IF EXISTS played_tracks ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS played_tracks_select_own ON played_tracks FOR SELECT USING ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS played_tracks_insert_own ON played_tracks FOR INSERT WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS played_tracks_update_own ON played_tracks FOR UPDATE USING ( user_id = auth.uid() ) WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS played_tracks_delete_own ON played_tracks FOR DELETE USING ( user_id = auth.uid() );

-- liked_tracks
ALTER TABLE IF EXISTS liked_tracks ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS liked_tracks_select_own ON liked_tracks FOR SELECT USING ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS liked_tracks_insert_own ON liked_tracks FOR INSERT WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS liked_tracks_update_own ON liked_tracks FOR UPDATE USING ( user_id = auth.uid() ) WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS liked_tracks_delete_own ON liked_tracks FOR DELETE USING ( user_id = auth.uid() );

-- emotion_history
ALTER TABLE IF EXISTS emotion_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS emotion_history_select_own ON emotion_history FOR SELECT USING ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS emotion_history_insert_own ON emotion_history FOR INSERT WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS emotion_history_update_own ON emotion_history FOR UPDATE USING ( user_id = auth.uid() ) WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS emotion_history_delete_own ON emotion_history FOR DELETE USING ( user_id = auth.uid() );

-- notifications
ALTER TABLE IF EXISTS notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS notifications_select_own ON notifications FOR SELECT USING ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS notifications_insert_own ON notifications FOR INSERT WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS notifications_update_own ON notifications FOR UPDATE USING ( user_id = auth.uid() ) WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS notifications_delete_own ON notifications FOR DELETE USING ( user_id = auth.uid() );

-- prefs (optional per-user)
ALTER TABLE IF EXISTS prefs ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS prefs_select_own ON prefs FOR SELECT USING ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS prefs_insert_own ON prefs FOR INSERT WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS prefs_update_own ON prefs FOR UPDATE USING ( user_id = auth.uid() ) WITH CHECK ( user_id = auth.uid() );
CREATE POLICY IF NOT EXISTS prefs_delete_own ON prefs FOR DELETE USING ( user_id = auth.uid() );

-- Notes:
-- - service_role 키는 RLS 우회 가능하니 절대 클라이언트에 노출 금지.
-- - 기존 데이터가 있으면 user_id 매핑이 필요합니다.
