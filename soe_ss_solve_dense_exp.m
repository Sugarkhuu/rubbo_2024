function [W,C,EX1,EX2,EX3,PH,PC,P1,P2,P3,MC1,MC2,MC3,Y1,Y2,Y3,L1,L2,L3,Ltot,CH,CF] = soe_ss_solve_dense_exp(ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33,OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX1,KAPEX2,KAPEX3,GAMMA,VARPHI,MU)
% Wrapper around soe_ss_resid_dense_exp + fzero, mirroring
% soe_ss_solve_dense.m's role but for the sector-specific export model
% (TASK #2, FULL VERSION). Called with a single unbroken line from the
% .mod file's steady_state_model block (Dynare's lexer does not accept
% "@(...)" anonymous functions or "..." line continuation there).
f = @(WW) soe_ss_resid_dense_exp(WW, ALPHA1,ALPHA2,ALPHA3, OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, OF1,OF2,OF3, BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX1,KAPEX2,KAPEX3,GAMMA,VARPHI,MU);
W = fzero(f, [0.05, 5]);
[~, ss] = soe_ss_resid_dense_exp(W, ALPHA1,ALPHA2,ALPHA3, OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, OF1,OF2,OF3, BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX1,KAPEX2,KAPEX3,GAMMA,VARPHI,MU);
C = ss.C; EX1 = ss.EX1; EX2 = ss.EX2; EX3 = ss.EX3; PH = ss.PH; PC = ss.PC;
P1 = ss.P1; P2 = ss.P2; P3 = ss.P3;
MC1 = ss.MC1; MC2 = ss.MC2; MC3 = ss.MC3;
Y1 = ss.Y1; Y2 = ss.Y2; Y3 = ss.Y3;
L1 = ss.L1; L2 = ss.L2; L3 = ss.L3; Ltot = ss.Ltot;
CH = ss.CH; CF = ss.CF;
end
