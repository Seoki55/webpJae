(function(){
		const body = document.body;
		const themeToggle = document.getElementById('themeToggle');
		const stored = localStorage.getItem('theme'); // 'dark' 또는 'light' 저장
		const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

		function applyTheme(theme){
			if(theme === 'dark') body.setAttribute('data-theme', 'dark');
			else body.removeAttribute('data-theme');
			if(themeToggle) themeToggle.textContent = theme === 'dark' ? '라이트 모드' : '다크 모드';
		}

		// 초기 테마 결정: 저장된 값 -> 시스템 선호 -> 라이트
		const initial = stored || (prefersDark ? 'dark' : 'light');
		applyTheme(initial);

		if(themeToggle){
			themeToggle.addEventListener('click', ()=> {
				const next = body.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
				applyTheme(next);
				localStorage.setItem('theme', next);
			});
		}

		const form = document.getElementById('contactForm');
		if(form){
			form.addEventListener('submit', (e)=>{
				e.preventDefault();
				alert('메시지를 확인했습니다. (데모)');
				form.reset();
			});
		}
	})();
