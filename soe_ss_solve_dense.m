function [W,C,EX,PH,PC,P1,P2,P3,MC1,MC2,MC3,Y1,Y2,Y3,L1,L2,L3,Ltot,CH,CF] = soe_ss_solve_dense(ALPHA1,ALPHA2,ALPHA3,OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33,OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU)
% Wrapper around soe_ss_resid_dense + fzero, mirroring soe_ss_solve.m's
% role for the dense-Omega^H model (open_economy_network_chile.mod):
% Dynare's lexer (inside a .mod file's steady_state_model block) does not
% accept "@(...)" anonymous functions, "..." line continuation, or struct
% dot-access, so all of that lives here instead, called with a single
% unbroken line from the .mod file.
f = @(WW) soe_ss_resid_dense(WW, ALPHA1,ALPHA2,ALPHA3, OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, OF1,OF2,OF3, BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);
W = fzero(f, [0.05, 5]);
[~, ss] = soe_ss_resid_dense(W, ALPHA1,ALPHA2,ALPHA3, OH11,OH12,OH13,OH21,OH22,OH23,OH31,OH32,OH33, OF1,OF2,OF3, BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);
C = ss.C; EX = ss.EX; PH = ss.PH; PC = ss.PC;
P1 = ss.P1; P2 = ss.P2; P3 = ss.P3;
MC1 = ss.MC1; MC2 = ss.MC2; MC3 = ss.MC3;
Y1 = ss.Y1; Y2 = ss.Y2; Y3 = ss.Y3;
L1 = ss.L1; L2 = ss.L2; L3 = ss.L3; Ltot = ss.Ltot;
CH = ss.CH; CF = ss.CF;
end
