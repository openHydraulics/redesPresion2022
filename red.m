# Cálculo y análisis de una red de distribución

close all; clear; clc

# Enlace a funciones (relativas a Q, D, I, k y nu) en carperta ./src/
addpath('./src/');

# Se cargan los datos de la red
datos;

# Se genera, con características aleatorias, una demanda anual por horas (24 x 30 x 12 = 8640 h)
gen_demanda;

## Se analizan las necesidades energéticas de la red y su eficiencia

#Variables para almacenar los resultados de cada simulación
resultado=[];
indicadores=[];
distBocas=[];

#Se cargan los caudales demandados desde las bocas

%load cauddemandbocas.m caudales; No hace falta, puesto que se ejecuta "gen_demanda.m" (ver arriba)

numsim=size(caudales,2);
numbocas=size(caudales,1);

iterQbombeomax=0;
Qbombeomax=0;

H_nodonec=hreq+z; % Altura piezométrica necesaria en cada boca (o hidrante)

for i=1:numsim
  %Caudal de cada tramo (tubería)
  
  qdemand=caudales(:,i).*1e-3; % Conversión de L/s a m3/s.
  
  if sum(qdemand)>0 % Sólo se aborda el cálculo si hay demanda desde alguna boca

    Q=Mconex_Q*qdemand; % Caudales de los tramos
    
    Qbombeo=max(Q); % Caudal a elevar por el bombeo
    
    if Qbombeo>Qbombeomax % Se registra el bombeo máximo y el momento en el que se produce
      iterQbombeomax=i;
      Qbombeomax=Qbombeo;
    endif

    %Pérdida de carga en cada tramo
    hf=IWC(Q,D,k,nu).*L;
    %hf=0*hf; % Para evaluar cuanto influyen las pérdidas de carga
    
    %Carga necesaria en cabeza para satisfacer a cada nodo
    Hcabnec=H_nodonec+Mconex_hf*hf-z0; % Altura piezométrica en nodo mas las pérdidas de carga menos la cota en origen
    
# Altura de elevación mínima. Determinada por aquella boca que más energía requiere en cada situación
    Hbombeo=max(Hcabnec); % Altura a elevar por el bombeo
    
# Altura de elevación fija, en vez de dependiente de las bocas en uso
    %(Eliminar este comentario para fijar la altura de elevación)%Hbombeo=65;
    %Sugerencia a realizar: fijar un valor fijo para "Hbombeo" y analizarlo mediante indicadores.
    %Esto enlaza con el tema siguiente sobre bombeos.
    %De todas formas, se hace en el caso del análisis de la red mallada.
    
    
    %Carga en cada nodo una vez establecida la altura de elevación del bombeo
    H_nodo=z0+Hbombeo-Mconex_hf*hf;
    
# Indicadores
    # Indicador rendimiento energético
    % Potencia útil en las bocas con presión suficiente en relación a la potencia del bombeo
    rendEnerg=sum(qdemand.*hreq.*((H_nodo-z)>hreq))/(Hbombeo*Qbombeo);
    # Coeficiente déficit energético
    % Potencia entregada "no aprovechable" en relación a la potencia requerida
    coefDef=sum(qdemand.*(H_nodo-z).*((H_nodo-z)<hreq))/sum(qdemand.*hreq);
  
    resultado=[resultado;Qbombeo Hbombeo vectorBocas'*(Hcabnec==max(Hcabnec))];
    
    % Almacenamiento indicadores
    indicadores=[indicadores; Qbombeo rendEnerg coefDef];
  endif 

endfor


figure()
subplot(1,3,1)
plot(resultado(:,1),resultado(:,2),'+')
axis([0 max(resultado(:,1)) 0 max(resultado(:,2))])
xlabel('Q'); ylabel('H bombeo')
hold on
plot([0 max(resultado(:,1))],[min(resultado(:,2)) min(resultado(:,2))])
hold off

% Distribución de bocas que determinan la altura en cabeza
for i=1:numbocas
  distBocas=[distBocas sum(resultado(:,3)==i)];
endfor
distBocas=distBocas./sum(distBocas);
subplot(1,3,2)
bar(distBocas)
xlabel('boca condiciona');ylabel('frecuencia')

subplot(1,3,3)
plot(indicadores(:,1),indicadores(:,2),'+')
axis([0 max(indicadores(:,1)) 0 max(indicadores(:,2))])
xlabel('Q'); ylabel('rend. Energético')
hold on
plot(indicadores(:,1),indicadores(:,3),'+')
hold off