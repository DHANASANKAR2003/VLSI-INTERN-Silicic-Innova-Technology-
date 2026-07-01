# report_generator.py
# Generates a premium, clean, interactive HTML validation report.

import datetime

class ReportGenerator:
    def __init__(self, test_results):
        self.test_results = test_results
        self.timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def generate_html(self, filepath: str):
        passed_tests = sum(1 for t in self.test_results if t['status'] == 'PASSED')
        total_tests = len(self.test_results)
        failed_tests = total_tests - passed_tests
        
        status_text = "REGRESSION PASSED" if failed_tests == 0 else "REGRESSION FAILED"
        status_class = "badge-passed" if failed_tests == 0 else "badge-failed"
        
        # Build test items HTML
        test_items_html = []
        for i, t in enumerate(self.test_results):
            tc_num = f"TC-0{i+1}"
            status_pill = "pass" if t['status'] == 'PASSED' else "fail"
            
            item_html = f"""
            <div class="test-item">
                <div class="test-header">
                    <span class="test-tc">{tc_num}</span>
                    <div class="test-title-desc">
                        <span class="test-title">{t['name']}</span>
                        <span class="test-desc">{t['description']}</span>
                    </div>
                    <div><span class="status-pill {status_pill}">{t['status']}</span></div>
                    <span class="test-duration">{t['duration']:.3f}s</span>
                </div>
                <div class="test-notes">
                    <strong>Audit Notes:</strong> {t['notes']}
                </div>
            </div>
            """
            test_items_html.append(item_html)
            
        test_items_html_str = "\n".join(test_items_html)

        # HTML Template with f-string escape brace syntax
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>8-Bit Adder/Subtractor Validation Report</title>
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600&family=Inter:wght@400;500;600;700&family=Outfit:wght@500;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {{
            --bg-color: #080b11;
            --card-bg: rgba(17, 24, 39, 0.7);
            --card-border: rgba(255, 255, 255, 0.08);
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --accent-blue: #3b82f6;
            --accent-blue-glow: rgba(59, 130, 246, 0.2);
            --accent-green: #10b981;
            --accent-green-glow: rgba(16, 185, 129, 0.2);
            --accent-red: #ef4444;
            --font-family: 'Inter', sans-serif;
            --font-display: 'Outfit', sans-serif;
            --font-mono: 'Fira Code', monospace;
        }}

        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}

        body {{
            font-family: var(--font-family);
            background-color: var(--bg-color);
            background-image: 
                radial-gradient(at 0% 0%, rgba(59, 130, 246, 0.08) 0px, transparent 50%),
                radial-gradient(at 100% 0%, rgba(139, 92, 246, 0.08) 0px, transparent 50%);
            background-attachment: fixed;
            color: var(--text-primary);
            padding: 40px 20px;
            min-height: 100vh;
        }}

        .container {{
            max-width: 1000px;
            margin: 0 auto;
        }}

        header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 35px;
            border-bottom: 1px solid var(--card-border);
            padding-bottom: 20px;
        }}

        .title-area h1 {{
            font-family: var(--font-display);
            font-size: 2rem;
            font-weight: 800;
            background: linear-gradient(135deg, #ffffff 40%, var(--accent-blue) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 6px;
        }}

        .badge-passed {{
            background-color: var(--accent-green-glow);
            color: var(--accent-green);
            border: 1px solid var(--accent-green);
            padding: 6px 16px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 0.9rem;
            font-family: var(--font-display);
        }}

        .badge-failed {{
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--accent-red);
            border: 1px solid var(--accent-red);
            padding: 6px 16px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 0.9rem;
            font-family: var(--font-display);
        }}

        /* Board Visualizer styles */
        .board-visualizer {{
            background: #0d2c1d; /* Dark green PCB */
            border: 3px solid #144a30;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: inset 0 0 20px rgba(0,0,0,0.6), 0 10px 30px rgba(0,0,0,0.3);
            background-image: 
                radial-gradient(rgba(20, 80, 50, 0.25) 1px, transparent 0),
                radial-gradient(rgba(20, 80, 50, 0.25) 1px, transparent 0);
            background-size: 20px 20px;
            background-position: 0 0, 10px 10px;
        }}

        .board-title {{
            font-family: var(--font-display);
            color: #4ade80;
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            border-bottom: 1px solid rgba(74, 222, 128, 0.2);
            padding-bottom: 8px;
            margin-bottom: 16px;
        }}

        .board-grid {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }}

        @media (max-width: 768px) {{
            .board-grid {{
                grid-template-columns: 1fr;
            }}
        }}

        .board-section {{
            background: rgba(0, 0, 0, 0.25);
            padding: 16px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.03);
        }}

        .section-title {{
            font-size: 0.78rem;
            color: #86efac;
            margin-bottom: 12px;
            font-weight: 600;
        }}

        .interactive-row {{
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            align-items: center;
        }}

        .input-box {{
            background: #1e293b;
            border: 1px solid var(--card-border);
            color: #fff;
            padding: 6px 12px;
            border-radius: 4px;
            width: 80px;
            font-family: var(--font-mono);
            font-size: 0.85rem;
        }}

        /* Visual LEDs */
        .led-row {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(0,0,0,0.20);
            padding: 12px 10px;
            border-radius: 6px;
        }}

        .switch-container {{
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            flex: 1;
        }}

        .board-led {{
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: #1e293b;
            border: 2px solid #334155;
            transition: all 0.15s ease;
        }}

        .board-led.led-active {{
            background: #ef4444; /* Glowing Red */
            border-color: #f87171;
            box-shadow: 0 0 12px #ef4444;
        }}

        .board-led.carry-active {{
            background: #f59e0b; /* Amber for carry */
            border-color: #fbbf24;
            box-shadow: 0 0 12px #f59e0b;
        }}

        .switch-label {{
            font-family: var(--font-mono);
            font-size: 0.65rem;
            color: #86efac;
        }}

        /* Slide Switch styling */
        .switch-toggle {{
            position: relative;
            display: inline-block;
            width: 20px;
            height: 34px;
        }}

        .switch-toggle input {{
            opacity: 0;
            width: 0;
            height: 0;
        }}

        .slider-track {{
            position: absolute;
            cursor: pointer;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: #334155;
            transition: .2s;
            border-radius: 4px;
            border: 1px solid #475569;
        }}

        .slider-track:before {{
            position: absolute;
            content: "";
            height: 12px;
            width: 16px;
            left: 1px;
            bottom: 2px;
            background-color: #cbd5e1;
            transition: .2s;
            border-radius: 2px;
        }}

        input:checked + .slider-track {{
            background-color: #10b981;
        }}

        input:checked + .slider-track:before {{
            transform: translateY(-16px);
            background-color: #f8fafc;
        }}

        /* Test items */
        .test-list {{
            display: flex;
            flex-direction: column;
            gap: 16px;
        }}

        .test-item {{
            background: rgba(30, 41, 59, 0.2);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            overflow: hidden;
            backdrop-filter: blur(12px);
        }}

        .test-header {{
            display: grid;
            grid-template-columns: 80px 1fr 100px 80px;
            align-items: center;
            padding: 16px 20px;
            border-bottom: 1px solid var(--card-border);
        }}

        .test-tc {{
            font-family: var(--font-mono);
            font-weight: 700;
            color: var(--accent-blue);
        }}

        .test-title {{
            font-weight: 600;
            font-family: var(--font-display);
            display: block;
        }}

        .test-desc {{
            font-size: 0.85rem;
            color: var(--text-secondary);
        }}

        .status-pill {{
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 700;
            font-family: var(--font-display);
            text-transform: uppercase;
        }}

        .status-pill.pass {{
            background: rgba(16, 185, 129, 0.15);
            color: var(--accent-green);
        }}

        .status-pill.fail {{
            background: rgba(239, 68, 68, 0.15);
            color: var(--accent-red);
        }}

        .test-duration {{
            font-family: var(--font-mono);
            font-size: 0.85rem;
            color: var(--text-secondary);
            text-align: right;
        }}

        .test-notes {{
            background: rgba(0,0,0,0.15);
            padding: 12px 20px;
            font-size: 0.85rem;
            color: var(--text-secondary);
            border-top: 1px solid rgba(255,255,255,0.02);
        }}
    </style>
</head>
<body>
<div class="container">
    <header>
        <div class="title-area">
            <h1>8-Bit Adder/Subtractor Validation Report</h1>
            <p style="color: var(--text-secondary); font-size: 0.9rem;">Executed: {self.timestamp}</p>
        </div>
        <div>
            <span class="{status_class}">{status_text}</span>
        </div>
    </header>

    <!-- FPGA Board Visualizer Panel -->
    <div class="board-visualizer">
        <div class="board-title">EDGE Artix-7 board visualizer (Interactive math widget)</div>
        <div class="board-grid">
            <!-- Inputs -->
            <div class="board-section">
                <div class="section-title">Inputs (OP_A, OP_B, CTRL)</div>
                <div class="interactive-row">
                    <span>Operand A (0-255):</span>
                    <input type="number" id="val-a" class="input-box" value="120" min="0" max="255" oninput="calculateMath()">
                </div>
                <div class="interactive-row">
                    <span>Operand B (0-255):</span>
                    <input type="number" id="val-b" class="input-box" value="30" min="0" max="255" oninput="calculateMath()">
                </div>
                <div class="interactive-row">
                    <span>Mode Switch (CTRL):</span>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="font-size: 0.75rem; color: var(--text-secondary);">ADD</span>
                        <label class="switch-toggle">
                            <input type="checkbox" id="ctrl-sub" onchange="calculateMath()">
                            <span class="slider-track"></span>
                        </label>
                        <span style="font-size: 0.75rem; color: var(--text-secondary);">SUB</span>
                    </div>
                </div>
            </div>

            <!-- LEDs Output -->
            <div class="board-section">
                <div class="section-title">Outputs (LEDs sum/diff & carry/borrow)</div>
                <div class="led-row" style="margin-bottom: 12px;">
                    <div class="switch-container">
                        <div class="board-led" id="led-carry"></div>
                        <span class="switch-label" id="carry-lbl">CARRY</span>
                    </div>
                </div>
                <div class="led-row">
                    <div class="switch-container"><div class="board-led" id="led-7"></div><span class="switch-label">L7</span></div>
                    <div class="switch-container"><div class="board-led" id="led-6"></div><span class="switch-label">L6</span></div>
                    <div class="switch-container"><div class="board-led" id="led-5"></div><span class="switch-label">L5</span></div>
                    <div class="switch-container"><div class="board-led" id="led-4"></div><span class="switch-label">L4</span></div>
                    <div class="switch-container"><div class="board-led" id="led-3"></div><span class="switch-label">L3</span></div>
                    <div class="switch-container"><div class="board-led" id="led-2"></div><span class="switch-label">L2</span></div>
                    <div class="switch-container"><div class="board-led" id="led-1"></div><span class="switch-label">L1</span></div>
                    <div class="switch-container"><div class="board-led" id="led-0"></div><span class="switch-label">L0</span></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Test List -->
    <h2 style="font-family: var(--font-display); font-size: 1.2rem; margin-bottom: 15px;">Validation Test Logs</h2>
    <div class="test-list">
        {test_items_html_str}
    </div>
</div>

<script>
    function calculateMath() {{
        const a = parseInt(document.getElementById('val-a').value) || 0;
        const b = parseInt(document.getElementById('val-b').value) || 0;
        const sub = document.getElementById('ctrl-sub').checked;
        
        let sumDiff = 0;
        let carryBorrow = 0;
        
        if (!sub) {{
            // Addition
            const res = a + b;
            sumDiff = res & 0xFF;
            carryBorrow = res > 255 ? 1 : 0;
            document.getElementById('carry-lbl').textContent = 'CARRY';
        }} else {{
            // Subtraction
            const res = a - b;
            sumDiff = res & 0xFF;
            carryBorrow = a < b ? 1 : 0;
            document.getElementById('carry-lbl').textContent = 'BORROW';
        }}
        
        // Update LEDs
        for (let i = 0; i < 8; i++) {{
            const bit = (sumDiff >> i) & 1;
            const led = document.getElementById(`led-${{i}}`);
            if (led) {{
                if (bit === 1) led.classList.add('led-active');
                else led.classList.remove('led-active');
            }}
        }}
        
        // Update Carry/Borrow LED
        const cLed = document.getElementById('led-carry');
        if (cLed) {{
            if (carryBorrow === 1) cLed.classList.add('carry-active');
            else cLed.classList.remove('carry-active');
        }}
    }}
    
    // Initial Run
    calculateMath();
</script>
</body>
</html>
"""
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
