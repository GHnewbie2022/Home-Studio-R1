！！！AI必須全程使用繁體中文進行問答！！！

# 專案背景
你的使用者是台灣音樂製作人（混音/母帶），他在 2026 年用 THREE.js Path Tracing Renderer 做了一個家庭錄音室 3D 可視化專案。

## 現狀 - R2-18 金屬三類驗收通過，非金屬 UI 甜蜜點調整中（2026-04-18）

### GitHub Pages（發布版本）

| 版本 | 網址 |
|------|------|
| R2 開發版 | https://ghnewbie2022.github.io/Home-Studio-R2/Home_Studio.html |

### 本地開發伺服器（測試版本）

| 版本 | 啟動方式 | 網址 |
|------|----------|------|
| R1 開發 | `cd Home-Studio-R1 && python3 -m http.server 9001` | http://localhost:9001/Home_Studio.html |
| R2 開發 | `cd Home-Studio-R2 && python3 -m http.server 9001` | http://localhost:9001/Home_Studio.html |

**本地開發說明：**
- 目前開發階段為 R2，在 `Home-Studio-R2` 目錄執行 `python3 -m http.server 9001`
- 瀏覽 http://localhost:9001/Home_Studio.html
- **交接必做：每次對話開始時，必須先啟動本地伺服器，確認回應 200 OK 後再進行開發工作**
- 當前 cache-buster：`r2-18-fix11-presets`（金屬三類驗收後暫定；非金屬 UI 擴充完成後續遞增）

### 🚨 接手第一步（不得跳過）

1. 必讀 `/Users/eajrockmacmini/Documents/VS Code/My Project/SOP/Debug_Log.md` 開頭「通用 Debug 紀律」
2. 未讀完勿動 code。**R2-14 曾三任翻車皆因跳過此步**
3. 啟動本地伺服器並 curl 或開瀏覽器確認 200 OK
4. 對照本文件「關鍵架構」與 SOP 當前階段節，建立心智模型後再動手

---

**R1 內容：**
- 1個簡單盒子房間 + 1盞吸頂燈
- E = 上升，C = 下降
- 左鍵點擊切換視角控制（pointer lock）
- samples_per_frame 預設 8
- pixel resolution 預設 2.0（2x 解析度）
- lil-gui UI 控制項完整
- 快照功能已就緒

**R2-1 ~ R2-17 累積內容（在 Home-Studio-R2）：**
- 房間邊界常數、16 色常量、牆面 16 個 Box、傢俱 5 件 + 層板 4 個（共 25 個 Box）
- BVH 加速結構（BVH_Acc_Structure_Iterative_Fast_Builder.js），取代 naive for-loop
- Box 資料改為 data-driven：JS 端 `addBox()` → DataTexture → shader BVH 遍歷
- 攝影機 3 preset 按鈕（Cam 1/2/3）+ lockedPreset 鎖定機制
- pixel resolution 降為 1.0（開發期）
- R2-5：北牆木門 + 西牆鐵門 + 窗外景色背板（共 28 個 Box）
- 窗外貼圖（duk.tw/WfvcAv.png）透過 uWinTex uniform + shader type 5 採樣
- 預設載入即 Cam 1 位置、Cam 切換時 FOV 重置
- 攝影機位置/角度 GUI 即時顯示與控制（pos X/Y/Z、pitch、yaw）
- 移動速度從 10 降為 5
- R2-6：KH150 喇叭 + 腳架 8 個旋轉物件（mat4 inverse matrix）+ ISO-PUCK MINI 8 顆圓柱
- KH150 正面/背面貼圖（本地原圖 + canvas 黑底放大裁白邊）透過 u150F/u150B uniform + shader type 6 採樣
- ISO-PUCK 高度 2.4cm，喇叭 Y 中心上移 4mm（底面齊平 PUCK 頂面 0.924m）
- MAX_SAMPLES = 1000：到達後框架跳過 STEP 1/2 渲染，顯示「(休眠)」，防止過曝
- 快照里程碑 [8, 100, 300, 500, 1000]，縮圖 60px + hover 放大預覽 + 存檔按鈕在右上角
- 狀態列簡化為「FOV: xx / Samples: xx」
- 北牆木門貼圖（本地 wood_door.jpeg，shader type 7 純漫反射）+ 西牆鐵門貼圖（本地 iron_door.jpg，shader type 8 金屬光澤反射 roughness 0.3 / metalness 1.0）
- 框架 ScreenOutput_Fragment.glsl 7×7 降噪模糊核心導致所有貼圖模糊：透過 pixelSharpness = 1.0 標記有貼圖表面為 edge pixel，跳過降噪（適用 BACKDROP、SPEAKER、WOOD_DOOR、IRON_DOOR、SUBWOOFER）
- R2-7：KH750 超低音（type 9 SUBWOOFER，33×38.3×38.3cm，靜態 BVH Box）+ 正背面貼圖（本地 kh750_front.jpg / kh750_back.jpg，手動裁切白邊 + prepSpeakerTex 黑底放大 4%）
- R2-8：吸音板三種 config 切換（動態 BVH 重建）+ 本地貼圖 `textures/gik244_grey.jpeg` 與 `textures/gik244_white.jpeg`（type 2）
  - Config 1: 3 灰（東西北各 1）
  - Config 2: 3 灰北 + 3 白東 + 3 白西（9 片）
  - Config 3: Config 2 + 6 白 Cloud（15 片，Cloud 由 R2-16 提供）
  - 注意：舊 SOP 曾誤標「紅色」，實為白色；紅色 GIK 廠商停產已作廢
- R2-9：插座面板 6 個（type 11 OUTLET，以 shader 物理座標程式繪製插孔圖案，無額外幾何）
- R2-10：冷氣 + 通風口（type 1 DIFF，C_WHITE 主體 + C_DARK_VENT 純黑出風口，東南牆角安裝）
- R2-11：中央吸頂燈 + 品質/效能補強 —
  - 吸頂燈：圓柱體外殼（CylinderIntersect 復用 ISO-PUCK 函式）+ Quad Light 圓形遮罩（外接矩形 0.47×0.47m，`dx²+dz² ≤ r²` 判定），`uniform vec3 uLightEmission = kelvinToRGB(colorTemp) × brightness × 0.05764`，brightness 0~4000 預設 800、colorTemp 2700~6500K 預設 4000K
  - bounces UI：`uniform float uMaxBounces`（1~14 預設 4），shader 編譯期上限 14、runtime `if (bounces >= int(uMaxBounces)) break;`
  - Bloom 金字塔（Jorge Jimenez SIGGRAPH 2014，Unreal / Blender Eevee 同款）：7 層 mip (1/2 ~ 1/128)、13-tap Karis average brightpass、13-tap partial average downsample、9-tap tent radius=1 upsample + AdditiveBlending，UI 提供 intensity（預設 0.03）、layers（3~7 預設 7）、debug checkbox
  - samplesPerFrame 預設 1.0（UI 預留，shader 未實作 multi-sample 累加）
  - FPS cap 60（`lastRenderTime` + `FRAME_INTERVAL_MS = 1000/60`，animate 開頭 early-return）
  - 切換 Cam 殘影：切換時整塊 clear `pathTracingRenderTarget` + `screenCopyRenderTarget`（犧牲 1 幀短暫噪點換瞬間消除殘影）
- R2-12：貼圖全本地化 + GIK 側邊 UV 裁切修正 —
  - 9 張貼圖皆改為 `textures/` 本地載入（木門、鐵門、KH150 正背、KH750 正背、GIK 灰/白、窗外景色 `window_scene.png` 1323×690 使用者手工裁切），徹底移除 `duk.tw`、`shop.cyuncai.com` 等外部網域依賴
  - 紅藍 GIK 廠商停產，作廢不實作
  - GIK 吸音板 shader UV：偵測薄軸（11.8cm），側面沿薄軸改取正面貼圖中央細條（寬 ≈ hs_thin/maxFront ≈ 9.8%，UV ∈ [0.451, 0.549]）避免 LOGO 被拉伸至邊面，正面維持 [0,1] 全覆蓋
- R2-13：X-ray 透視剝離 + 一連串伴隨修正（fix12 ~ fix23） —
  - X-ray 雙層 cullable tier：`cullable=0` 永不透（家具），`cullable=1` 薄板貼牆以「內向角近牆面」判（牆板/樑/GIK/插座），`cullable=2` 大型遮擋以「box 中心位於相機同側半空間」判（柱）
  - 新增 uniform：`uCamPos`、`uRoomMin/Max`、`uCullThreshold (0.30)`、`uCullEpsilon (0.01)`、`uXrayEnabled`（UI toggle，預設 ON）
  - fix12：剔除範圍自 primary ray 擴展至 secondary ray，避免地面殘留牆影造成詭異空洞陰影
  - fix19（木門西側暗化色差根因）：`Home_Studio_Fragment.glsl` 行 377 之 `boxIdx` 範圍由 `1..15` 修正為 `0..31`，修正 fix10 地板/天花板重切後索引脫鉤造成 asymmetric 套 `uWallAlbedo`
  - fix20（牆↔牆共邊噪點根因）：結構組（索引 0..31）統一 `hitObjectID = 1`，避免 `fwidth(objectID)` 於共邊誤觸 `pixelSharpness=1` 致 raw noise 永存；牆↔天花板等法線變化邊仍保留銳利
  - fix21/22/23（X-ray 結構體對齊）：東西樑、南北牆、天花板四邊、柱、冷氣本體之 `bmin.z` / `bmax.z` 全數切齊內牆面 Z=-1.874（北）、Z=3.056（南），消除 X-ray 視角下結構體外延與冷氣 12.5cm 卡進南牆之問題
  - `uWallAlbedo` 預設值由 0.8 調整為 0.9
- R2-14：東西側投射燈軌道（commit b0f563c） —
  - Box 8 個：軌道底座 + 支架；4 盞投射燈頭為 shader 圓柱
  - TRACK=13 與 OUTLET=11 material type 分家修軌道底面黑線
  - fixtureGroup=1 獨立 toggle `uTrackLightEnabled`
  - Z-fighting 踩雷：嚴禁 max.y 微降（2.904 等）修黑線，fix03 已驗證無效；fix04（BoxIntersect OUTLET inside-box 拒絕法）亦失敗，Cam 3 876spp 確認後回滾
- R2-15：南北側廣角燈軌道（commit 8d65b5e） —
  - Box 4 個：軌道 + 支架；2 盞廣角燈頭為 shader 矮胖圓柱（r=5cm L=7.2cm 20°）
  - fixtureGroup=2 獨立 toggle `uWideTrackLightEnabled`
  - SOP 原漏寫燈頭，實作時撈舊專案補建（教訓：SOP 新增階段若僅列 Box，需主動比對「軌道 Box + shader Cylinder 燈頭」慣例）
  - 多群 gating 改為排他式 `if (x < bound) return cond`，禁用 cascading `if (x < bound && cond) return true`
- R2-16：Cloud 吸音板 6 片 + DASH 拼縫 + Cloud toggle 聯動吸頂燈 —
  - Box 6 個：3×2 矩陣 180×240cm，每片 60×11.8×120cm；type=10 ACOUSTIC_PANEL、meta=1 白貼 `uGikWhiteTex`、頂面 y=2.787 距天花板 11.8cm 空腔
  - shader DASH 拼縫虛線：ACOUSTIC_PANEL 分支內判 `ctr.y > 2.7 && hitNormal.y < -0.5`；Z 向 4 條（x=±0.9/±0.3）+ X 向 3 條（z=-0.702/+0.498/+1.698），週期 6cm（4cm 實 + 2cm 空），純白 `hitColor=vec3(1.0)` 於 gamma+0.7 衰減**之後**覆寫
  - **Cloud toggle 實作中追加（原 SOP 未列）**：借用 R2-17 預留 fixtureGroup=3，新增 `uCloudPanelEnabled` uniform + GUI 勾選項「Cloud 吸音板 (6片)」
  - **吸頂燈位置聯動**：shader 內燈位改由 `uCeilingLampPos` uniform 驅動；Cloud ON → z=-1.5（越過 R2-15 北軌 z=-1.1，距軌 14.8cm 距北牆 13.9cm）；Cloud OFF → 回中央 z=0.591
  - BASE_BOX_COUNT 65 → 71；cullable=1 比照 R2-8 北牆吸音板頂向剝離
  - 驗收時使用者另詢暗部底噪收斂慢問題，已說明為 Monte Carlo O(1/√N) 正常現象；Cloud ON 後直接光被遮更顯噪，待 R3 多光源 MIS / SVGF / ReSTIR 改善
- R2-17：Cloud 漫射燈條 4 支（emission=0 視覺幾何） —
  - Box 4 個：type=14 `CLOUD_LIGHT`、mat `C_CLOUD_LIGHT=[0.9,0.9,0.9]`；東/西 1.6×1.6×240cm 沿 z、南/北 1768×1.6×1.6cm 沿 x
  - 中心 y=2.795，底 2.787 貼死 Cloud 頂（`uCloudPanelEnabled` 實裝頂面），頂 2.803，距天花板 2.905 餘 10.2cm
  - fixtureGroup=4、獨立 toggle `uCloudLightEnabled`（GUI「Cloud 燈條 (4支)」）；不與 Cloud 板 toggle 聯動
  - cullable=1，X-ray 隨 Cloud 一同被頂向剝離
  - shader `if (hitType == CLOUD_LIGHT)` 獨立分支，行為同純 DIFF（未共享 DIFF 分支，符 Debug_Log 規則一「每型獨立」）
  - BASE_BOX_COUNT 71 → 75
  - **重大踩雷（首次實作回滾）**：原 SOP 表 s=[0.15, 0.05, 2.4] 為舊專案 shader `sampleLightPos` 採樣體積散射範圍，**非**可見幾何；誤抄致首版燈條寬 15cm 過粗。真值取自舊專案 `Path Tracking 260412a 5.4 Clarity.html` line 514-515 type 9 之 s=[0.016, 0.016, 2.4]。詳見 Debug_Log「R2-17｜採樣體積 vs 可見幾何誤植」節
  - **fix02 ghost**：驗收期 Cloud 吸音板 toggle 切換吸頂燈位置 0.591 ↔ -1.5 位移 2m+ 留殘影。於 `cloudPanel` onChange 補 `needClearAccumulation = true`，比照 R2-11 Cam 切換瞬清 render target 機制
  - R3 遺緒：emission=0 非真光源；真光源（lumens 800、WARM/NEUTRAL/COLD 三色溫、朝 Cloud 中心 weight=0 扇型、4-quad MIS）留 R3 統一實作

---

## 關鍵架構（接手必讀）

**addBox 呼叫順序（不得亂）**：結構 0..31 → 家具 32+ → 貼圖物件
**BASE_BOX_COUNT = 75**（base 53 + R2-14 八 + R2-15 四 + R2-16 六 + R2-17 四）
**fixtureGroup gating（排他式，嚴禁 cascading `&&` 寫法）**：

```glsl
if (fixtureGroup < 0.5) return false;
if (fixtureGroup < 1.5) return uTrackLightEnabled < 0.5;      // R2-14 投射燈軌道
if (fixtureGroup < 2.5) return uWideTrackLightEnabled < 0.5;  // R2-15 廣角燈軌道
if (fixtureGroup < 3.5) return uCloudPanelEnabled < 0.5;      // R2-16 Cloud 吸音板
if (fixtureGroup < 4.5) return uCloudLightEnabled < 0.5;      // R2-17 Cloud 漫射燈條
return false;
```

**關鍵檔案**：

```
js/Home_Studio.js                 — addBox + BVH + fixtureGroup + uniform init + GUI
shaders/Home_Studio_Fragment.glsl — isBoxCulled + isFixtureDisabled + SceneIntersect
Home_Studio.html                  — cache-buster script tag
js/InitCommon.js                  — uWallAlbedo 預設 0.9
js/PathTracingCommon.js           — edge detection（共享，勿動）
```

---

## R2-18 進度（2026-04-18）

**Step 1~6 已落地**：DataTexture 5-pixel 擴容、autoAssignMaterial per-type 指派、shader hitRoughness/hitMetalness 全域變數、4 處金屬 gate（DIFF/SPEAKER/SUBWOOFER/IRON_DOOR）。

**金屬三類解耦 ✅ 驗收通過**：
- IRON_DOOR uniforms（預設 0.25 / 0.85）
- C_STAND uniforms（預設 1.3 / 0.5）
- C_STAND_PILLAR uniforms（預設 1.2 / 0.65）
- GUI 分三子資料夾 roughness/metalness 雙 slider + Alt-click reset

**Monte Carlo 機率分支 ✅ 驗收通過**：`if (hitMetalness > 0.5)` 硬閾值全改 `if (rand() < hitMetalness)`，金屬度呈連續 blend。

**非金屬 UI 擴充（進行中）**：牆+傢俱 / 吸音板+Cloud / 軌道 等非金屬類別待暴露 roughness/metalness 控制，供使用者微調甜蜜點。

### R2-18 踩雷彙整

1. **ISO-PUCK 狀態洩漏（fix05-puckleak）**：Step 1 骨架漏寫 CylinderIntersect 4 處命中點之 hitRoughness/hitMetalness，致前一物件 metalness=1.0 污染 PUCK，觸發 Step 4 金屬路徑產生錯位反射。修法：SceneIntersect 入口補預設 + 四處命中點顯式寫入。詳見 Debug_Log「R2-18｜ISO-PUCK 狀態洩漏」。
2. **metalness 硬閾值（fix10-metalrand）**：`if (metalness > 0.5)` 造成 0.5 二元觀感，改 `rand() < metalness` 機率分支後呈連續漸變。詳見 Debug_Log「R2-18｜metalness 硬閾值 → Monte Carlo 機率分支」與 feedback memory `feedback_pathtracing_metal_rand_branch.md`。
3. **cameraFlightSpeed 從 5 降為 3**：便於觀察材質微調甜蜜點。

### 實作參考

- SOP R2-18 節末「實作紀錄（2026-04-18）」— 完整 uniform 列表、資料流、fix 進程
- Debug_Log R2-18 兩節 — 狀態洩漏與硬閾值修法
- `feedback_pathtracing_metal_rand_branch.md` — 機率分支原則（跨 R 階段通用）

---

## R2-14 / R2-15 / R2-16 / R2-17 累積教訓

1. SOP 新增階段若僅列 Box，需主動比對「軌道 Box + shader Cylinder 燈頭」慣例（R2-15）
2. 多群 fixtureGroup gating 用排他式 `if (x < bound) return cond`，禁用 `if (x < bound && cond) return true`（R2-15）
3. Z-fighting 修法：嚴禁 max.y 微降（2.904 等），fix03 已驗證無效（R2-14）
4. BoxIntersect OUTLET inside-box 拒絕法不解決軌道底面黑線（R2-14 fix04 失敗已回滾）
5. SOP 標記「✅」不代表實裝，仍需核對 `Home_Studio.js` 之 `addBox` 是否存在（R2-8-4 幻覺教訓）
6. 「Cam 1~4」一律是誤寫；本專案僅 Cam 1 / 2 / 3
7. SOP 用 `type 2` 代稱吸音板是寫作代號，實 shader `#define ACOUSTIC_PANEL 10`；addBox 實參須傳 10（R2-16）
8. DASH 純白覆寫要置於 `hitColor = pow(rawTexCol, vec3(2.2)) * 0.7;` **之後**，否則會被 gamma+0.7 衰減為灰（R2-16）
9. 光學預估 <1% 遮擋僅算直接光，未計入間接光反射損失；白色 GIK 板 0.7 albedo 仍會把天花板-Cloud 空腔反射光大幅吸收（R2-16 追加 toggle 的根因）
10. 吸頂燈座標若要隨 uniform 聯動，需同步將 shader `ceilingLampQuad` 建構改由 uniform 驅動，不能只改 JS `uCeilingLampPos.value`（R2-16）
11. fixtureGroup 編號決策：R2-16 借用原 R2-17 預留 group=3 控 Cloud 板，R2-17 進場時須改 group=4；新增 group 編號一律排他式 gating
12. **舊專案 `s` 欄非單一語義**（R2-17）：同一份 .html 內可能同時有「可見 box 之 s」與「shader `sampleLightPos` 採樣體積之 s」，後者為軟陰影散射面積，**禁**當幾何尺寸使用。複用舊專案座標前先 grep 實體 boxes/addBox 條目，找到實體才抄 s。此坑與 R2-7「s 為全尺寸需除以 2」同科但不同源
13. **GUI toggle 連動幾何位置需清 accumulation buffer**（R2-17 fix02）：progressive path tracer 的殘影不限於 Cam 切換。任何 onChange callback 若動了「位置/姿態」uniform（非單純 visibility），僅 `wakeRender()` 不足以消殘影，須補 `needClearAccumulation = true` 比照 R2-11 修法。分界：位置/姿態變動 → 強清；純顯隱變動 → 軟收斂

---

## SOP 打勾雙標規則（階段完工）

SOP 檔案採雙層打勾慣例：
- 頂部 outline 表格列加 ✅
- 內文對應 `### R2-X` 小標題亦加 ✅

階段完工即同步打勾，勿僅改一處。反之狀態降級（如 R2-8-4 幻覺事件）亦需雙撤。

---

## 本輪 SOP 修訂摘要（2026-04-18）

- R2-8-4 整段刪除（AI 幻覺，從未實裝）
- R2-16 章節重寫：Cloud 6 片 GIK + DASH + 11.8cm 空腔（替代舊 4 支燈條設定）
- R2-8 顏色配置：DUK 欄移除、紅改白、東西牆位置標示改「近北 / 中 / 近南」（水平排列沿 Z）
- R2-8 總覽：三種 config（1 灰 / 2 灰白 / 3 + Cloud）
- R2-17 驗收條件 Cam 1~4 → Cam 1~3（順手一併修正）
- R2-1 ~ R2-15 內文 `### ` 小標補 ✅（與 outline 雙標同步）
- SOP 備份 backup 5 建立

## R2-16 完工修訂（2026-04-18）

- R2-16 outline 與 `### ` 小標加 ✅（雙標）
- R2-16 幾何表 `type 2` → `type 10 ACOUSTIC_PANEL`（修正 SOP 代號與 shader `#define` 不一致）
- R2-16 DASH GLSL 變數名改回實裝 `ctr / hitNormal / hp / hitColor`，加註須於 gamma+0.7 後覆寫
- R2-16 新增「Cloud toggle + 吸頂燈聯動」小節（實作中追加，原 SOP 未列）
- R2-16 fixtureGroup 節：由「不涉及」改為「借 R2-17 預留 group=3 控 Cloud 板」
- R2-17 節 fixtureGroup 3 → 4，`uCloudLightEnabled` 保留；BASE_BOX_COUNT 起點 71（原 69 誤）→ 完工 75（原 73 誤）
- 狀態列 `R2-1 ~ R2-15 ✅` → `R2-1 ~ R2-16 ✅`
- SOP 備份 backup 6 建立

---

**R1 審查結論：**
- 框架完整，無舊專案污染
- Blue Noise 為框架標準功能，非舊專案帶入
- 65 個 JS 範例檔案為框架自帶，以後 R2~R6 可參考

**Git Commit（Home-Studio-R2）：**
- `HiRes` - pixelRatio 2.0 + samplesPerFrame 8.0
- `d10e452` R2-8 ~ R2-11: 吸音板 / 插座 / 冷氣通風口 / 吸頂燈 + Bloom 金字塔 + bounces UI + FPS cap
- `5c0daac` R2-12: 貼圖全本地化 + GIK 側邊 UV 裁切
- `83d0a10` R2-13: X-ray 透視剝離 + 伴隨修正（fix12 ~ fix23）
- `b0f563c` R2-14: 東西投射燈軌道 + TRACK material type 分家
- `8d65b5e` R2-15: 南北廣角燈軌道 + 廣角燈頭補建（SOP 漏寫撈舊專案）
- `e0f7c93` R2-16: Cloud 吸音板 6 片 + DASH 拼縫虛線 + Cloud toggle 聯動吸頂燈
- `f6f2a26` R2-17: Cloud 漫射燈條 4 支（CLOUD_LIGHT=14，fixtureGroup=4，1.6×1.6cm 細柱，SOP 採樣體積誤植已修正）
- `0a5da96` R2-17 fix02: Cloud 吸音板 toggle 殘影瞬清（needClearAccumulation 比照 R2-11 Cam 切換）

**開發位置：**
- 主開發目錄：`/Users/eajrockmacmini/Documents/VS Code/My Project/Home-Studio-PathTracing-FreeAgentTest`
- R1 deploy 目錄：`/Users/eajrockmacmini/Documents/VS Code/My Project/Home-Studio-R1`
- R2 deploy 目錄：`/Users/eajrockmacmini/Documents/VS Code/My Project/Home-Studio-R2`

**舊專案位置（單一 html）：**
- `/Users/eajrockmacmini/Documents/VS Code/My Project/Home Studio 3D Pace Tracing/Path Tracking 260412a 5.4 Clarity.html`
- 用於撈 Cloud GIK 座標（L506-511）與 DASH shader 邏輯

**相關 feedback / project memory（`/Users/eajrockmacmini/.claude/projects/-Users-eajrockmacmini-Documents-Claude-Code/memory/`）：**
- `feedback_home_studio_r2_14_zfighting_failure.md` — Z-fighting 1mm 下沉法失敗
- `feedback_home_studio_r2_14_fix04_failure.md` — OUTLET inside-box 拒絕法失敗
- `feedback_threejs_euler_ambiguity.md` — rotation 須用 .set() 清三軸
- `feedback_r_done_means_push.md` — R 幾 DONE 即觸發改 SOP → 改交接 → git push
- `feedback_sop_dual_checkmark.md` — SOP outline 與內文 ✅ 雙標規則
- `project_home_studio_r2_13_handover.md` — R2-13/14/15 完工交接（與本檔同步）

---

## 新框架 vs 舊內容（重要，務必區分清楚）

**R1 已使用範例框架完成**，與其他 50 個範例（Cornell_Box、CSG_Museum 等）結構完全一致。

### 使用範例框架（已實現）
- Three.js Path Tracing 渲染管線 ✅
- js/ + shaders/ 的檔案結構 ✅
- lil-gui UI 配置方式 ✅
- 控制邏輯（WASD前後左右/E上升/C下降/滑鼠左鍵啟動或取消視角旋轉控制）✅
- pixel resolution 2.0 + samples per frame 8 ✅

### R2~R6 任務內容簡述，包含但不限於：
- 房間尺寸（長寬高）
- 器材幾何（監聽喇叭、吸音版、燈具本體等）
- 傢俱（桌椅、櫃子等）
- 燈光位置、強度、顏色
- 材質貼圖（喇叭正面背面、木門、鐵門、窗外景色）
- 顏色配置
- 完整 UI 系統與 preset
- 快照與打包功能

**簡單來說，是把舊專案的「資料」填入 R1 的「框架」中。**

---

### SOP 階段導覽（`/Users/eajrockmacmini/Documents/VS Code/My Project/SOP`）
R1：初始框架（已完成）
R2：所有幾何物件（R2-1 ~ R2-17 已完成；R2-18 roughness/metalness 待執行）
R3：燈光系統
R4：UI 控制層
R5：完整功能
R6：BVH 加速（可選）

---

**在開始寫任何代碼之前**，你必須：

1. **先讀懂舊專案**
   - 打開 `/Users/eajrockmacmini/Documents/VS Code/My Project/Home Studio 3D Pace Tracing/Path Tracking 260412a 5.4 Clarity.html`
   - 分析舊專案的房間幾何、燈光、材質、UI 結構
   - 列出所有需要「搬運」的元素

2. **輸出 SOP 報告**
   - 在 SOP 大綱的結構底下，依照使用者要求，給出詳細的 SOP「細則」

3. **制定漸進式匯入計畫**
   - 嚴格按照 SOP 細則執行
   - 每階段完成後必須讓使用者測試確認
   - 使用者表示能在瀏覽器中正常運作才算驗收成功



**在你給出 SOP 報告之前，請勿開始寫任何代碼。**

4. **當使用者說「R 幾 DONE」時，依序執行：**
   - 在上方 SOP 階段導覽中，將該項目標記為（已完成）
   - 同步更新本交接文件的現狀描述（版本、內容摘要等）
   - SOP 檔案內 outline 與內文 `### ` 小標同步加 ✅（雙標規則）
   - 在 `Home-Studio-R2` 目錄執行 git commit 並 push 部署

5. **需要使用者驗收時，回覆最後必須單獨一行給出可點擊的網址**
   - 本地測試：`http://localhost:9001/Home_Studio.html`
   - GitHub Pages：對應版本的 Pages 網址
   - 若瀏覽器快取可能擋住新版 shader 或資源，附帶 cache-busting query string（例如 `?_t=1`）或提醒使用者 Cmd+Shift+R

## 強制 Skill 觸發機制

### 規劃階段（制定 SOP 報告）
- **必須**載入 `karpathy-guidelines` skill
- 指令：`/karpathy-guidelines` 或在 task 中指定

### 除錯階段（遇到 bug / 錯誤 / 非預期行為）
- **必須**先使用 `/systematic-debugging` skill
- 在找到根本原因之前不得直接提出修復方案
- 修復完成後**必須**將症狀、根因、修法寫入 Debug Log：`/Users/eajrockmacmini/Documents/VS Code/My Project/SOP/Debug_Log.md`

### 執行 task 時
- 每個 task 都應載入相關 skill：`load_skills: ["skill-name"]`

---

## K 神思考方式（必須遵循）

在做出任何決定之前，必須先問自己：

1. **我的假設是什麼？** — 把潛在假設說出來
2. **這是「框架缺失」還是「內容缺少」？**
   - 框架缺失（功能壞了、黑畫面）→ 先修框架
   - 框架正常但內容空 → 直接填內容
   - 未來可能需要的功能 → 等需要時再加（驗證驅動）
3. **這是「最小代碼」嗎？** — 不是就直接簡化

**不要假設**框架缺東西，**先驗證**再動手。


使用者補充：
中央吸頂燈已於 R2-11 實裝完成。規格：直徑 47cm（半徑 0.235m）、厚度 4cm、與天花板間隔 3cm，座落於房間正中心（X=0, Z=0.591）。以 `CylinderIntersect` 圓柱體作燈罩 + Quad Light 配圓形遮罩發光，brightness 0~4000（預設 800）、colorTemp 2700~6500K（預設 4000K）經 `uniform vec3 uLightEmission` 驅動。

## R3 遺緒

所有燈頭 emission=0，為視覺幾何非真光源。
多光源 MIS（2 廣角 + 4 投射 + CLOUD 燈條 4-quad）待 R3 統一處理。
