# Taiwan Safe Rules (Auto)

自動維護的 AdGuard Home / Pi-hole 規則集合（台灣環境）。

- `rules/base_whitelist.txt`：白名單（銀行、登入、LINE、微信、夸克、MFA…）
- `rules/base_blacklist.txt`：黑名單（短網址詐騙、LINE 廣告、YouTube 廣告、追蹤…）
- `rules/extra_local.txt`：你臨時新增的規則（可留空）
- `build.sh`：合併、去重、產生最終清單 `dist/taiwan-safe-master.txt`
- `.github/workflows/build.yml`：每日自動重建規則

## 使用方式
1. Fork 或直接建立此 Repo。
2. 啟用 GitHub Actions（Public repo 無需特別設定）。
3. 取得 RAW 清單網址（範例）：
   `https://raw.githubusercontent.com/<YOUR_GITHUB>/safe-rules/main/dist/taiwan-safe-master.txt`
4. AdGuard Home → Filters → DNS blocklists → Add blocklist → 貼上上面網址（建議 24h 更新）。

## 本地手動建置
```bash
chmod +x build.sh
./build.sh
```

## 版權與免責
僅供學術研究與自用。使用造成之服務異常或損害，請自行承擔風險。
