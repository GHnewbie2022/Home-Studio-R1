# R3-1 光通量 → Radiance 單位換算層 — Ralplan 共識計畫

- 產出日期：2026-04-19
- 分支：`r3-light`（基線 commit `e1a4c9e`，R3-0 完工凍結）
- cache-buster：`r3-1-lumens-uniform-pipeline`
- 驗收網址：http://localhost:9001/Home_Studio.html?v=r3-1-lumens-uniform-pipeline
- 共識狀態：Planner ✅ / Architect ✅ / Critic ✅ APPROVE（條件：§4 已補 `fullBeamAngleDeg` 語義註記）
- 本計畫屬「管線純施工」：所有 emission 值皆寫 0，畫面須與 R3-0 在 Cam 1/2/3 × ≥500 spp 像素級一致

---

## 1. 目標與邊界

### 1.1 本階段做什麼

建立 R3 系列真光源所需的光度學計算管線，但**不接任何發光邏輯**。

A. JS 端新增三支換算函式 + 一支光視效能查表。
B. Shader 端新增三組 emission 陣列 uniform + 一支 DCE-proof gate。
C. GUI 端凍結 `brightness` / `colorTemp` 兩個 slider，改唯讀顯示（R3-6 才重新校準）。

### 1.2 本階段不做什麼（嚴禁逾越）

- 不改 `uLightEmission`（吸頂燈、R2-18 校準定案值保留）。
- 不改 `uLegacyGain`（R3-0 產物，R3-5 歸一前維持 1.5）。
- 不在任何 hitType 分支寫入新發光邏輯（`CLOUD_LIGHT` emission 留 R3-3、`TRACK` 留 R3-4）。
- 不改 NEE/MIS 採樣（留 R3-5）。
- 不動 `uIndirectMultiplier`（留 R3-6）。

### 1.3 驗收門檻（不得降級）

- Cam 1（正面）、Cam 2（側後）、Cam 3（俯視）× 每機位 ≥ 500 spp。
- 與 R3-0 基線（cache-buster `r3-0-legacy-gain-uniform`）**像素級一致**。
- WebGL 主控台 `0 errors / 0 warnings`。
- Console 檢查：`typeof lumenToCandela === 'function'` 等四支函式皆存在。

---

## 2. Principles（本計畫指導原則）

1. **框架優先、內容留白**：本階段只建管線，任何換算結果都不得寫入畫面。
2. **物件語義命名**：uniform / 函式名須表達「物件是什麼」（`uCloudEmission` / `uTrackEmission`），禁用位置或階段別名。
3. **驗證驅動**：每寫一支函式即在 Console 驗 ≥ 3 個已知數值點，pass 後才進下一支。
4. **零視覺副作用**：emission=0 + gate=0 的雙重保險，確保 Critic 可以 diff 像素驗證。
5. **R3-3/4/5 易承接**：uniform 槽位、陣列長度、索引對映須與燈具產品規格 1:1 匹配。

## 3. Decision Drivers（關鍵決策驅動）

1. **erichlof NEE 框架限制**：shader 端 uniform 若宣告卻未用會被 GLSL DCE 掉，之後 R3-3 再補會觸發重新編譯；故必須以 runtime-valued gate 把全部陣列接到 `accumCol`。
2. **Lambertian π 因子**：直接寫 `cd / A` 是錯的（少了 π），若此刻把值寫進 uniform 會污染 R3-3 繼承；故 R3-1 一律吐 0。
3. **使用者肉眼驗收習慣**：Cam 1/2/3 × 500 spp 是既有紀律，計畫須可執行「R3-0 / R3-1 同機位對照」測試。

## 4. Viable Options（已審視的替代方案）

| 方案 | 描述 | 採用 | 否決理由 |
|------|------|------|----------|
| A. 本計畫 | JS 算、shader 備 uniform、gate=0、emission=0 | ✅ | 同時滿足「零視覺副作用」與「R3-3 即插即用」 |
| B. 純 JS 先行 | 只做 JS 函式，shader uniform 留 R3-3 | ❌ | R3-3 時 uniform 新增 → shader 重編譯引發 erichlof framework state reset，違反增量原則 |
| C. 一次做完 R3-1+R3-3 | 連同 Cloud 真光源一起接 | ❌ | 違反 Debug_Log 紀律「小步提交、單變更驗證」；R3-5 MIS 前 emission 值無法校準 |

---

## 5. 檔案異動清單

| 檔案 | 異動範圍 | 行為改變 |
|------|----------|----------|
| `js/Home_Studio.js` | §6 函式 × 4、uniform 宣告 × 3 群、`computeLightEmissions()` 呼叫點 × 2、GUI 凍結 × 2、HTML cache-buster × 1 | 管線就緒、畫面不變 |
| `shaders/Home_Studio_Fragment.glsl` | 新增 `uCloudEmission[4]` / `uTrackEmission[4]` / `uTrackWideEmission[2]` / `uR3EmissionGate` 四條宣告 + `CalculateRadiance()` sink 五行 | uniform 存在、sink 值恆為 vec3(0) |
| `Home_Studio.html` | `Home_Studio.js?v=r3-1-lumens-uniform-pipeline` | cache 破 |
| `docs/SOP/R3：燈光系統.md` | R3-1 章節後加 ✅、outline 表格同步 | SOP 雙標同步 |
| `docs/SOP/（先讀大綱.md` | 階段狀態欄更新 | 大綱同步 |

---

## 6. 實作步驟（依序，每步驗證 pass 才進下一步）

### Step 0：R3-0 基線取樣

1. `git checkout r3-light`（已在）、`git status` 須 clean。
2. 啟動 `python3 -m http.server 9001`。
3. 以 `?v=r3-0-legacy-gain-uniform` 開 Home_Studio.html。
4. Cam 1/2/3 各跑 500 spp，Snapshot → Capture 三張存 `docs/R3-1_basis/` 以供後續 diff。

### Step 1：新增四支 JS 函式

插入點 `js/Home_Studio.js` 約 line 360 附近（`colorTemperature` 變數附近）。

```javascript
/**
 * Luminous flux (lm) + FULL beam angle (deg, 邊到邊全錐角) → peak axial candela.
 *
 * 警示：第二參數為「全錐角」，非半角。
 * 內部自除 2：sr = 2π(1 - cos(fullBeamAngleDeg/2 · π/180))。
 * 若改為半角語義，§6.a 斷言三組期望值（2375.90 / 37206.86 / 636.62）必須整組重算。
 * 舊專案 Path Tracking 260412a 5.4 Clarity.html:1752 原型（同全錐角語義）。
 */
function lumenToCandela(lm, fullBeamAngleDeg) {
    const halfDeg = Math.max(0.01, fullBeamAngleDeg / 2);   // 避免 0° 奇異點
    const halfRad = halfDeg * Math.PI / 180;
    return lm / (2 * Math.PI * (1 - Math.cos(halfRad)));
}

/**
 * Candela + emitter surface area (m²) → radiance proxy (cd/m²).
 * 注意：此為**中繼量**，R3-3/4 時須再乘以 (1/π) 補 Lambertian 因子，否則過亮 3.14×。
 * 本階段 R3-1 不直接使用，留予 R3-3/4 承接。
 */
function candelaToRadiance(cd, emitterAreaM2) {
    if (!Number.isFinite(cd)) return 0;
    const A = Math.max(emitterAreaM2, 1e-8);                // 防除以 0/NaN
    return cd / A;
}

/**
 * Luminous flux (lm) + color temperature (K) → electrical watts proxy.
 * 採查表 K(T) lm/W；R3-5 MIS 歸一時若需 radiant flux 可再乘 683 轉 W。
 */
function lumensToWatts(lm, kelvin) {
    return lm / kelvinToLuminousEfficacy(kelvin);
}

/**
 * Luminous efficacy K(T) lm/W，階梯式 LUT。
 * 資料來源：CIE 15:2004 Table T.3 / Philips LED 商品 spec 平均值。
 */
function kelvinToLuminousEfficacy(kelvin) {
    if (kelvin <= 2700) return 280;
    if (kelvin <= 3000) return 300;
    if (kelvin <= 4000) return 320;
    if (kelvin <= 5000) return 330;
    if (kelvin <= 6500) return 340;
    return 350;
}
```

### Step 1 驗證（Console 斷言）

| 輸入 | 期望輸出 | 容差 |
|------|----------|------|
| `lumenToCandela(2000, 60)` | `2375.8973` cd | ±0.01 |
| `lumenToCandela(2000, 15)` | `37206.8648` cd | ±0.01 |
| `lumenToCandela(2000, 120)` | `636.6198` cd | ±0.01 |
| `candelaToRadiance(1000, 0.002827)` | `353734.70` | ±0.1 |
| `candelaToRadiance(1000, 0)` | `1e11` 級（不 NaN） | 有限值 |
| `candelaToRadiance(NaN, 0.01)` | `0` | 嚴格相等 |
| `lumensToWatts(2000, 4000)` | `6.25` W | ±0.001 |
| `kelvinToLuminousEfficacy(2700)` | `280` | 嚴格相等 |
| `kelvinToLuminousEfficacy(10000)` | `350` | 嚴格相等 |

### Step 2：`pathTracingUniforms` 新增陣列

在 `js/Home_Studio.js` `uLegacyGain` 宣告（line 803）下方追加：

```javascript
// ---- R3-1 emission pipeline (values stay zero this phase) ----
pathTracingUniforms.uCloudEmission      = { value: [new THREE.Vector3(), new THREE.Vector3(), new THREE.Vector3(), new THREE.Vector3()] };
pathTracingUniforms.uTrackEmission      = { value: [new THREE.Vector3(), new THREE.Vector3(), new THREE.Vector3(), new THREE.Vector3()] };
pathTracingUniforms.uTrackWideEmission  = { value: [new THREE.Vector3(), new THREE.Vector3()] };
pathTracingUniforms.uR3EmissionGate     = { value: 0.0 };   // runtime 0，防 GLSL DCE
```

### Step 3：`computeLightEmissions()` 填零骨架

於 `updateVariablesAndUniforms` 同檔作用域新增：

```javascript
function computeLightEmissions() {
    // R3-1: pipeline only — R3-3/4/5 will fill real values.
    for (let i = 0; i < 4; i++) {
        pathTracingUniforms.uCloudEmission[i].value.set(0, 0, 0);
        pathTracingUniforms.uTrackEmission[i].value.set(0, 0, 0);
    }
    for (let i = 0; i < 2; i++) {
        pathTracingUniforms.uTrackWideEmission[i].value.set(0, 0, 0);
    }
}
```

呼叫點：`init()` 尾段一次、`applyPanelConfig()` 尾段一次（為 R3-3 dirty-flag 預留鉤點）。

### Step 4：Shader uniform + sink

`shaders/Home_Studio_Fragment.glsl` 第 75 行 `uLegacyGain` 宣告下方追加：

```glsl
uniform vec3 uCloudEmission[4];
uniform vec3 uTrackEmission[4];
uniform vec3 uTrackWideEmission[2];
uniform float uR3EmissionGate;   // runtime 0，防止 GLSL DCE 把 emission uniform 移除
```

於 `CalculateRadiance(...)` 函式（line 674）`return accumCol;` 之前插入：

```glsl
// R3-1 DCE-proof sink: gate=0 時 r3Sink=vec3(0)，畫面不變；
// R3-3/4/5 將 uR3EmissionGate 改為 1 並填 emission 值即可點亮。
vec3 r3Sink = uR3EmissionGate * (
    uCloudEmission[0] + uCloudEmission[1] + uCloudEmission[2] + uCloudEmission[3] +
    uTrackEmission[0] + uTrackEmission[1] + uTrackEmission[2] + uTrackEmission[3] +
    uTrackWideEmission[0] + uTrackWideEmission[1]
);
accumCol += r3Sink;
```

### Step 5：GUI slider 凍結

`js/Home_Studio.js` line 971 附近（brightness / colorTemp controller）追加 `.disable().name('brightness (R3-6 校準)')` 與 `colorTemp (R3-6 校準)`；既有 onChange 邏輯保留，但因 slider 禁用，值永凍於 R2-18 校準定案值（900 / 4000）。

### Step 6：HTML cache-buster

`Home_Studio.html` `<script src="js/Home_Studio.js?v=...">` 的 query 改為 `r3-1-lumens-uniform-pipeline`。

### Step 7：驗收 3×500 spp

三機位逐一跑，Snapshot Capture，與 Step 0 基線 diff。**任一機位像素差即 rollback 至 Step 6 前**。

---

## 7. 風險登錄

| # | 風險 | 機率 | 影響 | 緩解 |
|---|------|------|------|------|
| R01 | GLSL DCE 把 emission uniform 移除，R3-3 再接時重編譯抖動 | 高 | 中 | `uR3EmissionGate` runtime-valued gate + sink 加總強制使用 |
| R02 | `emitterArea=0` 使 candela→radiance 爆 Infinity 污染 uniform | 中 | 高 | `Math.max(A, 1e-8)` + `Number.isFinite` 雙防線 |
| R03 | 使用者誤以為 `lumenToCandela` 吃半角 → 全場亮度 3.73× 偏差 | 低 | 極高 | §4 docstring 明示 full beam angle、參數命名 `fullBeamAngleDeg`、§6.a 三組期望值皆以全錐角計算 |
| R04 | `cd/A` 被 R3-3 工程師當作終值使用（缺 π） | 中 | 高 | `candelaToRadiance` docstring 警告「中繼量、R3-3 須再乘 1/π」 |
| R05 | GUI slider 雖 disable 但外部仍改 `brightness` 變數 | 低 | 中 | `onChange` 保留但 slider 禁用、值固定；R3-6 才重開 |
| R06 | 光視效能查表精度不足（階梯式） | 低 | 低 | R3-1 階段用不到該值；R3-5 需要時改平滑插值，風險後移 |
| R07 | 陣列 uniform 超過 WebGL2 最小 224 vec4 限制 | 極低 | 高 | 本階段共 10 vec3 + 1 float ≈ 11 slot；仍遠低於上限 |
| R08 | `Home_Studio.html` cache-buster 改動與 `InitCommon.js` 無 query 造成使用者看到舊材質 | 中 | 低 | 驗收提示若 query 有變則免重整；若 query 未變才附 Cmd+Shift+R |
| R09 | pathTracingUniforms 陣列存成 JS array of Vector3，three.js 若偵測到長度變化會重 compile | 低 | 中 | 初始化即配足最終長度 (4/4/2)，後續只 `.set()` 不 reassign |
| R10 | GLSL 編譯器優化把 `0.0 * expr` 折掉 | 中 | 高 | gate 為 runtime uniform、非 literal `0.0`，編譯期無法折 |
| R11 | `computeLightEmissions` 寫零在每幀呼叫會空轉 | 低 | 極低 | 掛於 init + applyPanelConfig，不入每幀；R3-3 改 dirty-flag |
| R12 | SOP R3-1 範例數值（candela≈2388）已知為誤，若工程師照抄會以為函式 bug | 中 | 中 | 本計畫 §6.a 已改為正確值 2375.8973；待 R3-1 DONE 一併修 SOP |
| R13 | R3-3/4 工程師忘記把 `uR3EmissionGate` 改 1 → 畫面仍黑 | 中 | 中 | 本計畫尾段交接備忘列入、R3-3 SOP 第一步即改 gate=1 |

---

## 8. 共識過程記錄（Planner → Architect → Critic 閉環）

### 8.1 Planner 初稿重點

- 提出四支 JS 函式、三群 uniform、GUI 凍結、cache-buster 步驟。
- sink 位置誤寫於 `pc_fragColor`（PathTracingCommon.js:3339 scope，不在本 fragment 檔可達範圍）。
- `candelaToRadiance` 預先填入三組計算值（含 Lambertian π 誤差）。
- 無 `Math.max` 防線，`emitterArea=0` 未處理。

### 8.2 Architect 反駁與綜合

- **Blocking #1**：sink 注入點 `pc_fragColor` 錯誤，必須改為 `CalculateRadiance()` 內 `accumCol += r3Sink` before return。
- **Blocking #2**：`cd/A` 硬值缺 π、缺 hemispherical 2×、缺單面積分攤，會污染 R3-3 繼承。唯一安全作法是本階段 emission 全寫 0。
- **Blocking #3**：`emitterArea=0/NaN` 無守，Infinity 寫入 uniform 為 WebGL UB。`Math.max(A, 1e-8)` + `Number.isFinite` 必備。
- **綜合**：採「runtime gate + 全 0 emission + sink 恆為 vec3(0)」三重保險，確保 R3-1 像素級零副作用，同時 uniform 槽位預留給 R3-3/4/5。

### 8.3 Critic 第一輪（ITERATE — 7 defects）

1. §6.a 期望值 `candela ≈ 2388` 抄自 SOP 錯值，實為 `2375.8973`。
2. 15° / 120° beam 期望值缺失，須補 `37206.8648` / `636.6198`。
3. Step 0 基線取樣未寫入（R3-0 diff 無從比對）。
4. R10 DCE 折除 `0.0 * expr` 風險未列。
5. R12 SOP 數值錯誤未標註。
6. R13 `uR3EmissionGate` 預設值交接備忘未註。
7. `candelaToRadiance` docstring 未標註「中繼量、缺 π」。

→ 本計畫已逐項修正（§6.a 三組期望值經 Node.js 驗算、§7 R10/R12/R13 已補、§6.a docstring 已警示）。

### 8.4 Critic 第二輪（ITERATE — 1 blocking ambiguity）

> §4 `lumenToCandela` 函式參數命名與 docstring 必須明示「full beam angle」語義（邊到邊全錐角）。若實作者誤以為半角，§6.a 三組斷言整組偏 3.73×。補簽名註記即可 APPROVE。

→ 已在 §6 Step 1 註解內明示「第二參數為全錐角、非半角」，參數改名 `fullBeamAngleDeg`，並附警告「若改半角語義則三組期望值須重算」。

### 8.5 Critic 第三輪（APPROVE，條件式）

語義歧義消除後，Critic 同意 APPROVE。本計畫為最終共識版本。

---

## 9. ADR（架構決策紀錄）

- **Decision**：R3-1 僅建管線，所有換算值回 0；shader 以 runtime-valued gate 持有 uniform。
- **Drivers**：erichlof DCE、Lambertian π 正確性、肉眼零副作用驗收紀律。
- **Alternatives considered**：見 §4 方案 B / C。
- **Why chosen**：同時兼顧「即插即用」「可逆」「可像素級 diff」三要件，R3-3/4/5 只需改 gate 與填值即可點亮。
- **Consequences**：本階段無視覺改變，使用者驗收仰賴 Console function 存在性 + Cam 1/2/3 × 500 spp pixel diff。
- **Follow-ups**：R3-3 第一步 `uR3EmissionGate=1` + 填 `uCloudEmission[0..3]`；R3-6 重新啟用 brightness / colorTemp slider；SOP `candela ≈ 2388` 於 R3-1 DONE 一併修正。

---

## 10. 完工交付（R3-1 DONE 後須做）

1. `docs/SOP/R3：燈光系統.md` R3-1 章節內文 `### ` 標與 outline 表雙處加 ✅（雙標規則）。
2. `docs/SOP/（先讀大綱.md` 階段狀態欄同步。
3. SOP R3-1 example `candela ≈ 2388` 改為 `2375.90`（帶 4 位有效數）。
4. `memory/project_home_studio_r2_13_handover.md` R3 進度行新增 `R3-1 ✅ lumens→radiance 管線、emission uniform 陣列備妥、gate=0 未點燈`。
5. `git add -A && git commit`，message 樣式：
   ```
   R3-1: lumens→radiance 換算層 + emission uniform 管線（gate=0 未點燈）
   ```
6. `git push origin r3-light`。

---

## 11. 執行工具建議

依 `docs/AI交接必讀.md` § 六對照表，R3-1 屬「數學函式、有標準公式、邊界敏感」類，本計畫既已取得共識，下階段執行建議：

- 預設：`/oh-my-claudecode:ultrawork` — shader + JS 雙線改、步驟 7 步需串連、每步驗算。
- 次選：`/oh-my-claudecode:team 2:executor` — JS 函式 + shader uniform 可獨立推進，惟 HTML cache-buster 為匯合點。
- 非推薦：`/oh-my-claudecode:ralph` — 本階段有明確終點，ralph 循環過頭。

**本計畫已共識通過，等候使用者核可執行路徑，勿擅自進入 ultrawork。**
