#!/usr/bin/env bash
set -euo pipefail

OUT=dist/taiwan-safe-master.txt
TMP=dist/.tmp
EXT="$TMP/external"
mkdir -p dist "$EXT"

# =============================
# 🌍 外部來源 (自動更新版本)
# =============================
echo "[INFO] 下載外部來源清單中..."

# 官方與區域清單
curl -fsSL https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt -o "$EXT/adguard_dns.txt" || true
curl -fsSL https://easylist-downloads.adblockplus.org/easylistchina.txt -o "$EXT/easylist_china.txt" || true
curl -fsSL https://raw.githubusercontent.com/yous/YousList/master/youslist.txt -o "$EXT/youslist.txt" || true
curl -fsSL https://raw.githubusercontent.com/5whys-adblock/AdGuardHome-rules/main/rules/output_full.txt -o "$EXT/5whys.txt" || true
curl -fsSL https://raw.githubusercontent.com/ppfeufer/adguard-filter-list/refs/heads/master/blocklist -o "$EXT/ppfeufer.txt" || true
curl -fsSL https://filter.futa.gg/TW165-redirect.txt -o "$EXT/tw165_1.txt" || true
curl -fsSL https://filter.futa.gg/TW165_abp.txt -o "$EXT/tw165_2.txt" || true

# 🧱 Facebook / Instagram 廣告與追蹤清單
curl -fsSL https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds-Facebook-Tracking-List.txt -o "$EXT/goodbye_fb.txt" || true

# =============================
# 🧩 合併主規則 (白 + 黑 + 外部來源)
# =============================
MERGED="$TMP/merged_stage.txt"
{
  echo "! Taiwan Safe Rules (auto-built)"
  echo "! Updated: $(TZ=Asia/Taipei date -Iseconds)"
  echo "! Version: $(date -u +%Y%m%d)"
  echo "! Source: https://github.com/<YOUR_GITHUB>/safe-rules"
  echo
  echo "! === local whitelist ==="
  cat rules/base_whitelist.txt
  echo
  echo "! === local blacklist ==="
  cat rules/base_blacklist.txt
  echo

  if [[ -s rules/extra_local.txt ]]; then
    echo "! === extra local ==="
    cat rules/extra_local.txt
    echo
  fi

  echo "! === external filters ==="
  for f in "$EXT"/*.txt; do
    [[ -e "$f" ]] || continue
    echo
    echo "! --- $(basename "$f") ---"
    cat "$f"
  done
} > "$MERGED"

# =============================
# 🧹 去重 + 去空行
# =============================
awk '!x[$0]++' "$MERGED" | sed -E '/^[[:space:]]*$/d' > "$OUT"

echo "[DONE] 規則建置完成：$OUT"
echo "[SIZE] $(wc -l < "$OUT") 行"
