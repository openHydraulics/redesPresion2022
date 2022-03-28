# Cálculo de la pendiente motriz en tubos segun White-Colebrook

% Q = caudal
% D = diámetro
% I = pendiente motriz
% k = aspereza de arena equivalente
% nu = viscosidad cinemática

%Q, D y k pueden ser vectores con el mismo numero de elementos

function D=DWC(Q,I,k,nu)
    D=sqrt(4*Q./Q./pi);Da=D+0.1;
  while abs(D-Da)>1e-6
    Da=D;
    D=(4*Q/pi./sqrt(2*9.80665.*I)./(-2*log10(k/3.7./Da+2.51*nu./Da./sqrt(2*9.80665*I.*Da)))).^(2/5);
  endwhile
endfunction