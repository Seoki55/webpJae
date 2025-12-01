// AI Mood Player - Frontend Only
// - Emotion Detection via Face++ (optional)
// - Spotify via Embed (default) + optional OAuth for device playback

(function () {
  const $ = (sel) => document.querySelector(sel);

  // Elements
  const spotifyLoginBtn = $('#spotify-login');
  const spotifyLogoutBtn = $('#spotify-logout');

  const logoutBtn = document.getElementById('logout-btn');
  const profileBtn = document.getElementById('profile-btn');
  const notificationsBtn = document.getElementById('notifications-btn');
  const notifBadge = document.getElementById('notif-badge');
  const notifDropdown = document.getElementById('notifications-dropdown');
  const notifList = document.getElementById('notif-list');
  const clearNotifsBtn = document.getElementById('clear-notifs');

  const imageInput = $('#image-input');
  const preview = $('#preview');
  const previewImg = $('#preview-img');
  const analyzeBtn = $('#analyze-btn');
  const demoBtn = $('#demo-btn');
  const statusEl = $('#status');

  const resultBox = $('#result-box');
  const emotionText = $('#emotion-text');
  const moodText = $('#mood-text');
  const confidenceText = $('#confidence-text');

  const embed = $('#embed');
  const playOnSpotify = $('#play-on-spotify');
  const likeBtn = document.getElementById('like-btn'); // 변경: 좋아요 버튼 선택자
  const skipBtn = $('#skip');
  const resetLearningBtn = $('#reset-learning');

  // ...existing code...

  // State
  let accessToken = null;
  let currentPlaylistId = null;
  let currentMood = null;
  // ...existing code...
  let likedTracks = []; // 좋아요 목록

  // ...existing code...

  function addPlayedTrack(mood, playlistId) {
    const track = {
      id: Date.now(),
      mood,
      playlistId,
      time: new Date().toISOString()
    };
    playedTracks.unshift(track);
    if (playedTracks.length > 50) playedTracks = playedTracks.slice(0, 50);
    localStorage.setItem('playedTracks', JSON.stringify(playedTracks));
  }

  // 좋아요 항목 추가
  function addLikedTrack(item) {
    likedTracks.unshift(item);
    if (likedTracks.length > 100) likedTracks = likedTracks.slice(0, 100);
    localStorage.setItem('likedTracks', JSON.stringify(likedTracks));
  }

  function renderProfileLiked() {
    if (!profileLikedList) return;
    if (likedTracks.length === 0) {
      profileLikedList.innerHTML = '<p class="muted">좋아요 누른 곡이 없습니다.</p>';
      return;
    }

    profileLikedList.innerHTML = likedTracks.map(t => {
      const time = formatTimeAgo(new Date(t.time));
      return `
        <div class="profile-item">
          <div class="profile-item-icon">❤️</div>
          <div class="profile-item-details">
            <div class="profile-item-title">${t.title || ('플레이리스트: ' + (t.playlistId || '-'))}</div>
            <div class="profile-item-time">${time}</div>
          </div>
        </div>
      `;
    }).join('');
  }

  function setEmbedByMood(mood) {
    const key = (mood || 'neutral').toLowerCase();
    const playlistId = choosePlaylistForMood(key);
    currentPlaylistId = playlistId;
    embed.innerHTML = '';
    const iframe = document.createElement('iframe');
    iframe.style.borderRadius = '12px';
    iframe.src = `https://open.spotify.com/embed/playlist/${playlistId}?utm_source=generator`;
    iframe.width = '100%';
    iframe.height = '380';
    iframe.frameBorder = '0';
    iframe.allow = 'autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture';
    iframe.loading = 'lazy';
    embed.appendChild(iframe);
  }

  // 좋아요 버튼 핸들러 추가
  if (likeBtn) {
    likeBtn.addEventListener('click', () => {
      if (!currentPlaylistId) {
        setStatus('먼저 플레이리스트를 선택하거나 감정을 분석하세요.');
        return;
      }
      const item = {
        id: Date.now(),
        playlistId: currentPlaylistId,
        mood: currentMood || 'unknown',
        time: new Date().toISOString(),
        title: (currentMood ? `무드: ${currentMood}` : '플레이리스트')
      };
      addLikedTrack(item);
      renderProfileLiked();
      addNotification('like', `좋아요: ${item.title}`);
      setStatus('좋아요가 저장되었습니다.');
    });
  }

  // 기존 이벤트 바인딩 유지
  imageInput.addEventListener('change', () => {
    const file = imageInput.files && imageInput.files[0];
    if (file) showPreview(file);
  });
  analyzeBtn.addEventListener('click', onAnalyze);
  demoBtn.addEventListener('click', () => {
    const result = promptDemoMood();
    if (!result) return;
    setResult(result);
    setEmbedByMood(result.mood);
    setStatus('데모 무드 적용됨');
  });
  playOnSpotify && playOnSpotify.addEventListener('click', onPlayOnSpotify);
  skipBtn && skipBtn.addEventListener('click', () => { if (currentMood) { record('skip', currentPlaylistId); setEmbedByMood(currentMood); setStatus('다른 추천을 표시했습니다.'); } });
  resetLearningBtn && resetLearningBtn.addEventListener('click', () => { localStorage.removeItem('prefs'); setStatus('학습 데이터가 초기화되었습니다.'); });
// Init: load likedTracks from storage
  (function initStorageLikes() {
    try {
      const savedLiked = localStorage.getItem('likedTracks');
      if (savedLiked) likedTracks = JSON.parse(savedLiked);
    } catch (e) { likedTracks = []; }
  })();

})();