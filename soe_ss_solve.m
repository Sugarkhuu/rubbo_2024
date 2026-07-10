function [W,C,EX,PH,PC,P1,P2,P3,MC1,MC2,MC3,Y1,Y2,Y3,L1,L2,L3,Ltot,CH,CF] = soe_ss_solve(ALPHA1,ALPHA2,ALPHA3,OH21,OH32,OF1,OF2,OF3,BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU)
% Wrapper around soe_ss_resid + fzero, returning plain (non-struct)
% outputs since Dynare's lexer (inside a .mod file's steady_state_model
% block) does not accept "@(...)" anonymous functions, "..." line
% continuation, or struct dot-access -- so all of that lives here in an
% ordinary Matlab file instead, called with a single unbroken line from
% the .mod file.
f = @(WW) soe_ss_resid(WW, ALPHA1,ALPHA2,ALPHA3,OH21,OH32,OF1,OF2,OF3, BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);
W = fzero(f, [0.3, 3]);
[~, ss] = soe_ss_resid(W, ALPHA1,ALPHA2,ALPHA3,OH21,OH32,OF1,OF2,OF3, BH1,BH2,BH3,OMEGA,ETA,THETA_S,KAPEX_SCALE,GAMMA,VARPHI,MU);
C = ss.C; EX = ss.EX; PH = ss.PH; PC = ss.PC;
P1 = ss.P1; P2 = ss.P2; P3 = ss.P3;
MC1 = ss.MC1; MC2 = ss.MC2; MC3 = ss.MC3;
Y1 = ss.Y1; Y2 = ss.Y2; Y3 = ss.Y3;
L1 = ss.L1; L2 = ss.L2; L3 = ss.L3; Ltot = ss.Ltot;
CH = ss.CH; CF = ss.CF;
end
