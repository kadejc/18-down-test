/* Test-site guard (Kade, 2026-11-28). deploy.sh puts this at the top of every test build; it is not part of the game.
   1. Offline: the test build plays by different rules than the live game, so it must never write to Hayden's live
      Supabase project (cloud saves, the friends leaderboard, contests, rating votes). Every request to Supabase fails
      here, before it leaves the phone.
   2. Progress reset: the first time a phone opens a build with a new RESET date, every saved 18 Down key on this site is
      cleared, except a few settings. Change RESET to start everyone over again. The live game's site is a different
      address, so its saves are never touched. */
(function(){
  var RESET = "2026-11-28";
  var KEEP = /^18down\.(mute|meonly|hard|testReset)$/;
  try {
    if (localStorage.getItem("18down.testReset") !== RESET){
      var drop = [];
      for (var i = 0; i < localStorage.length; i++){ var k = localStorage.key(i); if (k && k.indexOf("18down.") === 0 && !KEEP.test(k)) drop.push(k); }
      drop.forEach(function(k){ localStorage.removeItem(k); });
      localStorage.setItem("18down.testReset", RESET);
    }
  } catch (e) {}
  var f = window.fetch;
  window.fetch = function(input, init){
    var url = typeof input === "string" ? input : (input && input.url) || "";
    if (/supabase\.co/i.test(url)) return Promise.reject(new Error("Online features are off on the test site"));
    return f.apply(this, arguments);
  };
  window.__18DOWN_TEST = true;
})();
