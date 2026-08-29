(function () {
  'use strict';

  var THEME_KEY = 'vrp_loadscreen_theme';
  var MUTE_KEY = 'vrp_loadscreen_muted';
  var VALID_THEMES = ['heist', 'vice', 'modern'];
  var BOOT_FADE_MS = 600;
  var BOOT_MAX_MS = 10000;  // safety cap in case boot.mp4 stalls without erroring or firing 'ended'

  // TEMPORARY diagnostic logging -- prints to the F8 console (NUI JS
  // console output shows up there, confirmed) with elapsed-ms-since-page-
  // load on every real loading event, so gaps/stalls are directly visible
  // instead of guessed at. Safe to strip once the timing is understood.
  var DEBUG_LOAD_START = Date.now();
  function debugLog(msg) {
    console.log('[vrp_loadscreen] +' + (Date.now() - DEBUG_LOAD_START) + 'ms ' + msg);
  }

  // html/img/bg/ holds a pool of background photos (1.png..N.png); each
  // load picks a random subset and slowly crossfades through just those,
  // so the loading screen looks different almost every time without
  // needing every image on every connect.
  var BG_IMAGE_COUNT = 12;
  var BG_IMAGE_PATH = 'img/bg/';
  var BG_SELECT_MIN = 5;
  var BG_SELECT_MAX = 8;
  var BG_SLIDE_INTERVAL_MS = 9000;

  // How many cfg.keybinds entries show at once per rotation -- kept in
  // sync with cfg.lua's cfg.keybinds_per_slide, same instant-start-before-
  // Lua reasoning as DEFAULT_TIPS/DEFAULT_RULES/DEFAULT_KEYBINDS below.
  var KEYBINDS_PER_SLIDE = 5;

  // Purely cosmetic -- how long the simulated Initializing / Getting
  // Character Data fills animate for. Overridden by vrpInit's
  // initializingMs/characterDataMs (cfg.lua's cfg.initializing_duration_ms
  // / cfg.character_data_duration_ms) once Lua's message arrives, same as
  // everything else here, so they stay visually in sync with how long
  // client.lua's close() is actually waiting -- but client.lua owns the
  // real timing regardless of what this shows.
  var initializingMs = 10000;
  var characterDataMs = 10000;

  // How often the waiting-state fill (before either Initializing trigger
  // arrives) restarts itself -- it doesn't know how long the real gap
  // will be, so it just keeps looping a fresh chunked fill until
  // startInitializing() takes over.
  var WAITING_LOOP_MS = 4000;

  // Loading screen JS starts running the instant this page renders, well
  // before this resource's Lua client script does (that's the whole point
  // of a loading screen -- it covers the phase where client resources are
  // still being loaded). So the tips/rules/audio defaults live here, not
  // in cfg.lua, and start immediately rather than waiting on a Lua
  // message. Lua's "vrpInit" message (see the 'message' listener below)
  // only overrides them once it eventually arrives -- it's an
  // enhancement, not a dependency. Keep these two lists in sync with
  // cfg.lua's cfg.tips/cfg.rules by hand.
  var DEFAULT_TIPS = [
    "New here? Type /help in chat to see available commands.",
    "Found a bug or a rule-breaker? Report it with /report.",
    "Your loading screen theme is saved automatically -- pick your favorite with the swatches in the corner.",
    "Toggle the loading screen music with the speaker icon in the top right.",
  ];
  var DEFAULT_RULES = [
    "No RDM (Random Death Match) -- don't kill or attack players without valid, established roleplay.",
    "No VDM (Vehicle Death Match) -- don't use vehicles as weapons outside of legitimate RP scenarios.",
    "No metagaming -- using out-of-character info (streams, Discord, OOC chat) in-character is not allowed.",
    "No powergaming -- give others a real chance to react; don't force unavoidable outcomes on them.",
    "Value your life -- roleplay realistic fear and self-preservation in dangerous situations.",
    "Respect the New Life Rule (NLR) -- your character forgets the events leading up to their death.",
    "Initiate before engaging -- proper RP initiation is required before combat.",
    "No exploiting bugs or glitches for personal or group advantage.",
  ];
  var DEFAULT_KEYBINDS = [
    "W / A / S / D -- Move",
    "SHIFT -- Sprint",
    "CTRL -- Crouch",
    "E -- Interact / Enter Vehicle",
    "TAB -- Inventory",
    "M -- Map",
    "F1 -- Phone",
    "H -- Horn",
    "B -- Seatbelt",
    "L -- Flashlight",
  ];
  var DEFAULT_AUDIO = { volume: 0.5, loop: true, autoplay: true };

  var root = document.documentElement;
  var els = {
    serverName: document.getElementById('serverName'),
    playerCount: document.getElementById('playerCount'),
    tipText: document.getElementById('tipText'),
    ruleText: document.getElementById('ruleText'),
    keyText: document.getElementById('keyText'),
    progressBar: document.getElementById('progressBar'),
    progressPct: document.getElementById('progressPct'),
    statusText: document.getElementById('statusText'),
    fadeOverlay: document.getElementById('fadeOverlay'),
    themeSwitcher: document.getElementById('themeSwitcher'),
    muteBtn: document.getElementById('muteBtn'),
    muteIcon: document.getElementById('muteIcon'),
    bgAudio: document.getElementById('bgAudio'),
    bgSlideA: document.getElementById('bgSlideA'),
    bgSlideB: document.getElementById('bgSlideB'),
    bootScreen: document.getElementById('bootScreen'),
    bootVideo: document.getElementById('bootVideo'),
    bootAudio: document.getElementById('bootAudio'),
  };

  var state = {
    closed: false,
    mainStarted: false,
  };

  // ---------------------------------------------------------------------
  // Theme handling -- applied immediately from local storage (or the
  // fallback below) so there's no flash of the wrong theme before Lua's
  // init message arrives.
  // ---------------------------------------------------------------------

  function applyTheme(theme, persist) {
    if (VALID_THEMES.indexOf(theme) === -1) theme = 'heist';
    root.setAttribute('data-theme', theme);

    var swatches = els.themeSwitcher.querySelectorAll('.swatch');
    swatches.forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.themeChoice === theme);
    });

    if (persist) {
      try { localStorage.setItem(THEME_KEY, theme); } catch (e) {}
    }
  }

  (function initTheme() {
    var saved = null;
    try { saved = localStorage.getItem(THEME_KEY); } catch (e) {}
    applyTheme(saved || 'heist', false);
  })();

  els.themeSwitcher.addEventListener('click', function (ev) {
    var btn = ev.target.closest('.swatch');
    if (!btn) return;
    applyTheme(btn.dataset.themeChoice, true);
  });

  // ---------------------------------------------------------------------
  // Boot screen -- silent boot.mp4 plays once, then fades into the main
  // screen. Falls straight through with no delay if the video is missing
  // or fails to play (e.g. during development before it's dropped in).
  // ---------------------------------------------------------------------

  function stopBootAudio() {
    els.bootAudio.pause();
    els.bootAudio.currentTime = 0;
  }

  function finishBoot() {
    if (els.bootScreen.classList.contains('fade-out')) return;
    stopBootAudio();
    els.bootScreen.classList.add('fade-out');
    setTimeout(function () {
      els.bootScreen.classList.add('hidden');
    }, BOOT_FADE_MS);
    startMainScreen();
  }

  function skipBoot() {
    stopBootAudio();
    els.bootScreen.classList.add('hidden');
    startMainScreen();
  }

  function runBootSequence() {
    els.bootVideo.addEventListener('ended', finishBoot);
    els.bootVideo.addEventListener('error', skipBoot);
    // Safety net: if boot.mp4 stalls without erroring or ending (bad
    // encode, huge file, etc.), don't leave the player staring at it.
    setTimeout(function () {
      if (!state.mainStarted) finishBoot();
    }, BOOT_MAX_MS);

    // Respect a previously-saved mute preference (a player who muted last
    // time shouldn't get blasted with boot audio this time) -- setMuted
    // (defined below) keeps bootAudio and bgAudio in sync from here on.
    var mutedSaved = null;
    try { mutedSaved = localStorage.getItem(MUTE_KEY); } catch (e) {}
    setMuted(mutedSaved === '1', false);

    // bootVideo itself stays permanently muted (see its HTML attribute --
    // Chromium-family browsers, which FiveM's NUI is, commonly block
    // unmuted <video> autoplay outright, and the loading screen never
    // grabs NUI input focus, so there's no click for an "unmute on first
    // interaction" fallback to ever catch). bootAudio plays the real
    // sound instead, pointed at the same boot.mp4 -- an <audio> element
    // happily plays just the audio track of an mp4, and unmuted <audio>
    // autoplay is confirmed working already via bgAudio elsewhere on this
    // page, so this sidesteps the restriction entirely rather than
    // fighting it.
    els.bootVideo.play().catch(skipBoot);
    els.bootAudio.play().catch(function () {
      els.bootAudio.muted = true;
      els.bootAudio.play().catch(function () {});
      document.addEventListener('click', function once() {
        if (!els.muteBtn.classList.contains('muted')) els.bootAudio.muted = false;
        document.removeEventListener('click', once);
      });
    });
  }

  // ---------------------------------------------------------------------
  // Background slideshow -- random subset of html/img/bg/*.png, crossfaded
  // on a loop for the rest of the load. The per-theme colored .bg-tint
  // overlay (see style.css) is what differentiates the same photo pool
  // across heist/vice/modern. Fails silently into the gradient .bg-layer
  // if every image is missing.
  // ---------------------------------------------------------------------

  function shuffle(arr) {
    for (var i = arr.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
    }
    return arr;
  }

  function preloadImage(src) {
    return new Promise(function (resolve) {
      var img = new Image();
      img.onload = function () { resolve(src); };
      img.onerror = function () { resolve(null); };
      img.src = src;
    });
  }

  function startBackgroundSlideshow() {
    var all = [];
    for (var i = 1; i <= BG_IMAGE_COUNT; i++) all.push(BG_IMAGE_PATH + i + '.jpg');
    shuffle(all);

    var pickCount = BG_SELECT_MIN + Math.floor(Math.random() * (BG_SELECT_MAX - BG_SELECT_MIN + 1));
    var candidates = all.slice(0, Math.min(pickCount, all.length));

    Promise.all(candidates.map(preloadImage)).then(function (results) {
      var pool = results.filter(function (src) { return !!src; });
      if (!pool.length) return;

      var layers = [els.bgSlideA, els.bgSlideB];
      var layerIndex = 0;
      var poolIndex = 0;

      function showNext() {
        var layer = layers[layerIndex % 2];
        var other = layers[(layerIndex + 1) % 2];
        layer.style.backgroundImage = 'url("' + pool[poolIndex % pool.length] + '")';
        layer.classList.add('visible');
        other.classList.remove('visible');
        layerIndex++;
        poolIndex++;
      }

      showNext();
      if (pool.length > 1) setInterval(showNext, BG_SLIDE_INTERVAL_MS);
    });
  }

  // ---------------------------------------------------------------------
  // Audio
  // ---------------------------------------------------------------------

  function setMuted(muted, persist) {
    els.bgAudio.muted = muted;
    els.bootAudio.muted = muted;
    els.muteBtn.classList.toggle('muted', muted);
    els.muteIcon.innerHTML = muted ? '&#9835;&#0824;' : '&#9834;';
    if (persist) {
      try { localStorage.setItem(MUTE_KEY, muted ? '1' : '0'); } catch (e) {}
    }
  }

  els.muteBtn.addEventListener('click', function () {
    setMuted(!els.bgAudio.muted, true);
  });

  // Called once at main-screen start (JS defaults) and again if Lua's
  // vrpInit later arrives with different settings -- the second call only
  // adjusts volume/loop, it never restarts playback or touches mute state.
  function applyAudioSettings(cfg, allowPlay) {
    cfg = cfg || {};
    els.bgAudio.loop = cfg.loop !== false;
    els.bgAudio.volume = typeof cfg.volume === 'number' ? cfg.volume : 0.5;

    if (allowPlay && cfg.autoplay !== false && els.bgAudio.paused) {
      els.bgAudio.play().catch(function () {
        document.addEventListener('click', function once() {
          els.bgAudio.play().catch(function () {});
          document.removeEventListener('click', once);
        });
      });
    }
  }

  // NOTE: bgAudio can go silent partway through connecting on some
  // clients -- root cause confirmed to be FiveM's own Mumble VoIP
  // subsystem claiming the OS audio device mid-connect (see F8 console:
  // "Returning device Speakers..."/"MumbleAudioInput::InitializeAudioDevice"
  // right around when script loading finishes), not anything this
  // resource does. A JS-side mute-toggle kick was tried here to force
  // recovery, but it caused its own audible stutter on clients that don't
  // hit the underlying VoIP conflict, which is worse than the original
  // problem. The actual fix is client-side FiveM settings (Settings >
  // Audio > "Mute audio on focus loss", and Settings > Voice Chat >
  // "Voice/Noise Suppression") -- worth a line in your server's
  // connecting instructions if players report this.

  // ---------------------------------------------------------------------
  // Rotators -- shared engine behind the plain center tip line and both
  // side panels (rules/left, keybinds/right). Each is independent: own
  // list, own index, own timer, own interval, so they don't drift in sync
  // with each other. An item can be a single string (tips/rules -- one
  // line) or an array of strings (keybinds -- rendered as multiple lines
  // per slide via the .side-panel-text white-space: pre-line rule).
  // ---------------------------------------------------------------------

  function chunk(arr, size) {
    var out = [];
    for (var i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
    return out;
  }

  function createRotator(textEl, intervalMs) {
    var items = [];
    var index = 0;
    var timer = null;

    function show(i) {
      textEl.classList.add('fading');
      setTimeout(function () {
        var item = items[i % items.length];
        textEl.textContent = Array.isArray(item) ? item.join('\n') : item;
        textEl.classList.remove('fading');
      }, 300);
    }

    function start(newItems) {
      items = Array.isArray(newItems) && newItems.length ? newItems : items;
      if (timer) clearInterval(timer);
      if (!items.length) return;

      index = 0;
      show(index);
      timer = setInterval(function () {
        index = (index + 1) % items.length;
        show(index);
      }, intervalMs);
    }

    function stop() {
      if (timer) clearInterval(timer);
      timer = null;
    }

    return { start: start, stop: stop };
  }

  var tipsRotator = createRotator(els.tipText, 6000);
  var rulesRotator = createRotator(els.ruleText, 7000);
  var keybindsRotator = createRotator(els.keyText, 7000);

  // ---------------------------------------------------------------------
  // Main screen start -- runs the instant the boot stage clears (or
  // immediately, if there's no boot image at all). Nothing here waits on
  // Lua/the server.
  // ---------------------------------------------------------------------

  function startMainScreen() {
    if (state.mainStarted) return;
    state.mainStarted = true;

    var mutedSaved = null;
    try { mutedSaved = localStorage.getItem(MUTE_KEY); } catch (e) {}
    setMuted(mutedSaved === '1', false);

    tipsRotator.start(DEFAULT_TIPS);
    rulesRotator.start(DEFAULT_RULES);
    keybindsRotator.start(chunk(DEFAULT_KEYBINDS, KEYBINDS_PER_SLIDE));
    applyAudioSettings(DEFAULT_AUDIO, true);
  }

  // ---------------------------------------------------------------------
  // Progress -- driven by FiveM's own granular loading events rather than
  // the single aggregate loadProgress/loadFraction event. count/idx reset
  // whenever a new phase starts (init functions, then data file entries),
  // same two-phase shape as the original script this was modeled on.
  //
  // Starts in an indeterminate/pulsing state with no percentage shown --
  // "Connecting..." -- rather than sitting frozen at 0%, since on a small
  // dev server these events can fire and finish within a fraction of a
  // second (few resources = few discrete steps). Switches to showing a
  // real percentage only once the first real data point actually arrives,
  // so the bar never looks stuck/dead even if these events end up firing
  // faster than perceptible, or (on some future game build) not at all.
  // ---------------------------------------------------------------------

  var loadCount = 0;
  var loadIdx = 0;
  var gotNativeProgress = false;
  var dataPhaseState = 'pending';  // 'pending' | 'real' | 'waiting' | 'initializing' | 'serverData' | 'characterData'
  var cancelActiveFill = null;     // cancel fn for whichever animateFill() is currently running, if any

  // Restores the fast, snappy transition real progress updates use --
  // separate from the slow linear one animateFill() sets directly on the
  // element.
  function resetBarTransition() {
    els.progressBar.style.transition = '';
  }

  function setProgress(fraction) {
    if (state.closed) return;
    if (!gotNativeProgress) {
      gotNativeProgress = true;
      els.progressBar.classList.remove('indeterminate');
    }
    var pct = Math.max(0, Math.min(1, fraction)) * 100;
    els.progressBar.style.width = pct + '%';
    els.progressPct.textContent = Math.round(pct) + '%';

    // Once a phase visually completes, keep it pulsing via CSS rather
    // than sitting static -- .indeterminate's animation runs on the
    // compositor thread, independent of main-thread JS. Real loading can
    // briefly stall/throttle JS timers (this is why the "Loading files"
    // debounce below can be delayed or skipped entirely), so this is what
    // keeps the bar looking alive through that stall regardless of
    // whether any further JS gets a chance to run.
    if (pct >= 100) {
      els.progressBar.classList.add('indeterminate');
    } else {
      els.progressBar.classList.remove('indeterminate');
    }
  }

  function updateNativeProgress() {
    if (loadCount > 0) setProgress(loadIdx / loadCount);
  }

  // Each real FiveM loading phase (init functions, then data file
  // entries) gets its own label and its own bar reset -- previously both
  // shared one generic "Loading world..." the whole time and never
  // visibly reset between phases.
  function setPhase(count, label) {
    loadCount = count;
    loadIdx = 0;
    resetBarTransition();
    els.statusText.textContent = label;
    setProgress(0);
  }

  // Simulated 0 -> 100% fill for the Initializing buffer -- chunked with
  // uneven step sizes and irregular pauses between them, rather than one
  // smooth linear ramp, so it reads as real chunked data arriving instead
  // of an obviously fake countdown. Only used post-freeze (this only ever
  // runs from startInitializing, triggered by vrpNativeReady/vrpClose,
  // both of which only arrive once the earlier NUI stall has already
  // cleared), so setTimeout-driven timing is safe to rely on here, unlike
  // the earlier attempts to use it during the stall itself. Returns a
  // cancel function.
  function animateFill(durationMs) {
    if (state.closed) return function () {};
    gotNativeProgress = true;
    // .indeterminate is width:100% !important -- if a previous phase left
    // it on the element, it would silently override the style.width='0%'
    // reset below (an !important stylesheet rule always beats an inline
    // style), leaving the bar visually pinned at 100% no matter what this
    // function does. Must come off before the reset, not just once ever.
    els.progressBar.classList.remove('indeterminate');

    els.progressBar.style.transition = 'none';
    els.progressBar.style.width = '0%';
    els.progressPct.textContent = '0%';
    void els.progressBar.offsetWidth; // force reflow so 0% actually applies before animating back up

    var STEP_MS = 220;               // quick snappy fill per chunk, like a burst of data landing
    var chunks = [];                 // uneven step sizes (4-18% each) summing to exactly 100
    var remaining = 100;
    while (remaining > 0) {
      var take = Math.min(remaining, 4 + Math.random() * 14);
      chunks.push(take);
      remaining -= take;
    }

    // Spread whatever time isn't spent on the fill transitions themselves
    // across irregular pauses between chunks, so some gaps read as a
    // quick trickle and others as a longer stall -- same variance real
    // chunked loading has.
    var pauseBudget = Math.max(0, durationMs - chunks.length * STEP_MS);
    var pauseWeights = chunks.map(function () { return Math.random(); });
    var weightSum = pauseWeights.reduce(function (a, b) { return a + b; }, 0) || 1;
    var pauses = pauseWeights.map(function (w) { return (w / weightSum) * pauseBudget; });

    var cancelled = false;
    var progress = 0;

    function step(i) {
      if (cancelled || state.closed) return;

      if (i >= chunks.length) {
        // Same compositor-thread pulse fallback as setProgress -- if
        // whatever comes next (vrpFadeOut) is delayed, this keeps the bar
        // visibly alive instead of sitting static at 100% again.
        els.progressBar.style.transition = '';
        els.progressBar.classList.add('indeterminate');
        return;
      }

      progress += chunks[i];
      var pct = Math.min(100, Math.round(progress));
      els.progressBar.style.transition = 'width ' + STEP_MS + 'ms ease-out';
      els.progressBar.style.width = pct + '%';
      els.progressPct.textContent = pct + '%';

      setTimeout(function () {
        if (cancelled || state.closed) return;
        setTimeout(function () { step(i + 1); }, pauses[i]);
      }, STEP_MS);
    }

    step(0);

    return function cancel() { cancelled = true; };
  }

  // Starts the looping waiting-state fill (runWaitingFill). Called from
  // two places below: the real vrpNativeReady signal (preferred -- see
  // client.lua's playerSpawned handler) and, as a fallback in case that
  // message is ever somehow lost, a same-tick progress-ratio check.
  function startWaitingState() {
    if (dataPhaseState !== 'pending') return;
    debugLog('startWaitingState triggered');

    dataPhaseState = 'waiting';
    els.statusText.textContent = 'Initializing…';
    runWaitingFill();
  }

  // Standard chunked fill, looped -- same look as the real Initializing/
  // Loading Character Data steps, just repeating since we don't know how
  // long the real gap will actually be. Stops itself the moment
  // dataPhaseState moves on (startInitializing sets it to 'initializing').
  function runWaitingFill() {
    if (dataPhaseState !== 'waiting') return;
    cancelActiveFill = animateFill(WAITING_LOOP_MS);

    setTimeout(function () {
      if (dataPhaseState === 'waiting') runWaitingFill();
    }, WAITING_LOOP_MS);
  }

  // Called synchronously from within the initFunctionInvoking handler
  // itself -- no setTimeout/debounce involved, deliberately. A timer-based
  // "wait to see if anything else arrives" approach was tried (twice, at
  // different durations) and consistently lost the race against real
  // multi-second stalls in the NUI's JS thread: the debounce would queue
  // up like everything else and only fire once the stall cleared, by which
  // point vRP's own ready signal had usually already arrived and cancelled
  // it. Message events (this one included) get delivered and handled
  // immediately regardless of any such stall -- onVrpClose is proof of
  // that -- so checking the real progress ratio right here, inline, is the
  // one thing that's actually reliable as a fallback. >=98% (not exactly
  // 100%) accounts for FiveM's idx possibly being 0-indexed and never
  // literally reaching count. In practice vrpNativeReady (playerSpawned,
  // forwarded from client.lua) should win this race almost every time,
  // since it's a definitive "connecting is actually done" signal rather
  // than a guess.
  function maybeStartWaitingState() {
    if (loadCount <= 0 || loadIdx / loadCount < 0.98) return;
    startWaitingState();
  }

  // ---------------------------------------------------------------------
  // Finish -- entirely reactive to Lua's own timer chain (client.lua's
  // close()), which handles the extra "Initializing" safety buffer and
  // final fade timing itself rather than the NUI trying to call back into
  // Lua (RegisterNUICallback support for the special "loadingScreen" frame
  // specifically isn't something documented/verified, unlike
  // SendLoadingScreenMessage, which is confirmed one-way Lua -> NUI and is
  // all this needs). vrpClose fires once vRP says the character is ready;
  // vrpFadeOut fires cfg.initializing_duration_ms later, once Lua is about
  // to actually tear the NUI down.
  // ---------------------------------------------------------------------

  // Starts the real animated Initializing fill. Called from vrpNativeReady
  // (playerSpawned, forwarded from client.lua -- the preferred, earlier
  // trigger) and from onVrpClose as a fallback in case that message is
  // ever somehow missed. Guarded against double-starting: if
  // vrpNativeReady already started it, a later vrpClose just leaves the
  // already-running fill alone instead of restarting it from 0%.
  function startInitializing() {
    if (dataPhaseState === 'initializing' || dataPhaseState === 'characterData') return;
    dataPhaseState = 'initializing';

    if (cancelActiveFill) { cancelActiveFill(); cancelActiveFill = null; }
    els.statusText.textContent = 'Initializing…';
    resetBarTransition();
    cancelActiveFill = animateFill(initializingMs);
  }

  // Second simulated step, triggered by Lua's vrpCharacterData message
  // (sent cfg.initializing_duration_ms after close()) -- same chunked
  // fill, different label, purely cosmetic like Initializing itself.
  // Starts as soon as vRP confirms ready (usually while Initializing is
  // still visually running -- see onVrpClose), well before Lua's own
  // separate vrpCharacterData message actually arrives (that runs on its
  // own fixed cfg.initializing_duration_ms schedule from close(),
  // decoupled from whenever this started). Since we don't know how much
  // longer that'll take from here, this loops the same way the earlier
  // waiting-state fill does, rather than running once and sitting idle.
  function startServerData() {
    if (dataPhaseState === 'serverData' || dataPhaseState === 'characterData') return;
    dataPhaseState = 'serverData';

    if (cancelActiveFill) { cancelActiveFill(); cancelActiveFill = null; }
    els.statusText.textContent = 'Loading Server Data…';
    runServerDataFill();
  }

  function runServerDataFill() {
    if (dataPhaseState !== 'serverData') return;
    resetBarTransition();
    cancelActiveFill = animateFill(WAITING_LOOP_MS);

    setTimeout(function () {
      if (dataPhaseState === 'serverData') runServerDataFill();
    }, WAITING_LOOP_MS);
  }

  // Final simulated step -- triggered when Lua's vrpCharacterData message
  // actually arrives (see the message handler below) while Loading Server
  // Data is already showing, which is the normal case since vrpClose
  // usually force-starts that earlier already. Runs for
  // cfg.character_data_duration_ms, which is exactly how long Lua's own
  // close() chain waits between sending this message and sending
  // vrpFadeOut, so this fill and the real close stay lined up.
  function startCharacterData() {
    if (dataPhaseState === 'characterData') return;
    dataPhaseState = 'characterData';

    if (cancelActiveFill) { cancelActiveFill(); cancelActiveFill = null; }
    els.statusText.textContent = 'Loading Character Data…';
    resetBarTransition();
    cancelActiveFill = animateFill(characterDataMs);
  }

  function onVrpClose() {
    debugLog('vrpClose received, dataPhaseState was=' + dataPhaseState);

    if (dataPhaseState === 'initializing') {
      // Initializing already started earlier via vrpNativeReady -- vRP
      // confirming ready now is the real signal that it's done, so switch
      // to Loading Server Data right here instead of leaving Initializing
      // sitting in its post-fill pulse until something else moves things
      // along.
      startServerData();
    } else {
      // vrpNativeReady never arrived (or hasn't yet) -- fall back to
      // starting Initializing normally.
      startInitializing();
    }
  }

  function onVrpFadeOut() {
    if (state.closed) return;
    state.closed = true;

    if (cancelActiveFill) { cancelActiveFill(); cancelActiveFill = null; }
    els.statusText.textContent = 'Ready';
    els.fadeOverlay.classList.add('active');
    tipsRotator.stop();
    rulesRotator.stop();
    keybindsRotator.stop();

    var fade = setInterval(function () {
      if (els.bgAudio.volume > 0.05) {
        els.bgAudio.volume = Math.max(0, els.bgAudio.volume - 0.05);
      } else {
        els.bgAudio.pause();
        clearInterval(fade);
      }
    }, 40);
  }

  // ---------------------------------------------------------------------
  // Lua -> NUI messages -- all enhancement/override, nothing here is
  // required for the screen to already be running by the time it arrives.
  // ---------------------------------------------------------------------

  window.addEventListener('message', function (event) {
    var data = event.data || {};

    switch (data.eventName) {
      // Real FiveM loading-screen events -- two phases (init functions,
      // then data file entries), each with its own label and its own
      // bar reset via setPhase().
      case 'startInitFunctionOrder':
        debugLog('startInitFunctionOrder count=' + data.count);
        setPhase(data.count, 'Loading scripts…');
        break;

      case 'initFunctionInvoking':
        loadIdx = data.idx;
        debugLog('initFunctionInvoking idx=' + data.idx + ' count=' + loadCount +
          ' ratio=' + (loadCount > 0 ? (data.idx / loadCount).toFixed(3) : 'n/a'));
        updateNativeProgress();
        maybeStartWaitingState();
        break;

      case 'startDataFileEntries':
        debugLog('startDataFileEntries count=' + data.count + ' dataPhaseState=' + dataPhaseState);
        // Only honored if we haven't already moved on to the waiting/
        // Initializing state -- avoids stepping backward from
        // "Initializing..." to "Loading files..." if this happens to
        // arrive late (see maybeStartWaitingState's comment on why real
        // events can still be delayed by a stall even though they're
        // reliable once they do get processed).
        if (dataPhaseState !== 'pending') break;
        dataPhaseState = 'real';
        setPhase(data.count, 'Loading files…');
        break;

      case 'performMapLoadFunction':
        loadIdx++;
        debugLog('performMapLoadFunction idx=' + loadIdx + ' count=' + loadCount);
        updateNativeProgress();
        break;

      case 'vrpInit':
        if (data.serverName) els.serverName.textContent = data.serverName;
        if (typeof data.initializingMs === 'number') initializingMs = data.initializingMs;
        if (typeof data.characterDataMs === 'number') characterDataMs = data.characterDataMs;

        var savedTheme = null;
        try { savedTheme = localStorage.getItem(THEME_KEY); } catch (e) {}
        if (!savedTheme) applyTheme(data.defaultTheme || 'heist', false);

        if (Array.isArray(data.tips) && data.tips.length) tipsRotator.start(data.tips);
        if (Array.isArray(data.rules) && data.rules.length) rulesRotator.start(data.rules);
        if (Array.isArray(data.keybinds) && data.keybinds.length) {
          var perSlide = typeof data.keybindsPerSlide === 'number' && data.keybindsPerSlide > 0
            ? data.keybindsPerSlide : KEYBINDS_PER_SLIDE;
          keybindsRotator.start(chunk(data.keybinds, perSlide));
        }
        applyAudioSettings(data.audio, false);
        break;

      case 'vrpPlayerCount':
        if (typeof data.count === 'number') {
          els.playerCount.textContent = data.count + ' / ' + (data.max || '--') + ' online';
        }
        break;

      // FiveM's native "the ped exists" event, forwarded from
      // client.lua's playerSpawned handler -- fires once real connecting/
      // building is actually done, ahead of vRP's own separate ~2s-later
      // readiness check. Preferred trigger for starting the real
      // Initializing fill over the percentage-based fallback above.
      case 'vrpNativeReady':
        debugLog('vrpNativeReady received, dataPhaseState=' + dataPhaseState);
        startInitializing();
        break;

      case 'vrpClose':
        onVrpClose();
        break;

      // Lua's own delayed signal (sent cfg.initializing_duration_ms after
      // close()). Normally arrives while already showing "Loading Server
      // Data..." (started earlier via vrpClose), in which case this is
      // what actually starts "Loading Character Data...". If vrpClose's
      // force-transition never happened for some reason, falls back to
      // starting Loading Server Data now instead of doing nothing.
      case 'vrpCharacterData':
        debugLog('vrpCharacterData received, dataPhaseState was=' + dataPhaseState);
        if (dataPhaseState === 'serverData') {
          startCharacterData();
        } else {
          startServerData();
        }
        break;

      case 'vrpFadeOut':
        onVrpFadeOut();
        break;
    }
  });

  runBootSequence();
  startBackgroundSlideshow();
})();
