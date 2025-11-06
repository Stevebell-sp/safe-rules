#!/usr/bin/env bash
set -euo pipefail

OUT=dist/taiwan-safe-master.txt
TMP=dist/.tmp
EXT="$TMP/external"
mkdir -p dist "$EXT"

echo "[INFO] 下載外部來源清單中..."

# =============================
# 🌍 官方與地區來源
# =============================
curl -fsSL https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt -o "$EXT/adguard_dns.txt" || true
curl -fsSL https://filters.adtidy.org/extension/adbka/base.txt -o "$EXT/adguard_base.txt" || true
curl -fsSL https://filters.adtidy.org/extension/adbka/tracking.txt -o "$EXT/adguard_tracking.txt" || true
curl -fsSL https://easylist-downloads.adblockplus.org/easylistchina.txt -o "$EXT/easylist_china.txt" || true
curl -fsSL https://raw.githubusercontent.com/yous/YousList/master/youslist.txt -o "$EXT/youslist.txt" || true
curl -fsSL https://raw.githubusercontent.com/5whys-adblock/AdGuardHome-rules/main/rules/output_full.txt -o "$EXT/5whys.txt" || true
curl -fsSL https://raw.githubusercontent.com/ppfeufer/adguard-filter-list/refs/heads/master/blocklist -o "$EXT/ppfeufer.txt" || true

# =============================
# 🇹🇼 台灣官方詐騙來源
# =============================
curl -fsSL https://filter.futa.gg/TW165-redirect.txt -o "$EXT/tw165_redirect.txt" || true
curl -fsSL https://filter.futa.gg/TW165_abp.txt -o "$EXT/tw165_abp.txt" || true

# 🇹🇼 MyGoPen 詐騙通報 API（JSON → 規則）
if command -v jq >/dev/null 2>&1; then
  echo "[INFO] 正在解析 MyGoPen Scam API..."
  curl -fsSL https://mystudy.mygoapp.tw/api/scam/opendata \
    | jq -r '.data[].url' \
    | sed 's/^/||/' \
    | sed 's/$/^/' \
    > "$EXT/mygopen_scam.txt" || true
else
  echo "[WARN] jq 未安裝，略過 MyGoPen API 解析"
fi

# 🇹🇼 備援：台灣網安社群詐騙網址資料庫（TaiwanScamList）
echo "[INFO] 抓取 TaiwanScamList 備援資料中..."
curl -fsSL https://raw.githubusercontent.com/iamdual/TaiwanScamList/main/blocklist.txt \
  -o "$EXT/taiwan_scam_backup.txt" || true

# =============================
# 🧱 Facebook / Instagram 廣告與追蹤封鎖
# =============================
curl -fsSL https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds-Facebook-Tracking-List.txt -o "$EXT/goodbye_fb.txt" || true

# =============================
# 📱 內建社群 & Bilibili 白名單
# =============================
SOCIAL_WHITELIST="$TMP/whitelist_social.txt"
cat > "$SOCIAL_WHITELIST" <<'EOF'
! === 📱 社群平台與影音網站白名單 ===

! 🟣 Instagram
@@||instagram.com^
@@||cdninstagram.com^
@@||ig.me^
@@||facebook.net^
@@||fbcdn.net^

! 🟠 Threads
@@||threads.net^
@@||cdnthreads.net^
@@||static.threads.net^
@@||meta.com^
@@||meta.net^
@@||l.instagram.com^

! 🔵 Twitter / X
@@||twitter.com^
@@||x.com^
@@||t.co^
@@||twimg.com^
@@||abs.twimg.com^
@@||video.twimg.com^

! 💖 Bilibili
@@||bilibili.com^
@@||bilibili.cn^
@@||passport.bilibili.com^
@@||passport.bilibili.cn^
@@||hdslb.com^
@@||api.bilibili.com^
@@||api.bilibili.cn^

! 💾 網盤與檔案分享白名單
@@||lanzouw.com^
@@||wwh.lanzouw.com^
@@||*.lanzouw.com^
EOF

# =============================
# 🧩 合併主規則 (白 + 黑 + 外部來源)
# =============================
MERGED="$TMP/merged_stage.txt"
{
  echo "! Taiwan Safe Rules (auto-built)"
  echo "! Updated: $(TZ=Asia/Taipei date -Iseconds)"
  echo "! Version: $(date -u +%Y%m%d)"
  echo "! Source: https://github.com/Stevebell-sp/safe-rules"
  echo
  echo "! === Local Whitelist ==="
  echo "! === Built-in Social & Bilibili Whitelist ==="
  cat "$SOCIAL_WHITELIST"
  echo
  cat rules/base_whitelist.txt 2>/dev/null || true
  echo
  echo "! === Local Blacklist ==="
  cat rules/base_blacklist.txt 2>/dev/null || true
  echo
  if [[ -s rules/extra_local.txt ]]; then
    echo "! === Extra Local Rules ==="
    cat rules/extra_local.txt
    echo
  fi
  echo "! === External Filters ==="
  for f in "$EXT"/*.txt; do
    [[ -e "$f" ]] || continue
    echo
    echo "! --- $(basename "$f") ---"
    cat "$f"
  done
} > "$MERGED"

# =============================
# 🧹 去重 + 清理
# =============================
awk '!x[$0]++' "$MERGED" | sed -E '/^[[:space:]]*$/d' > "$OUT"

echo "[DONE] 規則建置完成：$OUT"
echo "[SIZE] $(wc -l < "$OUT") 行"
