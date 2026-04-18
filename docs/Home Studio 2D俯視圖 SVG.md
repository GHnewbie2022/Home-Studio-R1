<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home Studio 聲學佈局俯視圖</title>
    <style>
        body {
            margin: 0;
            padding: 40px 20px;
            background-color: #f0f2f5;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
            font-family: sans-serif;
        }
        .canvas-container {
            background-color: #ffffff;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border-radius: 12px;
            padding: 40px;
            width: 100%;
            max-width: 900px;
            box-sizing: border-box;
        }
        svg {
            width: 100%;
            height: auto;
            display: block;
        }
        .instruction {
            text-align: center;
            color: #555;
            margin-bottom: 20px;
            font-size: 14px;
        }
        /* 樣式參數區 */
        .wall { fill: none; stroke: #333; stroke-width: 6; }
        .window { stroke: #7f8c8d; stroke-width: 8; stroke-linecap: square; }
        .door-arc { fill: rgba(0,0,0,0.05); stroke: #666; stroke-dasharray: 4; stroke-width: 1.5; }
        .door-panel { stroke: #e67e22; stroke-width: 4; }
        .speaker { fill: #2c3e50; stroke: #1a252f; stroke-width: 2; }
        .subwoofer { fill: #34495e; stroke: #2c3e50; stroke-width: 2; }
        .desk { fill: rgba(149, 165, 166, 0.3); stroke: #7f8c8d; stroke-width: 2; }
        .bass-trap { fill: #3498db; stroke: #3498db; stroke-width: 0; }
        .air-gap { fill: none; stroke: #3498db; stroke-dasharray: 2; stroke-width: 1.5; }
        .triangle-line { fill: none; stroke: #27ae60; stroke-dasharray: 6; stroke-width: 1.5; }
        .axis-line { fill: none; stroke: #bdc3c7; stroke-dasharray: 4; stroke-width: 1; }
        .dimension { font-family: sans-serif; font-size: 11px; fill: #555; }
        .label { font-family: sans-serif; font-size: 13px; fill: #222; font-weight: bold; }
        .small-label { font-family: sans-serif; font-size: 10px; fill: #555; text-anchor: middle; }
        
        /* 反射相關參數 - 洋紅色 (#e91e63) */
        .reflection-x { stroke: #e91e63; stroke-width: 2.0; stroke-linecap: round; } 
        .reflection-path { fill: none; stroke: #e91e63; stroke-dasharray: 1 1; stroke-width: 0.6; opacity: 0.7; }
        .bisector { fill: none; stroke: #e91e63; stroke-dasharray: 3 2; stroke-width: 0.5; opacity: 0.6; }
        
        /* 超細斜體希臘字母參數控制區 */
        .greek-path { 
            fill: none; 
            stroke: #e91e63; 
            stroke-width: 0.4; 
            /* 修正象限反轉後的傾斜角 */
            transform: skewX(15deg); 
            transform-origin: center;
        }
    </style>
</head>
<body>

<div class="canvas-container">
    <div class="instruction">
        【提示】你可以使用瀏覽器的縮放功能，或在觸控板上使用雙指縮放，來查看精確的座標與動線細節。
    </div>

    <svg xmlns="http://www.w3.org/2000/svg" viewBox="-271 -267.3 542 680" width="100%" height="100%">
      <defs>
        <marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
          <path d="M 0 2 L 10 5 L 0 8 z" fill="#555" />
        </marker>
        <symbol id="theta-icon" viewBox="0 0 10 10">
            <ellipse cx="5" cy="5" rx="3" ry="4.5" class="greek-path" />
            <line x1="2" y1="5" x2="8" y2="5" class="greek-path" />
        </symbol>
        <symbol id="phi-icon" viewBox="0 0 10 10">
            <circle cx="5" cy="5" r="3.5" class="greek-path" />
            <line x1="5" y1="1" x2="5" y2="9" class="greek-path" />
        </symbol>
      </defs>

      <g id="Cartesian-Root" transform="scale(1, -1)">

          <pattern id="grid" width="50" height="50" patternUnits="userSpaceOnUse">
            <path d="M 50 0 L 0 0 0 50" fill="none" stroke="#f0f0f0" stroke-width="1"/>
          </pattern>
          <rect x="-271" y="-412.7" width="542" height="680" fill="url(#grid)" />

          <line x1="0" y1="187.3" x2="0" y2="-305.7" class="axis-line" />

          <!-- KH 750 Subwoofer (移至東南方，繪製於家具之前以置於後景) -->
          <g class="subwoofer-group">
            <rect x="79" y="-265.7" width="33" height="38.3" rx="2" class="subwoofer" />
            <rect x="85.5" y="-265.7" width="20" height="4" fill="#7f8c8d" /> 
            <text transform="translate(131, -249) scale(1, -1)" class="small-label">KH750</text>
          </g>

          <!-- 東北角衣櫃 (不設定透明度，維持實體顏色) -->
          <rect x="135" y="70.3" width="56" height="117" fill="#f4e4d4" stroke="#b8977e" stroke-width="2" />
          <text transform="translate(163, 128.8) scale(1, -1)" font-family="sans-serif" font-size="12" fill="#8b7355" text-anchor="middle" font-weight="bold">Closet</text>

          <!-- 南牆家具：嵌牆木桌與書櫃 (設定 fill-opacity="0.6" 變為半透明) -->
          <rect x="-191" y="-305.7" width="293" height="67.2" fill="#f4e4d4" fill-opacity="0.6" stroke="#b8977e" stroke-width="2" />
          <text transform="translate(-44.5, -275) scale(1, -1)" font-family="sans-serif" font-size="12" fill="#8b7355" text-anchor="middle" font-weight="bold">Built-in Desk</text>
          
          <rect x="102" y="-305.7" width="76" height="32.7" fill="#f4e4d4" fill-opacity="0.6" stroke="#b8977e" stroke-width="2" />
          <text transform="translate(140, -293) scale(1, -1)" font-family="sans-serif" font-size="11" fill="#8b7355" text-anchor="middle" font-weight="bold">Bookcase</text>

          <!-- Room Outline (覆蓋在木頭上方) -->
          <rect x="-191" y="-305.7" width="382" height="493" class="wall" />
          
          <!-- 東南角柱子 -->
          <rect x="178" y="-305.7" width="13" height="56.7" fill="#333" stroke-width="0" />

          <!-- South Wall Window (最前層) -->
          <line x1="-173" y1="-305.7" x2="71" y2="-305.7" class="window" />
          <text transform="translate(0, -337.7) scale(1, -1)" class="label" text-anchor="middle">South Wall (Soundproof Window)</text>
          <text transform="translate(0, 207.3) scale(1, -1)" class="label" text-anchor="middle">North Solid Wall</text>

          <path d="M -73 187.3 A 79 79 0 0 0 -152 108.3 L -152 187.3 Z" class="door-arc" />
          <line x1="-152" y1="187.3" x2="-152" y2="108.3" class="door-panel" />
          <text transform="translate(-154, 96.3) scale(1, -1)" class="dimension">Door Sweep (79cm)</text>

          <g class="bass-trap-group">
            <line x1="-30" y1="177.025" x2="30" y2="177.025" class="air-gap" />
            <rect x="-30" y="157.8" width="60" height="11.8" class="bass-trap" />
            <text transform="translate(0, 143.05) scale(1, -1)" class="dimension" fill="#c0392b" text-anchor="middle">GIK 244 + Gap</text>
          </g>

          <g class="bass-trap-group">
            <line x1="-180.725" y1="-21.2" x2="-180.725" y2="-81.2" class="air-gap" />
            <rect x="-173.3" y="-79.8" width="11.8" height="60" class="bass-trap" />
            <text transform="translate(-149.15, -51.2) scale(1, -1) rotate(-90)" class="dimension" fill="#c0392b" text-anchor="middle">GIK 244 + Gap</text>
          </g>

          <g class="bass-trap-group">
            <line x1="180.75" y1="-21.2" x2="180.75" y2="-81.2" class="air-gap" />
            <rect x="161.7" y="-79.8" width="11.8" height="60" class="bass-trap" />
            <text transform="translate(146.45, -51.2) scale(1, -1) rotate(90)" x="2.85" class="dimension" fill="#c0392b" text-anchor="middle">GIK 244 + Gap</text>
          </g>

          <rect x="-60" y="-69.7" width="120" height="54" rx="4" class="desk" />
          <text transform="translate(0, -47.7) scale(1, -1)" class="label" text-anchor="middle">Desk</text>
          <text transform="translate(0, -65.2) scale(1, -1)" class="dimension" text-anchor="middle">120 x 54 cm</text>
          
          <line x1="82" y1="-271" x2="82" y2="-300" stroke="#27ae60" stroke-width="1.5" marker-start="url(#arrow)" marker-end="url(#arrow)" />
          <text transform="translate(40, -288) scale(1, -1)" class="dimension" fill="#27ae60" text-anchor="start">40 cm</text>

          <line x1="95.5" y1="-200" x2="95.5" y2="-300.7" stroke="#27ae60" stroke-dasharray="4" stroke-width="1" />
          <line x1="99" y1="-200" x2="184" y2="-200" stroke="#27ae60" stroke-width="1.5" marker-start="url(#arrow)" marker-end="url(#arrow)" />
          <text transform="translate(143.25, -195) scale(1, -1)" class="dimension" fill="#27ae60" text-anchor="middle">1/4 Width</text>

          <g transform="translate(-50, -86.6) rotate(-30)">
            <rect x="-11.25" y="-27.3" width="22.5" height="27.3" rx="2" class="speaker" />
            <rect x="-5.625" y="-4" width="11.25" height="4" fill="#7f8c8d" />
          </g>
          <text transform="translate(-41, -127.7) scale(1, -1)" class="dimension" text-anchor="end">KH150</text>

          <g transform="translate(50, -86.6) rotate(30)">
            <rect x="-11.25" y="-27.3" width="22.5" height="27.3" rx="2" class="speaker" />
            <rect x="-5.625" y="-4" width="11.25" height="4" fill="#7f8c8d" />
          </g>
          <text transform="translate(41, -127.7) scale(1, -1)" class="dimension" text-anchor="start">KH150</text>

          <circle cx="0" cy="0" r="8" fill="#f39c12" stroke="#e67e22" stroke-width="2" />
          <text transform="translate(17, 15.3) scale(1, -1)" class="label">Listener</text>
          <text transform="translate(17, 2.3) scale(1, -1)" class="dimension">(0,0)</text>
          <text transform="translate(17, -10.7) scale(1, -1)" class="dimension">(38% Rule)</text>

          <line x1="0" y1="0" x2="-50" y2="-86.6" class="triangle-line" />
          <line x1="0" y1="0" x2="50" y2="-86.6" class="triangle-line" />
          <line x1="-50" y1="-86.6" x2="50" y2="-86.6" class="triangle-line" />
          <text transform="translate(0, -81.7) scale(1, -1)" class="dimension" text-anchor="middle" fill="#27ae60">100 cm</text>
          
          <g class="reflection-path">
            <polyline points="-50,-86.6 -161.5,-51.2 0,0" />
            <polyline points="50,-86.6 161.7,-51.2 0,0" />
            <polyline points="-50,-86.6 -19.6,157.8 0,0" />
            <polyline points="50,-86.6 19.6,157.8 0,0" />
          </g>

          <g class="bisector">
            <line x1="-161.5" y1="-51.2" x2="-121" y2="-51.2" />
            <line x1="161.7" y1="-51.2" x2="124" y2="-51.2" />
            <line x1="-19.6" y1="157.8" x2="-19.6" y2="97.3" />
            <line x1="19.6" y1="157.8" x2="19.6" y2="97.3" />
          </g>

          <g class="reflection-x">
            <line x1="-28" y1="-40.3" x2="-22" y2="-46.3" />
            <line x1="-22" y1="-40.3" x2="-28" y2="-46.3" />
            <line x1="22" y1="-40.3" x2="28" y2="-46.3" />
            <line x1="28" y1="-40.3" x2="22" y2="-46.3" />
            <line x1="-164.5" y1="-48.2" x2="-158.5" y2="-54.2" />
            <line x1="-158.5" y1="-48.2" x2="-164.5" y2="-54.2" />
            <use href="#theta-icon" x="-136" y="-49.7" width="6" height="6" />
            <use href="#theta-icon" x="-136" y="-58.7" width="6" height="6" />
            <line x1="158.7" y1="-48.2" x2="164.7" y2="-54.2" />
            <line x1="164.7" y1="-48.2" x2="158.7" y2="-54.2" />
            <use href="#theta-icon" x="129" y="-49.7" width="6" height="6" />
            <use href="#theta-icon" x="129" y="-58.7" width="6" height="6" />
            <line x1="-22.6" y1="160.8" x2="-16.6" y2="154.8" />
            <line x1="-16.6" y1="160.8" x2="-22.6" y2="154.8" />
            <use href="#phi-icon" x="-25.6" y="112.3" width="6" height="6" />
            <use href="#phi-icon" x="-19.6" y="112.3" width="6" height="6" />
            <line x1="16.6" y1="160.8" x2="22.6" y2="154.8" />
            <line x1="22.6" y1="160.8" x2="16.6" y2="154.8" />
            <use href="#phi-icon" x="13.6" y="112.3" width="6" height="6" />
            <use href="#phi-icon" x="19.6" y="112.3" width="6" height="6" />
          </g>

          <line x1="-191" y1="227.3" x2="191" y2="227.3" stroke="#555" stroke-width="1" marker-start="url(#arrow)" marker-end="url(#arrow)" />
          <text transform="translate(0, 235.3) scale(1, -1)" class="dimension" text-anchor="middle">382 cm</text>
          
          <line x1="-231" y1="187.3" x2="-231" y2="-305.7" stroke="#555" stroke-width="1" marker-start="url(#arrow)" marker-end="url(#arrow)" />
          <text transform="translate(-239, -59.2) scale(1, -1) rotate(-90)" class="dimension" text-anchor="middle">493 cm</text>

<!-- Compass (指北針) -->
          <g transform="translate(-231, 227.3)">
            <!-- 北向箭頭 (紅色系) -->
            <polygon points="0,12 -4,-2 0,0" fill="#e74c3c" />
            <polygon points="0,12 4,-2 0,0" fill="#c0392b" />
            <!-- 南向箭頭 (灰色系) -->
            <polygon points="0,-12 -4,-2 0,0" fill="#bdc3c7" />
            <polygon points="0,-12 4,-2 0,0" fill="#95a5a6" />
            <!-- 標示文字 N -->
            <text transform="translate(0, 15) scale(1, -1)" font-family="sans-serif" font-size="12" font-weight="bold" fill="#c0392b" text-anchor="middle">N</text>
          </g>

          <g transform="translate(-191, -362.7)">
            <rect x="0" y="-34" width="380" height="34" rx="4" fill="#ffffff" stroke="#3498db" stroke-width="1.0" stroke-dasharray="4 4" />
            <text transform="translate(190, -21) scale(1, -1)" font-family="sans-serif" font-size="10" text-anchor="middle" letter-spacing="0.4">
              <tspan fill="#c0392b" font-weight="bold">Note: </tspan>
              <tspan fill="#c0392b">依 REW 瀑布圖結果決定 GIK 244 擺法（貼牆 vs 離牆空腔=板厚）</tspan>
            </text>
          </g>
          
      </g>
    </svg>
</div>

</body>
</html>