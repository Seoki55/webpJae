<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>나의 소개 페이지</title>
  <style>
    body {
      background-color: linen;
      color: #333;
      font-family: "맑은 고딕", sans-serif;
      margin: 40px;
    }
    h1 {
      text-align: center;
      color: darkred;
      margin-bottom: 6px;
      cursor: pointer; /* 마우스를 올릴 수 있다는 표시 */
    }
    hr {
      height: 5px;
      border: solid grey;
      background-color: grey;
      margin: 18px 0 28px;
    }
    .profile {
      text-align: center;
      margin: 20px 0;
    }
    .profile img {
      width: 200px;
      height: 200px;
      object-fit: cover;
      border-radius: 50%;
      box-shadow: 0 0 10px rgba(0,0,0,0.15);
      opacity: 0;                 /* 처음엔 숨김 */
      transition: opacity 200ms ease;
    }
    .visible { opacity: 1; }
    .section {
      margin: 16px 0;
    }
    .section h2 {
      color: darkblue;
      border-left: 6px solid darkblue;
      padding-left: 10px;
      margin: 12px 0;
      font-size: 20px;
    }
    ul { list-style: square; padding-left: 20px; }
  </style>

  <script>
    function show() { // <img>에 이미지 달기
      document.getElementById("fig").src = "me.png";
    }
    function hide() { // <img> 이미지 제거
      document.getElementById("fig").src = "";
    }
  </script>
</head>
<body>
  <!-- 제목에만 onmouseover / onmouseout -->
  <h1 onmouseover="show()" onmouseout="hide()">👋 나를 소개합니다</h1>
  <hr />

  <div>
    <img id="fig" src="">
  </div>

  <!-- 소개 글은 항상 보이게 -->
  <div class="section">
    <h2>소개</h2>
    <p>
      안녕하세요! 소프트웨어학과를 전공으로 하고 있는 이재석입니다.
      아직 제가 부족한 점이 많지만 한 번 열심히 해보겠습니다.
    </p>
  </div>

  <div class="section">
    <h2>취미</h2>
    <ul>
      <li>🎮 게임하기</li>
      <li>🎵 음악 듣기</li>
      <li>🍜 음식 만들어 먹기</li>
    </ul>
  </div>

  <div class="section">
    <h2>연락처</h2>
    <p>Email: <a href="mailto:witjr@naver.com">witjr@naver.com</a></p>
    <p>GitHub: <a href="https://github.com/Seoki55/webpJae" target="_blank" rel="noopener">github.com/Seoki55/webpJae</a></p>
  </div>
</body>
</html>
