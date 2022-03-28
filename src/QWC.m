# Cálculo del caudal en tubos segun White-Colebrook

% Q = caudal
% D = diámetro
% I = pendiente motriz
% k = aspereza de arena equivalente
% nu = viscosidad cinemática

%I, D y k pueden ser vectores con el mismo numero de elementos

function Q=QWC(I,D,k,nu)
  Q=pi.*D.^2./4.*sqrt(2*9.80665.*I.*D).*(-2*log10(k/3.7./D+2.51*nu./D./sqrt(2*9.80665*I.*D)));
endfunction