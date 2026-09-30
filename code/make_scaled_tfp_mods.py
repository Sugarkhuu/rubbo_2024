"""Diversification test: rescale each sectoral TFP shock's sd in the full-resolution .mod files
so that Var(aggregate TFP) = sum_i lam_i^2 sd^2 matches the 3-sector calibration's
(sd_scaled = 0.01*sqrt(HHI_3sec/HHI_full)). If the full-res Float/Managed losses climb back
towards their 3-sector values while Peg (eps_rp-dominated) barely moves, the granular
diversification mechanism explains the 'amplification'."""
import json, re, numpy as np
for c in ['chile','korea','czechia']:
    a=json.load(open(f'data_calibration/{c}_calibration_results.json'))
    b=json.load(open(f'data_calibration/{c}_calibration_full_results.json'))
    ha=(np.array(a['domar_weight'])**2).sum(); hb=(np.array(b['domar_weight'])**2).sum()
    sd=0.01*np.sqrt(ha/hb); print(c,'sd_scaled',sd)
    for r in ['float','managed','peg']:
        t=open(f'oen_full_{c}_{r}.mod').read()
        t=re.sub(r'(var eps_a\d+\s*=\s*)0\.01\^2;', lambda m: f'{m.group(1)}{sd:.8f}^2;', t)
        t=t.replace('graph_format=pdf','nograph')
        open(f'oen_fullscaled_{c}_{r}.mod','w').write(t)
