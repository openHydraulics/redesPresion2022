# Generación con características aleatorias de la demanda de las aprox. 8640 h anuales
%{
  Datos necesarios:
  - Necesidades hídricas mensuales de varios cultivos y su proporción.
  - Superficie a regar desde cada boca (o hidrante) de la red.
  - Valor de la relación Ra/(1-Cd), que es igual a la relación Hr/Hb entre las láminas requerida y bruta.
  - Número de horas diarias en las que es posible realizar la operación de riego.
%}

%Se establece el valor semilla de la funcion de generacion de numeros pseudoaleatorios rand(), para que sea aleatoria.
rand('state',sum(100*clock))

## Fase 1: Determinación dotación de caudal en cada boca

cultivos=["Cereal de primavera";"Maiz dulce";"Fresa";"Puerro temprano";"Puerro mediano";"Puerro tardio";"patata media estacion";"Patata tardia";"Zanahoria temprana";"Zanahoria mediana 1";"Zanahoria mediana 2";"Cebolla temprana";"Cebolla tardia";"Remolacha mesa temprana";"Remolacha mesa tardia";"Otras horticolas"];

# Necesidades hidrícas mensuales (en columnas ene, feb,...) de los cultivos (en filas Cereal de primavera, Maíz dulce,...) expresadas en mm/dia.
Hr= [
0.00	0.00	0.00	0.63	3.06	5.54	2.59	0.00	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	1.75	5.54	3.12	0.00	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.58	1.75	5.63	7.95	6.68	2.53	0.00	0.00	0.00;...
0.00	0.00	0.33	1.79	3.19	5.26	4.56	0.00	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	1.85	5.17	6.33	5.22	1.46	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	0.00	2.29	5.83	5.39	3.47	0.01	0.00	0.00;...
0.00	0.00	0.00	0.08	0.92	4.32	6.65	5.21	0.85	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	0.35	2.64	5.16	5.58	3.68	0.11	0.00	0.00;...
0.00	0.00	0.43	1.49	3.19	5.26	2.67	0.00	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.58	1.75	4.66	6.13	5.39	3.11	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	0.91	3.40	5.56	5.39	3.47	0.22	0.00	0.00;...
0.00	0.00	0.33	1.79	3.19	5.27	5.87	0.88	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	1.17	4.84	6.33	5.38	3.18	0.00	0.00	0.00;...
0.00	0.00	0.00	0.21	2.69	5.27	2.69	0.00	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	0.06	3.45	6.32	4.55	0.00	0.00	0.00	0.00;...
0.00	0.00	0.00	0.00	1.12	4.10	6.28	5.38	0.85	0.00	0.00	0.00];

# Distribución de cultivos
distCult=[0.05;0.1;0.03;0.1;0.03;0.04;0.04;0.05;0.03;0.04;0.04;0.04;0.04;0.06;0.06;0.25];

# Superficie a regar desde cada boca (ha)
S=[16; 16; 16; 16; 16; 16; 16; 16];

# Relación Ra/(1-Cd)
rend=0.9;

# Tiempo operación estación bombeo por meses
HorasRiego = 16; % Número horas diarias para riego
tfunc=HorasRiego*ones(8,6); % Se asume mismo número de horas para todos los meses

%Caudal ficticio continuo (L/s)
necRiego=sum(distCult.*Hr,1)./rend;%Necesidades de riego (mm/dia) mediante ponderación según la distribución de cultivos por meses
qfc=transpose(max(transpose(S*necRiego.*(1e4/24/3600/rend))));%Caudal ficticio continuo (L/s) necesario en cada boca

# Caudal asignado a cada boca (dotación) en L/s
GL=[3; 3; 3; 3; 3; 3; 3; 3]; % Grado de Libertad de cada boca (relación entre el caudal asignado y el estrictamente necesario)
% A las bocas que abastecen superficies pequeñas se les suele incrementar el Grado de Libertad
qboca=24/HorasRiego*qfc.*GL;

## Fase 2: Simulación de la demanda

planillaRiego=zeros(numel(S),24);
q=planillaRiego;
diaAgno=0;

# Tiempo necesario (h) para suministrar la demanda por meses
triego=necRiego.*S./qboca.*1e4./3600;
triego(isnan(triego))=0;%Se pone valor cero donde qboca es igual a cero
duracRiego=ceil(triego);

for k=1:12%Meses del año
  
  for j=1:30%Días del mes

    diaAgno=diaAgno+1;
    planillaRiego=zeros(numel(S),24);
    
    horaComienzo=floor(rand(numel(S),12).*(tfunc(k)-triego(:,k)));%Se determina aleatoriamente la hora de comienzo del riego en cada boca y día del año
    
    for i=1:numel(S)%Boca de riego
            
      if necRiego(k)~=0 
        %planillaRiego(i,(1+horaComienzo(i,k)):(1+(horaComienzo(i,k)+duracRiego(i,k))))=1;
        planillaRiego(i,(1+horaComienzo(i,k)):(horaComienzo(i,k)+duracRiego(i,k)))=1;
      endif
      
    endfor
    
    %Matriz de caudal (L/s) demandado (boca,hora,diaAño)
    q(:,:,diaAgno)=planillaRiego.*qboca;

  endfor

endfor

Q=sum(q,1);
distQ=reshape(Q,1,[]);%Vector distribución caudales horarios de 12 meses y 30 dias por mes.

figure()
plot(distQ)
hold on
plot(sort(distQ))
xlabel('hora del año')
ylabel('Q(L/s)')
axis([0 8640 0 max(distQ)])
hold off

caudales=reshape(q,numel(S),[]);

%Se guardan los caudales demandados de las bocas durante las aproximadamente 8640 horas de un año
save('cauddemandbocas.m','caudales','-append')