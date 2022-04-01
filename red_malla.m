# Cálculo y análisis de una red de distribución mallada

close all; clear; clc

# Enlace a funciones (relativas a Q, D, I, k y nu) en carperta ./src/
addpath('./src/');

# Se cargan los datos de la red
datos;

# Se genera, con características aleatorias, una demanda anual por horas (24 x 30 x 12 = 8640 h)
gen_demanda;

## Se analizan las necesidades energéticas de la red y su eficiencia

%Constante suavizado convergencia solución
cte=100;

#Variables para almacenar los resultados de cada simulación
resultado=[];
resultado2=[];
resultado3=[];
resultado4=[];
indicadores=[];
distBocas=[];

numsim=size(caudales,2);
numbocas=size(caudales,1);

iterQbombeomax=0;
Qbombeomax=0;

hreq=[hreq;0;0];

%Aportación bombeo
Hbombeo=59.0;
H0=z0+Hbombeo;


## x, abcisas de los nudos ficticios de la malla
## y, ordenadas de los nudos ficticios de la malla
## z, cotas de de los nudos ficticios de la malla

x=[x;1200;1200];
y=[y;-200;-200];
z=[z;125;125];
 
D=[D;0.15;0.15]; % Diámetros de los tramos de la malla
L=[L;200;200]; % Longitudes de los tramos de la malla
ka=[ka;4e-5;4e-5];

# Vector de nudos
vectorBocas=[vectorBocas; 9; 10];

## Matriz de conexiones
## Se añaden los tramos correspondientes a los nudos ficticios 9, que sale del 4, y 10, que sale del 7
Mconexmalla_hf=[Mconex_hf zeros(size(Mconex_hf,1),2)];
Mconexmalla_hf(9,:) =[Mconex_hf(4,:) 1 0];
Mconexmalla_hf(10,:)=[Mconex_hf(7,:) 0 1];

Mconexmalla_Q=transpose(Mconexmalla_hf);

# Se representa, en la figura de la red, los nuevos tramos que conforman la malla
figure(fig01)
hold on
plot([x(4+1) x(9+1)],[y(4+1) y(9+1)])
text(x(9+1)-25,y(9+1)+25,num2str(vectorBocas(9)))
plot([x(7+1) x(10+1)],[y(7+1) y(10+1)])
text(x(10+1)-25,y(10+1)-25,num2str(vectorBocas(10)))
hold off

for i=1:numsim
  %Caudal de cada tramo (tubería)
  
  ## Vector de la demanda desde los nudos, incluyendo los valores iniciales para los dos ficticios
  qdemand=[caudales(:,i).*1e-3;[0;0]];

  if sum(qdemand)>0
  
    H_nodo=hreq+z;
    H_nodo_ant=zeros(numel(vectorBocas,1));    
    
    while max(abs(H_nodo-H_nodo_ant))>1e-3
      
      H_nodo_ant=H_nodo;
      
      Q=Mconexmalla_Q*qdemand;
      Qbombeo=max(Q);
  
      %Pérdida de carga en cada tramo
      hf=IWC(Q,D,ka,nu).*L;
  
      %Carga en cada nodo
      H_nodo=H0-Mconexmalla_hf*hf;
      
      ##Mallado
      %Pareja de nodos ficticios 9,10
      if abs(H_nodo(9)-H_nodo(10))>1e-1
          qdemand(9)=qdemand(9)*(cte+H_nodo(9))/(cte+H_nodo(10))*sign(H_nodo(9)-H_nodo(10));
          qdemand(10)=-qdemand(9);
      endif
      [H_nodo(9) H_nodo(10) qdemand(9)];
      
    endwhile
    
# Indicadores
    # Indicador rendimiento energético
    % Potencia útil en las bocas con presión suficiente en relación a la potencia del bombeo
    rendEnerg=sum(qdemand.*hreq.*((H_nodo-z)>hreq))/(Hbombeo*Qbombeo);
    # Coeficiente déficit energético
    % Potencia entregada "no aprovechable" en relación a la potencia requerida
    coefDef=sum(qdemand.*(H_nodo-z).*((H_nodo-z)<hreq))/sum(qdemand.*hreq);
      
    %Columnas vector resultado [c1:caudal cabeza c2: presión máxima
    resultado=[resultado;Qbombeo max((H_nodo-z).*(hreq>0).*(qdemand>0)) min((H_nodo(1:8)-z(1:8)))];
    resultado2=[resultado2 H_nodo];
    resultado3=[resultado3 H_nodo-z < hreq];
    resultado4=[resultado4 qdemand];
    
    %Indicadores
    indicadores=[indicadores; Qbombeo rendEnerg coefDef];
 
  endif

endfor

fig04=figure();
subplot(1,3,1)
plot(resultado(:,1),resultado(:,2),'+')
axis([0 max(resultado(:,1)) min(resultado(:,3)) max(resultado(:,2))])
xlabel('Q');ylabel('Altura presión (max y min)')
hold on
plot(resultado(:,1),resultado(:,3),'+')
plot([0 max(resultado(:,1))],[min(resultado(:,3)) min(resultado(:,3))])
hold off

%resultado(lookup(resultado(:,2),max(resultado(:,2))),:)

% Proporción de bocas que no dispondrían de la altura requerida
for i=1:numel(vectorBocas)
  distBocas=[distBocas sum(resultado3(i,:))];
endfor
if sum(distBocas) == 0
  distBocas=zeros(1,numel(vectorBocas));
else
  distBocas=distBocas/size(resultado3,2);
endif

subplot(1,3,2)
bar(distBocas)
xlabel('boca presión mínima');ylabel('frecuencia')

subplot(1,3,3)
plot(indicadores(:,1),indicadores(:,2),'+')
axis([0 max(indicadores(:,1)) 0 max(indicadores(:,2))])
xlabel('Q'); ylabel('rend. Energético')
hold on
plot(indicadores(:,1),indicadores(:,3),'+')
hold off

