！！！AI 必須全程使用繁體中文進行問答！！！

# 交接入口（跨 AI 通用）

本文件為跨 AI 接棒入口，負責導航與跨階段規則。**實作細節不寫於此**，交由對應檔案承擔，避免重複導致不一致。

---

## 必讀順序（不得跳過）

```
一、docs/SOP/（先讀大綱.md        — 30 秒總覽當前 R 階段進度
二、docs/SOP/Debug_Log.md          — 通用 Debug 紀律（R2-14 曾三任翻車皆因跳過）
三、對應 R 階段 SOP（docs/SOP/R?：...md）— 當前階段工作手冊
四、CC 專屬：memory/project_home_studio_r2_13_handover.md
   （R2 實作決策、技術規格、踩雷全量—CC auto memory，OC/GC 無此系統）
```

未依序讀完勿動 code。

---

## 本地開發環境

```
專案目錄：/Users/eajrockmacmini/Documents/VS Code/My Project/Home_Studio_3D/
啟動 server：cd 上列目錄 && python3 -m http.server 9001
驗證 URL：http://localhost:9001/Home_Studio.html
          （勿加 Home_Studio_3D/ 前綴，server cwd 已在專案內）
GitHub Pages：https://ghnewbie2022.github.io/Home_Studio_3D/Home_Studio.html
當前 cache-buster：見 Home_Studio.html inline script tag，勿憑記憶複製
```

**每次對話開始時先 curl 或開瀏覽器確認 200 OK 再動工。**

---

## Git 工作流程

```
main       凍結於 tag v2.18-final（R2 完工穩定版）
r3-light   R3 工作分支（目前 active）
接手 R3 前：git checkout r3-light
R3 全驗收後：merge r3-light → main, tag v3.0-final
```

---

## 跨階段強制規則

### 一、K 神思考方式（動手前必問）

```
1. 我的假設是什麼？—把潛在假設說出來
2. 這是「框架缺失」還是「內容缺少」？
   - 框架壞了（黑畫面）→ 先修框架
   - 框架正常但內容空 → 直接填內容
   - 未來可能需要 → 等需要時再加（驗證驅動）
3. 這是「最小代碼」嗎？不是就簡化
不要假設框架缺東西，先驗證再動手
```

### 二、Skill 觸發（CC 限定）

```
規劃 SOP：載入 karpathy-guidelines skill
Debug：先走 /systematic-debugging，找到根因才提修復方案
Debug 完成：症狀、根因、修法寫入 docs/SOP/Debug_Log.md
```

### 三、「R 幾 DONE」三步驟

使用者宣告「R 幾 DONE」時依序執行：

```
1. docs/SOP/R?：...md 更新
   - outline 表格與內文 ### 小標雙處同步加 ✅（雙標規則）
2. docs/SOP/（先讀大綱.md 更新階段狀態
3. CC 專屬：同步更新 memory 的 handover
4. git commit + push（目前分支，R3 時為 r3-light）
```

### 四、SOP 打勾雙標規則

階段完工：outline 表格列 + 內文 `### ` 小標兩處都加 ✅。
階段降級（如幻覺事件）：兩處同時撤除 ✅。
僅改一處會造成狀態模糊。

### 五、驗收網址格式

回覆需要使用者驗收時：

```
網址：http://localhost:9001/Home_Studio.html?v=<fix-後綴當 changelog>
query 有變：不必提重整
query 未變：附「Cmd+Shift+R 硬重載」於次行（分行，勿串句）
```

### 六、R3 階段 × OMC 工具對照

動手前依階段性質選用對應工具，勿全程套同一 skill：

```
R3-0  抽離魔數 weight * 1.5
      單檔、單處常數改 uniform
      → 直接動工，勿套 skill

R3-1  光通量 lm → radiance 換算層
R3-2  色溫 K → RGB 換算
      數學函式、有標準公式、邊界敏感
      → /oh-my-claudecode:ralplan 事前取共識
         （Planner+Architect+Critic 三角互審）

R3-3  Cloud 漫射燈條接真光源
R3-4  軌道投射燈 spot cone NEE
R3-5  Many-Light Sampling + MIS（最高難度）
      shader+JS 雙線改、erichlof 框架踩雷多
      → /ralplan 先出計畫 → /ultrawork 執行
         R3-5 若反覆翻車可改 /ralph 持續循環

R3-6  indirectMul 校準歸一
      數值調參、肉眼驗收
      → Claude Code 直接動手、每次給對照圖

R3-7  採購評估驗收（4 情境切換）
      非編碼、使用者親自測
      → Claude Code 僅負責修 bug
```

注意：`/team` 不適用 R3。各階段有依賴鏈（單位換算 → 光源 → MIS），併行不安全。`/team` 適合大量獨立檔案重構。

通用任務選用規則另見全域 CLAUDE.md「任務 × OMC 工具選用提醒」。

---

## 文件邊界（避免重複）

| 需要什麼 | 去哪查 |
|---------|--------|
| R 階段當前進度 | `docs/SOP/（先讀大綱.md` |
| 通用 Debug 紀律 + fix 紀錄 | `docs/SOP/Debug_Log.md` |
| 某 R 階段工作手冊 | `docs/SOP/R?：...md` |
| R2 實作細節 / 踩雷 / 規格 | CC memory `project_home_studio_r2_13_handover.md` |
| 燈具產品規格 | `docs/R3_燈具產品規格.md` |
| 房間 2D 俯視圖 | `docs/Home Studio 2D俯視圖 SVG.md` |
| 跨階段規則 / 流程 | 本文件 |

本文件**不寫**：R 階段細節、cache-buster 字串、commit hash 清單、技術規格。
這些資訊會過期；過期資訊比沒有資訊更危險。
