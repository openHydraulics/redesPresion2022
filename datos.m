# Datos que definen la red a estudiar
# Red con 8 nudos
# Cada nudo representa una agrupación de bocas, desde el que se regarían 100 ha

z0=135; % z0 cota del origen del agua
D=transpose([0.5 0.35 0.3 0.25 0.2 0.3 0.25 0.2]); % diámetros de los tramos
L=transpose([1000 1000 1000 1000 1000 1000 1000 1000]); % longitudes de los tramos
k=transpose([4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5]); % aspereza de arena equivalente del material de los tubos de los tramos
nu=1.3e-6; % viscosidad cinemática

# Caudales q y altura de presión h requeridos en cada nodo (boca o hidrante)
GradoLibertad = 24/12;
hreq=transpose([35 35 35 35 35 35 35 35]);

# Coordenadas de los nudos
x=transpose([1000 1000 2000 3000 1000 2000 3000 2000]); % abcisas de los nudos
y=transpose([0 -1000 -1000 -1000 -2000 0 0 1000]); % ordenadas de los nudos
z=transpose([128 134 127 126 137 127 124 122]); % cotas de de los nudos
%z=z+5*randn(size(z)); % componente aleatoria en la cota

# Vector 1 al número de bocas
vectorBocas=(1:1:numel(z))';

# Matriz de tramos
# La fila i contiene los nudos de aguas arriba y aguas abajo del tramo i.
tramos=[0 1 2 3 2 1 6 6];
tramos=[tramos;1:numel(vectorBocas)]';

# Representación tramos red
figure()
plot([0 x(tramos(1,2))], [0 y(tramos(1,2))],'k')
hold on
for i=2:vectorBocas(end) % Tramos restantes
  plot([x(tramos(i,1)) x(tramos(i,2))], [y(tramos(i,1)) y(tramos(i,2))],'k')
endfor

plot(x,y,'ko') % representación nudos red
plot(0,0, 'b*') % representación nudo origen
text([0;x]+25,[0;y]+50,num2str([0;vectorBocas]))
text([0;x],[0;y]-50,num2str([z0;z]))
xlabel('x(m)')
ylabel('y(m)')

# Curvas de nivel
x=[0;x]; y=[0;y]; z=[z0;z];
X=min(x)-500:100:max(x)+500;
Y=min(y)-500:100:max(y)+500;
[X,Y]=meshgrid(X,Y);
Z=griddata(x,y,z,X,Y);
dimZ=size(Z);
Zvector=reshape(Z,dimZ(1)*dimZ(2),1);
equidCN=5;
rangoZ=floor(min(Zvector)/10)*10-equidCN:equidCN:ceil(max(Zvector))+equidCN;
contour(X,Y,Z,rangoZ,'k')
axis([min(x) max(x) min(y) max(y)]);
hold off

# Se crea la matriz de conexiones
caminos=zeros(numel(vectorBocas),numel(vectorBocas));
Mconex_hf=caminos;

for i=1:numel(vectorBocas)
  j=1;
  elementoInic=i;
  caminos(i,j)=elementoInic;
  Mconex_hf(i,elementoInic)=1;
  while elementoInic>0
    j=j+1;
    caminos(i,j)=tramos(elementoInic,1);
    elementoInic=caminos(i,j);
    if elementoInic>0
      Mconex_hf(i,elementoInic)=1;
    endif
  endwhile
  
endfor

# Matriz para el cálculo de los caudales de los tramos
Mconex_Q=transpose(Mconex_hf);