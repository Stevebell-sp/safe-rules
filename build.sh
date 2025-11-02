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

# =============================
# 🧱 Facebook / Instagram 廣告與追蹤封鎖
# =============================
curl -fsSL https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds-Facebook-Tracking-List.txt -o "$EXT/goodbye_fb.txt" || true

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