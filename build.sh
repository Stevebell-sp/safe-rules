#!/usr/bin/env bash
set -euo pipefail

OUT=dist/taiwan-safe-master.txt
TMP=dist/.tmp
mkdir -p dist "$TMP"

# 你可以在這裡加入外部來源清單（取消註解以下範例）
# curl -fsSL https://filters.adtidy.org/dns/adguard-dns.txt -o "$TMP/adguard_dns.txt" || true
# curl -fsSL https://easylist-downloads.adblockplus.org/easylistchina.txt -o "$TMP/easylist_china.txt" || true

{
  echo "! Taiwan Safe Rules (auto-built)"
  echo "! Updated: $(TZ=Asia/Taipei date -Iseconds)"
  echo "! Source: https://github.com/<YOUR_GITHUB>/safe-rules"
  echo

  cat rules/base_whitelist.txt
  echo
  cat rules/base_blacklist.txt
  echo
  if [[ -s rules/extra_local.txt ]]; then
    echo "! === extra local ==="
    cat rules/extra_local.txt
  fi

  # 附加外部來源（若有下載）
  # for f in "$TMP"/*.txt; do
  #   echo
  #   echo "! === external: $(basename "$f") ==="
  #   cat "$f"
  # done
} > "$TMP/merged.txt"

# 去重與去空白行（保留註解）
awk '!x[$0]++' "$TMP/merged.txt" | sed -E '/^[[:space:]]*$/d' > "$OUT"
echo "Built: $OUT"
