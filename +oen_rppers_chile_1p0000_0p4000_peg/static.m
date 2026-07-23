function [residual, g1, g2, g3] = static(y, x, params)
    T = NaN(54, 1);
    if nargout <= 1
        residual = oen_rppers_chile_1p0000_0p4000_peg.static_resid(T, y, x, params, true);
    elseif nargout == 2
        [residual, g1] = oen_rppers_chile_1p0000_0p4000_peg.static_resid_g1(T, y, x, params, true);
    elseif nargout == 3
        [residual, g1, g2] = oen_rppers_chile_1p0000_0p4000_peg.static_resid_g1_g2(T, y, x, params, true);
    else
        [residual, g1, g2, g3] = oen_rppers_chile_1p0000_0p4000_peg.static_resid_g1_g2_g3(T, y, x, params, true);
    end
end
