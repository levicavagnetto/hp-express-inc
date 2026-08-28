class AppConfig {
  // Company Information
  static const String companyName = 'H&P Express Inc.';
  static const String tagline = 'Your freedom begins with a great job!';
  
  // Decoded Secure Contacts (decrypted at runtime to protect from web bots)
  // Base64 encoded values for hpexpressinc@hotmail.com and (320) 224-4352
  static const String encodedEmail = 'aHBleHByZXNzaW5jQGhvdG1haWwuY29t';
  static const String encodedPhone = 'KDMyMCkgMjI0LTQzNTI=';

  // Helper scroll and height script snippet for embedded forms
  static const String _scrollForwarderScript = '''
  <script>
    (function() {
      var lastHeight = 0;

      function sendScroll(deltaY) {
        try {
          window.parent.postMessage('COGNITO_SCROLL:' + deltaY, '*');
        } catch(e) {}
      }

      function sendHeight() {
        try {
          var container = document.querySelector('.form-container');
          var height = container ? container.offsetHeight : 0;
          if (height && height !== lastHeight) {
            lastHeight = height;
            var idx = typeof _cognitoFormIndex !== 'undefined' ? _cognitoFormIndex : 0;
            window.parent.postMessage('COGNITO_HEIGHT:' + height + ':' + idx, '*');
          }
        } catch(e) {}
      }

      window.addEventListener('load', sendHeight);
      window.addEventListener('resize', sendHeight);
      setInterval(sendHeight, 300);

      var observer = new MutationObserver(function() {
        sendHeight();
      });
      
      // We must observe body mutations to resize iframe dynamically
      setTimeout(function() {
         observer.observe(document.body, { childList: true, subtree: true, characterData: true });
      }, 50);

      // --- DIRECT CAPTURE FORWARDER ---
      // Instead of a physical overlay which blocks clicks, we use capture-phase event listeners 
      // on the window itself. By setting passive: false, we can prevent the default inner scrolling.
      
      var wheelFired = false;
      window.addEventListener('wheel', function(e) {
        e.preventDefault();
        wheelFired = true;
        var delta = e.deltaY;
        if (e.deltaMode === 1) delta *= 40;
        if (e.deltaMode === 2) delta *= 800;
        sendScroll(delta);
        setTimeout(function() { wheelFired = false; }, 50);
      }, { passive: false, capture: true });

      window.addEventListener('mousewheel', function(e) {
        if (wheelFired) return;
        e.preventDefault();
        var delta = (e.wheelDelta !== undefined) ? -e.wheelDelta : (e.deltaY || 0);
        sendScroll(delta);
      }, { passive: false, capture: true });

      window.addEventListener('DOMMouseScroll', function(e) {
        if (wheelFired) return;
        e.preventDefault();
        var delta = (e.detail || 0) * 16;
        sendScroll(delta);
      }, { passive: false, capture: true });

      var lastTouchY = 0;
      var touchHistory = [];

      window.addEventListener('touchstart', function(e) {
        if (e.touches && e.touches.length > 0) {
          lastTouchY = e.touches[0].clientY;
          touchHistory = [{ y: lastTouchY, t: Date.now() }];
          try { window.parent.postMessage('COGNITO_TOUCH_START', '*'); } catch(err) {}
        }
      }, { passive: true, capture: true });

      window.addEventListener('touchmove', function(e) {
        if (e.touches && e.touches.length > 0) {
          var currentY = e.touches[0].clientY;
          var deltaY = lastTouchY - currentY;
          lastTouchY = currentY;
          var now = Date.now();
          touchHistory.push({ y: currentY, t: now });
          while (touchHistory.length > 0 && now - touchHistory[0].t > 100) {
            touchHistory.shift();
          }
          try { window.parent.postMessage('COGNITO_TOUCH_MOVE:' + deltaY, '*'); } catch(err) {}
        }
      }, { passive: false, capture: true });

      window.addEventListener('touchend', function(e) {
        var velocity = 0;
        if (touchHistory.length > 1) {
          var first = touchHistory[0];
          var last = touchHistory[touchHistory.length - 1];
          var dt = last.t - first.t;
          var dy = last.y - first.y; // dy is negative if user swiped up (scrolling down)
          if (dt > 0) {
            velocity = (dy / dt) * 1000;
          }
        }
        touchHistory = [];
        try { window.parent.postMessage('COGNITO_TOUCH_END:' + velocity, '*'); } catch(err) {}
      }, { passive: true, capture: true });
      
      window.addEventListener('touchcancel', function(e) {
        touchHistory = [];
        try { window.parent.postMessage('COGNITO_TOUCH_END:0', '*'); } catch(err) {}
      }, { passive: true, capture: true });
    })();
  </script>
''';

  static String cognitoFormEmbedHtml({required int formNumber, required int formIndex}) {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      overflow: hidden;
      background-color: transparent;
    }
    .form-container {
      width: 100%;
      box-sizing: border-box;
      padding: 24px 16px 40px;
    }
  </style>
  <script>var _cognitoFormIndex = $formIndex;</script>
  $_scrollForwarderScript
</head>
<body>
  <div class="form-container">
    <script src="https://www.cognitoforms.com/f/seamless.js" data-key="jAAE2LhMrU2RWrl5Ha0cSA" data-form="$formNumber"></script>
  </div>
</body>
</html>''';
  }
}
