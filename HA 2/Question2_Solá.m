%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEVELOPMENT ECONOMICS - HOMEWORK 2 
% Daniela Solá
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUESTION 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear all
clc


%% GENERAL SET-UP MODEL:

% Set parameters
N = 1000;
T = 12 * 40; % households live for 40 years, 40*12 months.
beta = 0.99^(1/12); % Given the Household lifetime utility. Note that anual beta (b^12)= 0.99.
sigma_e = 0.2;
sigma_u = 0.2; 
eta_1 = 1;
eta_2 = 2;
eta_4 = 4;
nu = 1;

% Calibration for kappa
theta = 0.6; % Labor share of total output
y_consumption = 1/0.25; % Output over consumption
hours_month = 28.5 * (30/7); % Hours worked per month (Bick et al 2018)
kappa = theta * y_consumption * (hours_month)^(-1-1/nu);

% Deterministic seasonal component positive
gm_low = [-0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018, 0.018, 0.001, -0.017, -0.041];
gm_mid = [-0.147, -0.370, 0.141, 0.131, 0.090, 0.058, 0.036, 0.036, 0.036, 0.002, -0.033, -0.082];
gm_high = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, 0.072, 0.004, -0.066, -0.164];

% Deterministic seasonal component negative
gm_low_neg = [+0.073, +0.185, -0.071, -0.066, -0.045, -0.029, -0.018, -0.018, -0.018, -0.001, +0.017, +0.041];
gm_mid_neg = [+0.147, +0.370, -0.141, -0.131, -0.090, -0.058, -0.036, -0.036, -0.036, -0.002, +0.033, +0.082];
gm_high_neg = [+0.293, +0.739, -0.282, -0.262, -0.180, -0.116, -0.072, -0.072,-0.072, -0.004, +0.066, +0.164];


% Stochastic seasonal component
sigma_m_low = [ 0.043, 0.034, 0.145, 0.142, 0.137, 0.137, 0.119, 0.102, 0.094, 0.094, 0.085, 0.068];
sigma_m_mid = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137];
sigma_m_high = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273];

% Discounting matrix
beta_month = zeros(1,12);
beta_age = zeros(1,40);
 for i = 1:12
     beta_month(1,i) = beta.^(i-1);
 end
 for i = 1:40 
     beta_age(1,i) = beta.^(12*i);
 end
Betas = ones(N,1) * kron(beta_age,beta_month);

%% QUESTION 2, SET UP: CONSUMPTION AND LABOR  

% Create NxT matrices with deterministic seasonal components
S_low = exp( kron(ones(N,40),gm_low) );
S_mid = exp( kron(ones(N,40),gm_mid) );
S_high = exp( kron(ones(N,40),gm_high) );
S_low_neg = exp( kron(ones(N,40),gm_low_neg) );
S_mid_neg = exp( kron(ones(N,40),gm_mid_neg) );
S_high_neg = exp( kron(ones(N,40),gm_high_neg) );

% Positively correlated.
% Stochastic seasonal components for both consumption and labor.
Sr_low = zeros(N,T);
lab_Sr_low = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sqrt(sigma_m_low(1,i)), 0.04; 0.04,sqrt(sigma_m_low(1,i))];
        ln = mvnrnd(zeros(2,1), varcov);
        Sr_low(k,i+j*12) = exp(-sqrt(sigma_m_low(1,i))/2) * exp(ln(1,1));
        lab_Sr_low(k,i+j*12) = exp(-sqrt(sigma_m_low(1,i))/2) * exp(ln(1,2));
        end
    end
end
Sr_mid = zeros(N,T);
lab_Sr_mid = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sqrt(sigma_m_mid(1,i)), 0.04; 0.04,sqrt(sigma_m_mid(1,i))];
        ln = mvnrnd(zeros(2,1), varcov);
        Sr_mid(k,i+j*12) = exp(-sqrt(sigma_m_mid(1,i))/2) * exp(ln(1,1));
        lab_Sr_mid(k,i+j*12) = exp(-sqrt(sigma_m_mid(1,i))/2) * exp(ln(1,2));
        end
    end
end
Sr_high = zeros(N,T);
lab_Sr_high = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sqrt(sigma_m_high(1,i)), 0.04; 0.04,sqrt(sigma_m_high(1,i))];
        ln = mvnrnd(zeros(2,1), varcov);
        Sr_high(k,i+j*12) = exp(-sqrt(sigma_m_high(1,i))/2) * exp(ln(1,1));
        lab_Sr_high(k,i+j*12) = exp(-sqrt(sigma_m_high(1,i))/2) * exp(ln(1,2));
        end
    end
end

% Negatively correlated.
% Stochastic seasonal components for both consumption and labor.
Sr_low_neg = zeros(N,T);
lab_Sr_low_neg = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sqrt(sigma_m_low(1,i)), -0.04; -0.04,sqrt(sigma_m_low(1,i))];
        ln = mvnrnd(zeros(2,1), varcov);
        Sr_low_neg(k,i+j*12) = exp(-sqrt(sigma_m_low(1,i))/2) * exp(ln(1,1));
        lab_Sr_low_neg(k,i+j*12) = exp(-sqrt(sigma_m_low(1,i))/2) * exp(ln(1,2));
        end
    end
end
Sr_mid_neg = zeros(N,T);
lab_Sr_mid_neg = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sqrt(sigma_m_mid(1,i)), -0.04; -0.04,sqrt(sigma_m_mid(1,i))];
        ln = mvnrnd(zeros(2,1), varcov);
        Sr_mid_neg(k,i+j*12) = exp(-sqrt(sigma_m_mid(1,i))/2) * exp(ln(1,1));
        lab_Sr_mid_neg(k,i+j*12) = exp(-sqrt(sigma_m_mid(1,i))/2) * exp(ln(1,2));
        end
    end
end
Sr_high_neg = zeros(N,T);
lab_Sr_high_neg = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sqrt(sigma_m_high(1,i)), -0.04; -0.04,sqrt(sigma_m_high(1,i))];
        ln = mvnrnd(zeros(2,1), varcov);
        Sr_high_neg(k,i+j*12) = exp(-sqrt(sigma_m_high(1,i))/2) * exp(ln(1,1));
        lab_Sr_high_neg(k,i+j*12) = exp(-sqrt(sigma_m_high(1,i))/2) * exp(ln(1,2));
        end
    end
end

%% QUESTION 2, SET UP: CONSUMPTION 

% Create the individual component z_i 
ln_u = mvnrnd(zeros(N,1),eye(N) * sqrt(sigma_u)).'; 
z = exp(-sqrt(sigma_u/2)) * exp(ln_u); 
Z = z * ones(1,T); 

% Create NxT matrix with non-seasonal shocks for any period
ln_e = zeros(N,T);
for i = 1:N
    for j = 0:39
        ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sigma_e);
    end
end
Exp = exp(-sqrt(sigma_e/2)) * exp(ln_e);


%% QUESTION 2, SET UP: LABOR 

% Create the individual component lab_z_i 
lab_ln_u = mvnrnd(zeros(N,1),eye(N) * sqrt(sigma_u)).'; 
lab_z = exp(-sqrt(sigma_u/2)) * exp(lab_ln_u); 
lab_Z = lab_z * ones(1,T); 

% Create NxT matrix with non-seasonal shocks for any period
lab_ln_e = zeros(N,T);
for i = 1:N
    for j = 0:39
        lab_ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sigma_e);
    end
end
lab_Exp = exp(-sqrt(sigma_e/2)) * exp(lab_ln_e);


%% SET UP: VALUES OF CONSUMPTION AND LABOR POSITIVELY CORRELATED

% Calculate matrix of individual consumptions (NxT each matrix)

%(1)
Clow_s_sr_r = Z .* S_low .*  Sr_low .* Exp; 
Cmid_s_sr_r = Z .* S_mid .* Sr_mid .* Exp;
Chigh_s_sr_r = Z .* S_high .* Sr_high .* Exp;

%(2)
Clow_s_sr = Z .* S_low .*  Sr_low; 
Cmid_s_sr = Z .* S_mid .* Sr_mid;
Chigh_s_sr = Z .* S_high .* Sr_high;

%(3)
Clow_s_r = Z .* S_low .* Exp; 
Cmid_s_r = Z .* S_mid .* Exp;
Chigh_s_r = Z .* S_high .* Exp;

%(4)
Clow_s = Z .* S_low; 
Cmid_s = Z .* S_mid;
Chigh_s = Z .* S_high;

%(5)
C_r = Z .* Exp; 

%(6)
C = Z;

% Create individual labors, each is a matrix of NxT:

%(1) 
Llow_s_sr_r = lab_Z .* S_low .*  lab_Sr_low .* lab_Exp; 
Lmid_s_sr_r = lab_Z .* S_mid .* lab_Sr_mid .* lab_Exp;
Lhigh_s_sr_r = lab_Z .* S_high .* lab_Sr_high .* lab_Exp;

%(2) 
Llow_s_sr = lab_Z .* S_low .*  lab_Sr_low; 
Lmid_s_sr = lab_Z .* S_mid .* lab_Sr_mid;
Lhigh_s_sr = lab_Z .* S_high .* lab_Sr_high;

%(3) 
Llow_s_r = lab_Z .* S_low .* lab_Exp; 
Lmid_s_r = lab_Z .* S_mid .* lab_Exp;
Lhigh_s_r = lab_Z .* S_high .* lab_Exp;

%(4) 
Llow_s = lab_Z .* S_low; 
Lmid_s = lab_Z .* S_mid;
Lhigh_s = lab_Z .* S_high;

%(5) 
L_r = lab_Z .* lab_Exp; 

%(6) 
L = lab_Z;

%% QUESTION 2, SET UP: CONSUMPTION AND LABOR NEGATIVELY CORRELATED

% Calculate matrix of individual consumptions (NxT each matrix)
Clow_s_sr_r_neg = Z .* S_low .*  Sr_low_neg .* Exp; 
Cmid_s_sr_r_neg = Z .* S_mid .* Sr_mid_neg .* Exp;
Chigh_s_sr_r_neg = Z .* S_high .* Sr_high_neg .* Exp;
Clow_s_sr_neg = Z .* S_low .*  Sr_low_neg; 
Cmid_s_sr_neg = Z .* S_mid .* Sr_mid_neg;
Chigh_s_sr_neg = Z .* S_high .* Sr_high_neg;

% Calculate matrix of individual labors (NxT each matrix)
Llow_s_sr_r_neg = lab_Z .* S_low .*  lab_Sr_low_neg .* lab_Exp; 
Lmid_s_sr_r_neg = lab_Z .* S_mid .* lab_Sr_mid_neg .* lab_Exp;
Lhigh_s_sr_r_neg = lab_Z .* S_high .* lab_Sr_high_neg .* lab_Exp;
Llow_s_sr_neg = lab_Z .* S_low .*  lab_Sr_low_neg; 
Lmid_s_sr_neg = lab_Z .* S_mid .* lab_Sr_mid_neg;
Lhigh_s_sr_neg = lab_Z .* S_high .* lab_Sr_high_neg;


%% QUESTION 2, PART A:

% Total effects
glow_s_sr = zeros(N,1); 
gmid_s_sr = zeros(N,1);
ghigh_s_sr = zeros(N,1);
for i = 1:N
funl = @(gl) abs(sum(...
    transpose(Betas(i,:).*( log(Clow_s_sr_r(i,:).*(1+gl)) - kappa.*(Llow_s_sr_r(i,:).^(1+1/nu)/(1+1/nu)) )) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
glow_s_sr(i,1) = fminbnd(funl,-6,15);

funm = @(gm) abs(sum(...
    transpose(Betas(i,:).*( log(Cmid_s_sr_r(i,:).*(1+gm)) - kappa.*(Lmid_s_sr_r(i,:).^(1+1/nu)/(1+1/nu)) )) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
gmid_s_sr(i,1) = fminbnd(funm,-6,15);

funh = @(gh) abs(sum(...
    transpose(Betas(i,:).*( log(Chigh_s_sr_r(i,:).*(1+gh)) - kappa.*(Lhigh_s_sr_r(i,:).^(1+1/nu)/(1+1/nu)) )) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:)) - kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
ghigh_s_sr(i,1) = fminbnd(funh,-6,15);
end

% Consumption effects
glow_s_sr_conseff = zeros(N,1); 
gmid_s_sr_conseff = zeros(N,1);
ghigh_s_sr_conseff = zeros(N,1);
for i = 1:N
funl = @(gl) abs(sum(...
    transpose(Betas(i,:).*(  log(Clow_s_sr_r(i,:).*(1+gl))  -  kappa.*(Llow_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(Llow_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))   ))  ));
glow_s_sr_conseff(i,1) = fminbnd(funl,-6,15);

funm = @(gm) abs(sum(...
    transpose(Betas(i,:).*(  log(Cmid_s_sr_r(i,:).*(1+gm))  -  kappa.*(Lmid_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(Lmid_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))   ))   ));
gmid_s_sr_conseff(i,1) = fminbnd(funm,-6,15);

funh = @(gh) abs(sum(...
    transpose(Betas(i,:).*(  log(Chigh_s_sr_r(i,:).*(1+gh))  -  kappa.*(Lhigh_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(Lhigh_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))  ))   ));
ghigh_s_sr_conseff(i,1) = fminbnd(funh,-6,15);
end

% Labor effects
glow_s_sr_labeff = zeros(N,1); 
gmid_s_sr_labeff = zeros(N,1);
ghigh_s_sr_labeff = zeros(N,1);
for i = 1:N
funl = @(gl) abs(sum(...
    transpose(Betas(i,:).*(  log(C_r(i,:).*(1+gl))  -  kappa.*(Llow_s_sr_r(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))      ))  ));
glow_s_sr_labeff(i,1) = fminbnd(funl,-6,15);

funm = @(gm) abs(sum(...
    transpose(Betas(i,:).*(  log(C_r(i,:).*(1+gm))  -  kappa.*(Lmid_s_sr_r(i,:).^(1+1/nu)/(1+1/nu)))) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))   ));
gmid_s_sr_labeff(i,1) = fminbnd(funm,-6,15);

funh = @(gh) abs(sum(...
    transpose(Betas(i,:).*( log(C_r(i,:).*(1+gh))  -  kappa.*(Lhigh_s_sr_r(i,:).^(1+1/nu)/(1+1/nu)))) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:)) -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
ghigh_s_sr_labeff(i,1) = fminbnd(funh,-6,15);
end


%% QUESTION 2, RESULTS PART A 
% Assume a deterministic seasonal component and a stochastic seasonal component for
% labor supply both of which are highly positively correlated with their consumption counterparts
 
% Summary statistics total effects
Results = [mean(glow_s_sr), mean(gmid_s_sr), mean(ghigh_s_sr); std(glow_s_sr), std(gmid_s_sr), std(ghigh_s_sr)];
disp(' RESULTS PART A. Total effects')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, mid, high')
disp(' ')
disp(' ')
 
% Summary statistics consumption effects
Results = [mean(glow_s_sr_conseff), mean(gmid_s_sr_conseff), mean(ghigh_s_sr_conseff); std(glow_s_sr_conseff), std(gmid_s_sr_conseff), std(ghigh_s_sr_conseff)];
disp(' RESULTS PART A. Consumption effects')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, mid, high')
disp(' ')
disp(' ')

% Summary statistics labor effects
Results = [mean(glow_s_sr_labeff), mean(gmid_s_sr_labeff), mean(ghigh_s_sr_labeff); std(glow_s_sr_labeff), std(gmid_s_sr_labeff), std(ghigh_s_sr_labeff)];
disp(' RESULTS PART A. Labor effects')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, mid, high')
disp(' ')
disp(' ')

% Graphs
figure
subplot(3,1,1);
hold on
histogram(glow_s_sr,16,'BinWidth',0.01);
hold on
histogram(glow_s_sr_conseff,16,'BinWidth',0.01);
hold on
histogram(glow_s_sr_labeff,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual')
ylabel('Nº indiv')
legend('comp_{total}','comp_{consumption}','comp_{labor}')
title('Low seasonality - Positive correlation')
 
subplot(3,1,2);
hold on
histogram(gmid_s_sr,16,'BinWidth',0.01);
hold on
histogram(gmid_s_sr_conseff,16,'BinWidth',0.01);
hold on
histogram(gmid_s_sr_labeff,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual')
ylabel('Nº indiv')
legend('comp_{total}','comp_{consumption}','comp_{labor}')
title('Medium seasonality - Positive correlation')
 
subplot(3,1,3);
hold on
histogram(ghigh_s_sr,16,'BinWidth',0.01);
hold on
histogram(ghigh_s_sr_conseff,16,'BinWidth',0.01);
hold on
histogram(ghigh_s_sr_labeff,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('comp_{total}','comp_{consumption}','comp_{labor}')
title('high seasonality - Positive correlation')
print('Q2_A','-dpng')


%% QUESTION 2, PART B :
%Assume a deterministic seasonal component and a stochastic seasonal component for
%labor supply both of which are highly negatively correlated with their consumption counterparts.

% Total effects
glow_s_sr_neg = zeros(N,1); 
gmid_s_sr_neg = zeros(N,1);
ghigh_s_sr_neg = zeros(N,1);
for i = 1:N
funl = @(gl) abs(sum(...
    transpose(Betas(i,:).*(  log(Clow_s_sr_r_neg(i,:).*(1+gl))  -  kappa.*(Llow_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))     ))   ));
glow_s_sr_neg(i,1) = fminbnd(funl,-6,15);

funm = @(gm) abs(sum(...
    transpose(Betas(i,:).*(  log(Cmid_s_sr_r_neg(i,:).*(1+gm))  -  kappa.*(Lmid_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))                      ))   ));
gmid_s_sr_neg(i,1) = fminbnd(funm,-6,15);

funh = @(gh) abs(sum(...
    transpose(Betas(i,:).*(  log(Chigh_s_sr_r_neg(i,:).*(1+gh))  -  kappa.*(Lhigh_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))   ))   ));
ghigh_s_sr_neg(i,1) = fminbnd(funh,-6,15);
end

% Consumption effects
glow_s_sr_conseff_neg = zeros(N,1); 
gmid_s_sr_conseff_neg = zeros(N,1);
ghigh_s_sr_conseff_neg = zeros(N,1);
for i = 1:N
funl = @(gl) abs(sum(...
    transpose(Betas(i,:).*(  log(Clow_s_sr_r_neg(i,:).*(1+gl))  -  kappa.*(Llow_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(Llow_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  ))   ));
glow_s_sr_conseff_neg(i,1) = fminbnd(funl,-6,15);

funm = @(gm) abs(sum(...
    transpose(Betas(i,:).*(  log(Cmid_s_sr_r_neg(i,:).*(1+gm))  -  kappa.*(Lmid_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(Lmid_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  ))   ));
gmid_s_sr_conseff_neg(i,1) = fminbnd(funm,-6,15);

funh = @(gh) abs(sum(...
    transpose(Betas(i,:).*(  log(Chigh_s_sr_r_neg(i,:).*(1+gh))  -  kappa.*(Lhigh_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*(  log(C_r(i,:))  -  kappa.*(Lhigh_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))        ))   ));
ghigh_s_sr_conseff_neg(i,1) = fminbnd(funh,-6,15);
end

% Labor effects
glow_s_sr_labeff_neg = zeros(N,1); 
gmid_s_sr_labeff_neg = zeros(N,1);
ghigh_s_sr_labeff_neg = zeros(N,1);
for i = 1:N
funl = @(gl) abs(sum(...
    transpose(Betas(i,:).*( log(C_r(i,:).*(1+gl))  -  kappa.*(Llow_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu)))) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
glow_s_sr_labeff_neg(i,1) = fminbnd(funl,-6,15);

funm = @(gm) abs(sum(...
    transpose(Betas(i,:).*( log(C_r(i,:).*(1+gm))  -  kappa.*(Lmid_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:))  -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
gmid_s_sr_labeff_neg(i,1) = fminbnd(funm,-6,15);

funh = @(gh) abs(sum(...
    transpose(Betas(i,:).*( log(C_r(i,:).*(1+gh))  -  kappa.*(Lhigh_s_sr_r_neg(i,:).^(1+1/nu)/(1+1/nu))  )) - ... 
    transpose(Betas(i,:).*( log(C_r(i,:)) -  kappa.*(L_r(i,:).^(1+1/nu)/(1+1/nu))))));
ghigh_s_sr_labeff_neg(i,1) = fminbnd(funh,-6,15);
end

%% RESULTS PART B %%
 
% Summary statistics total effects
Results = [mean(glow_s_sr_neg), mean(gmid_s_sr_neg), mean(ghigh_s_sr_neg); std(glow_s_sr_neg), std(gmid_s_sr_neg), std(ghigh_s_sr_neg)];
disp(' RESULTS PART B. Total effects')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, mid, high, and no seasonality')
disp(' ')
disp(' ')
 
% Summary statistics consumption effects
Results = [mean(glow_s_sr_conseff_neg), mean(gmid_s_sr_conseff_neg), mean(ghigh_s_sr_conseff_neg); std(glow_s_sr_conseff_neg), std(gmid_s_sr_conseff_neg), std(ghigh_s_sr_conseff_neg)];
disp(' RESULTS PART B. Consumption effects')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, mid, high, and no seasonality')
disp(' ')
disp(' ')

% Summary statistics labor effects
Results = [mean(glow_s_sr_labeff_neg), mean(gmid_s_sr_labeff_neg), mean(ghigh_s_sr_labeff_neg); std(glow_s_sr_labeff_neg), std(gmid_s_sr_labeff_neg), std(ghigh_s_sr_labeff_neg)];
disp(' RESULTS PART B. Labor effects')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, mid, high, and no seasonality')
disp(' ')
disp(' ')

% Graphs
figure
subplot(3,1,1);
hold on
histogram(glow_s_sr_neg,16,'BinWidth',0.01);
hold on
histogram(glow_s_sr_conseff_neg,16,'BinWidth',0.01);
hold on
histogram(glow_s_sr_labeff_neg,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual')
ylabel('Nº indiv')
legend('comp_{total}','comp_{consumption}','comp_{labor}')
title('Low seasonality - Negative correlation')
 
subplot(3,1,2);
hold on
histogram(gmid_s_sr_neg,16,'BinWidth',0.01);
hold on
histogram(gmid_s_sr_conseff_neg,16,'BinWidth',0.01);
hold on
histogram(gmid_s_sr_labeff_neg,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual')
ylabel('Nº indiv')
legend('comp_{total}','comp_{consumption}','comp_{labor}')
title('Medium seasonality - Negative correlation')
 
subplot(3,1,3);
hold on
histogram(ghigh_s_sr_neg,16,'BinWidth',0.01);
hold on
histogram(ghigh_s_sr_conseff_neg,16,'BinWidth',0.01);
hold on
histogram(ghigh_s_sr_labeff_neg,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual')
ylabel('Nº indiv')
legend('comp_{total}','comp_{consumption}','comp_{labor}')
title('high seasonality - Negative correlation')
print('Q2_B','-dpng')