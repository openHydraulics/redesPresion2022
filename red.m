# Cálculo y análisis de una red de distribución

close all; clear; clc

# Enlace a funciones (relativas a Q, D, I, k y nu) en carperta ./src/
addpath('./src/');

# Se cargan los datos de la red
datos;

# Se genera, con características aleatorias, una demanda anual por horas (24 x 30 x 12 = 8640 h)
gen_demanda;
