function [tempo_h,lunghezza] = jump_estimate(v_0x,v_0y)
%LUNGHEZZA_SALTO_V0s è una funzione creata al volo per calcolare tempo di
%volo per arrivare al picco della parabola e la lunghezza del salto
%(gittata della parabola).
% Metodo usato, quello delle velocità al momento dello stacco => METODO V0s

% VARIABILI D'INGRESSO:
%   v_0x= velocità orizzontale allo stacco
%   v_0y= velocità verticale allo stacco

%   VARIABILI IN USCITA:
%   tempo_h= tempo per arrivare al picco h della parabola
%   lunghezza= distanza saltata

%   ALTRE VARIABILI:
%   g= gravità

g= 9.80665;

tempo_h = (1+sqrt(2))*v_0y/g;

lunghezza =abs(2*v_0x*tempo_h); %perché in alcuni casi per il drift v0x o v0y sono negative
end