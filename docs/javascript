/* ============================================================
 * DUT Drone Development Guide - 交互增强脚本
 * ============================================================ */

document.addEventListener('DOMContentLoaded', function() {

  /* --- 表格响应式包装 (移动端横滚) --- */
  document.querySelectorAll('.md-typeset table').forEach(function(table) {
    if (!table.closest('.md-typeset__scrollwrap')) {
      var wrapper = document.createElement('div');
      wrapper.className = 'md-typeset__scrollwrap';
      var scroll = document.createElement('div');
      scroll.className = 'md-typeset__table';
      table.parentNode.insertBefore(wrapper, table);
      wrapper.appendChild(scroll);
      scroll.appendChild(table);
    }
  });

  /* --- 代码块一键复制提示（增强 Material 自带功能） --- */
  document.querySelectorAll('.md-clipboard').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var originalText = btn.getAttribute('title') || '复制内容';
      btn.setAttribute('title', '已复制! ✓');
      setTimeout(function() {
        btn.setAttribute('title', originalText);
      }, 2000);
    });
  });

  /* --- 图片点击放大（灯箱效果） --- */
  document.querySelectorAll('.md-typeset img').forEach(function(img) {
    img.style.cursor = 'pointer';
    img.addEventListener('click', function() {
      var overlay = document.createElement('div');
      overlay.style.cssText = '\
        position: fixed; top: 0; left: 0; width: 100%; height: 100%; \
        background: rgba(0,0,0,0.85); z-index: 9999; display: flex; \
        align-items: center; justify-content: center; cursor: zoom-out;';
      var cloneImg = img.cloneNode(true);
      cloneImg.style.cssText = '\
        max-width: 90%; max-height: 90%; object-fit: contain; \
        border-radius: 8px; box-shadow: 0 8px 32px rgba(0,0,0,0.3);';
      overlay.appendChild(cloneImg);
      overlay.addEventListener('click', function() {
        document.body.removeChild(overlay);
      });
      document.addEventListener('keydown', function close(e) {
        if (e.key === 'Escape') {
          document.body.removeChild(overlay);
          document.removeEventListener('keydown', close);
        }
      });
      document.body.appendChild(overlay);
    });
  });

  /* --- 外部链接新窗口打开 --- */
  document.querySelectorAll('.md-content a[href^="http"]').forEach(function(link) {
    if (!link.href.includes(window.location.hostname)) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });

  /* --- 右侧目录高亮当前可见标题 --- */
  if ('IntersectionObserver' in window) {
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        var id = entry.target.getAttribute('id');
        if (!id) return;
        var tocLink = document.querySelector('.md-nav--secondary a[href="#' + id + '"]');
        if (tocLink) {
          if (entry.isIntersecting) {
            tocLink.classList.add('md-nav__link--active');
          } else {
            tocLink.classList.remove('md-nav__link--active');
          }
        }
      });
    }, { rootMargin: '-80px 0px -80% 0px' });

    document.querySelectorAll('.md-content h2[id], .md-content h3[id]').forEach(function(heading) {
      observer.observe(heading);
    });
  }

});