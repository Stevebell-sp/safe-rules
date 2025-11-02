# 🧩 Taiwan Safe Rules (Auto)
### 🇹🇼 AdGuard Home / Pi-hole / Surge / Quantumult X 自動更新規則整合包

---

## 📘 專案介紹

本專案提供 **全自動每日更新的 DNS 過濾清單**，
針對 **台灣使用環境** 做最佳化，整合以下內容：

- ✅ 台灣各大銀行 / 政府機關 / 行動登入白名單
- ✅ Google / Microsoft / Apple / LINE / WeChat / Quark 等登入驗證白名單
- ✅ LINE 廣告、YouTube 廣告、短網址詐騙、假投資、假貸款、追蹤平台黑名單
- ✅ 整合多個高品質外部來源清單（自動更新）
- ✅ 每日由 GitHub Actions 自動重建、去重、發布

---

## ⚙️ 自動更新來源清單

| 類別 | 來源 | 狀態 |
|------|------|------|
| 🇷🇺 AdGuard DNS Filter（新版） | [AdGuardSDNSFilter](https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt) | ✅ |
| 🇨🇳 EasyList China | [EasyListChina](https://easylist-downloads.adblockplus.org/easylistchina.txt) | ✅ |
| 🇯🇵 YouTube 廣告過濾 | [YousList](https://raw.githubusercontent.com/yous/YousList/master/youslist.txt) | ✅ |
| 🇹🇼 5whys AdGuardHome Rules | [5whys Rules](https://raw.githubusercontent.com/5whys-adblock/AdGuardHome-rules/main/rules/output_full.txt) | ✅ |
| 🇩🇪 ppfeufer AdGuard List | [ppfeufer list](https://raw.githubusercontent.com/ppfeufer/adguard-filter-list/refs/heads/master/blocklist) | ✅ |
| 🇹🇼 165 反詐騙清單 #1 | [filter.futa.gg/TW165-redirect.txt](https://filter.futa.gg/TW165-redirect.txt) | ✅ |
| 🇹🇼 165 反詐騙清單 #2 | [filter.futa.gg/TW165_abp.txt](https://filter.futa.gg/TW165_abp.txt) | ✅ |

---

## 🧠 規則組成說明

| 類別 | 內容 |
|------|------|
| `rules/base_whitelist.txt` | 銀行 / 登入 / 微信 / LINE / Quark / Google / Apple 等白名單 |
| `rules/base_blacklist.txt` | LINE 廣告 / YouTube 廣告 / 詐騙 / 假購物 / 追蹤網域等 |
| `rules/extra_local.txt` | 你可自行加入臨時例外或封鎖域名 |
| `build.sh` | 主建構腳本：合併所有來源、去重、輸出最終清單 |
| `.github/workflows/build.yml` | 自動排程每日 12:00 台北時間重建規則 |

---

## 🧩 匯入 AdGuard Home 教學

1️⃣ 進入：  
**AdGuard Home → 過濾器 → DNS 封鎖清單 → 新增封鎖清單**

2️⃣ 貼上 RAW 清單網址：  
```
https://raw.githubusercontent.com/Stevebell-sp/safe-rules/main/dist/taiwan-safe-master.txt
```

3️⃣ 命名：  
`Taiwan Safe Rules (Auto)`  
更新頻率：24 小時（1440 分鐘）

4️⃣ 儲存後，按「檢查更新」以立即載入。

---

## 🔁 自動更新與版本資訊

每次自動建置的檔案開頭會顯示：
```
! Taiwan Safe Rules (auto-built)
! Updated: 2025-11-02T08:30:00+08:00
! Version: 20251102
! Source: https://github.com/Stevebell-sp/safe-rules
```

你可以在 AdGuard Home 介面看到最新版本的時間與行數。

---

## 🔍 驗證方式

| 類別 | 測試網址 | 預期結果 |
|------|-----------|-----------|
| ✅ 白名單（應通過） | `accounts.google.com`, `login.microsoftonline.com`, `cathaybk.com.tw`, `weixin.qq.com`, `myquark.cn` | 解析成功 |
| 🚫 黑名單（應封鎖） | `bit.ly`, `pagead2.googlesyndication.com`, `today.line.me`, `highprofit.site` | 解析失敗（NXDOMAIN） |

---

## 🧱 手動執行建置（開發者用）

```bash
chmod +x build.sh
./build.sh
```

生成結果會輸出至：
```
dist/taiwan-safe-master.txt
```

---

## 🪄 推薦上游 DNS（建議順序）

```
101.101.101.101       # Quad101（台灣學術網）
1.1.1.1               # Cloudflare
8.8.8.8               # Google
doh://dns.adguard.com/dns-query  # AdGuard DoH
```

---

## 🧰 未來擴充方向

- [ ] 加入台灣政府詐騙通報 API 自動同步
- [ ] 支援 AdGuard Home JSON API 直接推送更新
- [ ] 整合「社群封鎖貢獻」功能（使用 PR 方式提交）

---

## 🧾 授權與免責聲明

本專案僅供學術研究與個人自用。  
規則資料來自公開來源，作者不對因使用本清單導致的任何網路服務異常或損害負責。
