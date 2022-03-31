# Cálculo de la pendiente motriz en tubos segun White-Colebrook

% Q = caudal
% D = diámetro
% I = pendiente motriz
% k = aspereza de arena equivalente
% nu = viscosidad cinemática

%Q, D y k pueden ser vectores con el mismo numero de elementos
% La función admite valores de Q negativos, cuyo significado es que el flujo se produciría en sentido contrario. Las pérdidas de carga tendrían también sentido contrario y serían por tanto negativas.

function I=IWC(Q,D,k,nu)
    %Si Q es nulo, I también lo es
    I=1e-1.*(abs(Q)>0);
    Ia=2.*I;
  while sum(abs(I-Ia)>1e-6)>0
    Ia=I;
    I=(4.*abs(Q)./pi./D.^2./(-2.*log10(k./3.7./D+2.51.*nu./D./sqrt(2.*9.80665.*abs(Ia).*D)))).^2./2./9.80665./D.*(abs(Q)./Q);
  endwhile
  I(isnan(I))=0;%Las divisiones por Ia=0 dan el error NaN
endfunction