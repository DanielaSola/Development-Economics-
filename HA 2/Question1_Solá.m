%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEVELOPMENT ECONOMICS - HOMEWORK 2 
% Daniela Solá
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUESTION 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear all
clc

%% GENERAL SET-UP MODEL 

% Parameters
N = 1000;
T = 12 * 40; % households live for 40 years, 40*12 months.
beta = 0.99^(1/12); % Given the Household lifetime utility. Note that anual beta (b^12)= 0.99. 
sigma_e = 0.2;
sigma_u = 0.2; 
eta_1 = 1;
eta_2 = 2;
eta_4 = 4;

% Deterministic seasonal component
gm_low = [-0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018, 0.018, 0.001, -0.017, -0.041];
gm_mid = [-0.147, -0.370, 0.141, 0.131, 0.090, 0.058, 0.036, 0.036, 0.036, 0.002, -0.033, -0.082];
gm_high = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, 0.072, 0.004, -0.066, -0.164];

% Stochastic seasonal component
sigma_m_low = [ 0.043, 0.034, 0.145, 0.142, 0.137, 0.137, 0.119, 0.102, 0.094, 0.094, 0.085, 0.068];
sigma_m_mid = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137];
sigma_m_high = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273];


%% QUESTION 1, PART 1: SET UP 

% Create the individual component z_i 
ln_u = mvnrnd(zeros(N,1),eye(N) * sigma_u).'; % Nx1 matrix with the individual ln_u
z = exp(-sigma_u/2) * exp(ln_u); % Permanent level of consumption, Nx1 column with individual components Z_i's
Z = z * ones(1,T); % NxT matrix, for each consumer at each period.

% NxT matrices with seasonal components
% Diffrent in each season but the same for all individuals.
S_low = exp( kron(ones(N,40),gm_low) );
S_mid = exp( kron(ones(N,40),gm_mid) );
S_high = exp( kron(ones(N,40),gm_high) );

% Create individual risk (stochastic) for all period (NxT matrix) 
ln_e = zeros(N,T);
for i = 1:N
    for j = 0:39
        ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sqrt(sigma_e));
    end
end
Exp = exp(-sigma_e/2) * exp(ln_e);

% Create all consumptios, each is a matrix of NxT:

%(1) Individual consumption with seasonal component and stochastic risk.
C_slow_r = Z .* S_low .* Exp;  
C_smid_r = Z .* S_mid .* Exp;
C_shigh_r = Z .* S_high .* Exp;

%(2) Individual consumption with seasonal component.
C_slow = Z .* S_low; 
C_smid = Z .* S_mid;
C_shigh = Z .* S_high;

%(3)Individual consumption with individual risk
C_r = Z .* Exp;

% (4) Consumption without seasonal component and without stochastic risk.
C = Z ; 
       

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


%% QUESTION 1, PART 1.A. :
% Welfare gains of removing the seasonal component from the stream of consumption separately
% for each degree of seasonality (eta = 1)%%

glow1_s = zeros(N,1); 
gmid1_s = zeros(N,1);
ghigh1_s = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum(transpose(Betas(i,:) .* log( C_slow_r(i,:)*(1+gl))) -transpose(Betas(i,:) .* log(C_r(i,:))))));
glow1_s(i,1) = fminbnd(funl,-3,3);

funm = @(gm) abs(transpose(sum(transpose(Betas(i,:) .* log( C_smid_r(i,:)*(1+gm))) - transpose(Betas(i,:) .* log(C_r(i,:))))));
gmid1_s(i,1) = fminbnd(funm,-3,3);

funh = @(gh) abs(transpose(sum(transpose(Betas(i,:) .* log( C_shigh_r(i,:)*(1+gh))) - transpose(Betas(i,:) .* log(C_r(i,:))))));
ghigh1_s(i,1) = fminbnd(funh,-3,3);
end

    % Results:
Results = [mean(glow1_s), mean(gmid1_s), mean(ghigh1_s)];
disp(' RESULTS PART 1.A. Mean welfare gains of removing seasonality')
disp(Results)
disp('Low, Mid, and High seasonality')
disp(' ')
disp(' ')

%% QUESTION 1, PART 1.B. : 
% Welfare gains of removing the nonseasonal consumption risk (eta = 1):

glow1_r = zeros(N,1);
gmid1_r = zeros(N,1);
ghigh1_r = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum(transpose(Betas(i,:) .* log( C_slow_r(i,:)*(1+gl))) - transpose(Betas(i,:) .* log(C_slow(i,:))))));
glow1_r(i,1) = fminbnd(funl,-3,3);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* log( C_smid_r(i,:)*(1+gm))) - transpose(Betas(i,:) .* log(C_smid(i,:))))));
gmid1_r(i,1) = fminbnd(funm,-3,3);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* log( C_shigh_r(i,:)*(1+gh))) - transpose(Betas(i,:) .* log(C_shigh(i,:))))));
ghigh1_r(i,1) = fminbnd(funh,-3,3);
end

% Results
disp(' RESULTS PART 1.B. Welfare gains of removing non-seasonal consumption risk (eta=1)')
disp(Results)
disp('Row 1: means. Row 1: standard errors')
disp('Low, Mid, High, and no seasonality')
disp(' ')
disp(' ')

% Graph to compare distribution of welfare gains of removing non-seasonal consumption risk
hold on
histogram(gmid1_r,'FaceColor', 'r')
xlabel('Individual')
ylabel('Nº of households')
legend('eta=1')
title({'Q1 Part1 B', 'Welfare gains of removing non-seasonal consumption risk'})
print('Q1_Part1_B','-dpng')


%% QUESTION 1,PART 1.D. :
% Redo for eta = (2 ; 4)

%%%  ETA = 2
% Welfare gains of removing the seasonal component from the stream of consumption separately
% for each degree of seasonality (eta = 2)%%

glow2_s = zeros(N,1);
gmid2_s = zeros(N,1);
ghigh2_s = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((C_slow_r(i,:)*(1+gl))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2))))));
glow2_s(i,1) = fminbnd(funl,-3,3);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((C_smid_r(i,:)*(1+gm))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2))))));
gmid2_s(i,1) = fminbnd(funm,-3,3);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((C_shigh_r(i,:)*(1+gh))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2))))));
ghigh2_s(i,1) = fminbnd(funh,-3,3);
end

% Welfare gains removing seasonal component (eta = 4)
glow4_s = zeros(N,1);
gmid4_s = zeros(N,1);
ghigh4_s = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((C_slow_r(i,:)*(1+gl))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4))))));
glow4_s(i,1) = fminbnd(funl,-3,3);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((C_smid_r(i,:)*(1+gm))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4))))));
gmid4_s(i,1) = fminbnd(funm,-3,3);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((C_shigh_r(i,:)*(1+gh))).^(1-eta_4) / (1-eta_4))- transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4))))));
ghigh4_s(i,1) = fminbnd(funh,-3,3);
end

% Results:
Results = [mean(glow2_s), mean(gmid2_s), mean(ghigh2_s); mean(glow4_s), mean(gmid4_s), mean(ghigh4_s)];
disp(' RESULTS PART 1.D. Mean welfare gains of removing seasonality (eta=2 and 4)')
disp(Results)
disp('Row 1: eta=2. Row 2: eta=4')
disp('Low, Mid, and High seasonality')
disp(' ')
disp(' ')

% Welfare gains removing non-seasonal consumption risk (eta = 2)
glow2_r = zeros(N,1);
gmid2_r = zeros(N,1);
ghigh2_r = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((C_slow_r(i,:)*(1+gl))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_slow(i,:)).^(1-eta_2) / (1-eta_2)) ))) );
glow2_r(i,1) = fminbnd(funl,-3,3);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((C_smid_r(i,:)*(1+gm))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_smid(i,:)).^(1-eta_2) / (1-eta_2))))));
gmid2_r(i,1) = fminbnd(funm,-3,3);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((C_shigh_r(i,:)*(1+gh))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_shigh(i,:)).^(1-eta_2) / (1-eta_2))))));
ghigh2_r(i,1) = fminbnd(funh,-3,3);
end

% Welfare gains removing non-seasonal consumption risk (eta = 4)
glow4_r = zeros(N,1);
gmid4_r = zeros(N,1);
ghigh4_r = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((C_slow_r(i,:)*(1+gl))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_slow(i,:)).^(1-eta_4) / (1-eta_4))))));
glow4_r(i,1) = fminbnd(funl,-3,3);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((C_smid_r(i,:)*(1+gm))).^(1-eta_4) / (1-eta_4))- transpose(Betas(i,:) .* ((C_smid(i,:)).^(1-eta_4) / (1-eta_4))))));
gmid4_r(i,1) = fminbnd(funm,-3,3);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((C_shigh_r(i,:)*(1+gh))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_shigh(i,:)).^(1-eta_4) / (1-eta_4))))));
ghigh4_r(i,1) = fminbnd(funh,-3,3);
end


Results = [mean(glow2_r), mean(gmid2_r), mean(ghigh2_r); mean(glow4_r), mean(gmid4_r), mean(ghigh4_r); std(glow2_r), std(gmid2_r), std(ghigh2_r); std(glow4_r), std(gmid4_r), std(ghigh4_r)];

% Results
disp(' RESULTS PART 1.D. Welfare gains of removing non-seasonal consumption risk (eta=2;4)')
disp(Results)
disp('Rows 1 and 2: means for eta 2 and 4. Rows 3 and 4: standard errors for eta 2 and 4')
disp('Low, Mid, High, and no seasonality')
disp(' ')
disp(' ')

% Graph to compare distribution of welfare gains of removing non-seasonal consumption risk
figure 
hold on
histogram(gmid1_r,'FaceColor', 'r');
hold on
histogram(gmid2_r,'FaceColor', 'g');
hold on
histogram(gmid4_r,'FaceColor', 'b');
xlabel('Individual')
ylabel('Nº of households')
legend('eta=1','eta=2','eta=4')
title({'Q1 Part1 D', 'Welfare gains of removing non-seasonal consumption risk'})
print('Q1_Part1_D','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QUESTION 1, PART 2: SET-UP %%
% Now add an stochastic seasonal component to consumption.

% (1) Create NxT matrix with seasonal components
% Each one is a row of 12 seasonal components used for each indiv.

Sr_low = zeros(N,T);
for i = 1:N
    for j = 0:39
      Sr_low(i,(1+j*12):(j+1)*12) = exp(-sigma_m_low/2) .* exp( mvnrnd(zeros(12,1), ones(12,1) * sigma_m_low .* eye(12) ) );
    end
end
Sr_mid = zeros(N,T);
for i = 1:N
    for j = 0:39
      Sr_mid(i,(1+j*12):(j+1)*12) = exp(-sigma_m_mid/2) .* exp( mvnrnd(zeros(12,1), ones(12,1) * sigma_m_mid .* eye(12) ) );
    end
end
Sr_high = zeros(N,T);
for i = 1:N
    for j = 0:39
      Sr_high(i,(1+j*12):(j+1)*12) = exp(-sigma_m_high/2) .* exp( mvnrnd(zeros(12,1), ones(12,1) * sigma_m_high .* eye(12) ) );
    end
end


% (2)Calculate matrix of individual consumptions (NxT each matrix)
%Assume that the deterministic seasonal component is always mid. 

%including all risks
Clow_smid_sr_r = Z .* S_mid .*  Sr_low .* Exp; 
Cmid_smid_sr_r = Z .* S_mid .* Sr_mid .* Exp;
Chigh_smid_sr_r = Z .* S_mid .* Sr_high .* Exp;

%not including stochastic seasonal risk
Clow_smid_sr = Z .* S_mid .*  Sr_low; 
Cmid_smid_sr = Z .* S_mid .* Sr_mid;
Chigh_smid_sr = Z .* S_mid .* Sr_high;

%including individual risk
C_smid_sr_r = Z .* S_mid .* Exp; 

%not including deterministic seasonal risk
Clow_sr_r = Z .*  Sr_low .* Exp; 
Cmid_sr_r = Z .* Sr_mid .* Exp;
Chigh_sr_r = Z .* Sr_high .* Exp;



%% QUESTION 1, PART 2.A : 
  % Welfare gains removing deterministic seasonal component (eta = 1)
glow1_s2 = zeros(N,1); 
gmid1_s2 = zeros(N,1);
ghigh1_s2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(Betas(i,:) .* log(Clow_smid_sr_r (i,:)*(1+gl))) - transpose(Betas(i,:) .* log(Clow_smid_sr(i,:))))));
    glow1_s2(i,1) = fminbnd(funlow,-3,4);

    funmid = @(gm) abs(transpose(sum(transpose(Betas(i,:) .* log(Cmid_smid_sr_r (i,:)*(1+gm))) - transpose(Betas(i,:) .* log(Cmid_smid_sr(i,:))))));
    gmid1_s2(i,1) = fminbnd(funmid,-3,4);

    funhigh = @(gh) abs(transpose(sum(transpose(Betas(i,:) .* log(Chigh_smid_sr_r (i,:)*(1+gh))) - transpose(Betas(i,:) .* log(Chigh_smid_sr(i,:))))));
    ghigh1_s2(i,1) = fminbnd(funhigh,-3,4);
end

% Welfare gains removing stochastic seasonal component (eta = 1)
glow1_rs = zeros(N,1); 
gmid1_rs = zeros(N,1);
ghigh1_rs = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(Betas(i,:) .* log(Clow_smid_sr_r (i,:)*(1+gl))) - transpose(Betas(i,:) .* log(C_smid_sr_r(i,:))))));
    glow1_rs(i,1) = fminbnd(funlow,-3,4);

    funmid = @(gm) abs(transpose(sum(transpose(Betas(i,:) .* log(Cmid_smid_sr_r (i,:)*(1+gm))) - transpose(Betas(i,:) .* log(C_smid_sr_r(i,:))))));
    gmid1_rs(i,1) = fminbnd(funmid,-3,4);

    funhigh = @(gh) abs(transpose(sum(transpose(Betas(i,:) .* log(Chigh_smid_sr_r (i,:)*(1+gh))) - transpose(Betas(i,:) .* log(C_smid_sr_r(i,:))))));
    ghigh1_rs(i,1) = fminbnd(funhigh,-3,4);
end
  
% Welfare gains removing both seasonal components (eta = 1)
glow1_s_sr = zeros(N,1); 
gmid1_s_sr = zeros(N,1);
ghigh1_s_sr = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(Betas(i,:) .* log(Clow_smid_sr_r (i,:)*(1+gl))) - transpose(Betas(i,:) .* log(C_r(i,:))))));
    glow1_s_sr(i,1) = fminbnd(funlow,-3,3);

    funmid = @(gm) abs(transpose(sum(transpose(Betas(i,:) .* log(Cmid_smid_sr_r (i,:)*(1+gm))) - transpose(Betas(i,:) .* log(C_r(i,:))))));
    gmid1_s_sr(i,1) = fminbnd(funmid,-3,3);

    funhigh = @(gh) abs(transpose(sum(transpose(Betas(i,:) .* log(Chigh_smid_sr_r (i,:)*(1+gh))) - transpose(Betas(i,:) .* log(C_r(i,:))))));
    ghigh1_s_sr(i,1) = fminbnd(funhigh,-3,3);
end

% Matrix with the mean results from removing deterministic component:
Results = [mean(glow1_s2), mean(gmid1_s2), mean(ghigh1_s2)];
disp(' RESULTS PART 2A - Welfare gains of removing deterministic seasonal component (eta=1)')
disp(Results)
disp('Rows: Means')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

% Matrix with the mean results from removing stochastic component:
Results = [mean(glow1_rs), mean(gmid1_rs), mean(ghigh1_rs); std(glow1_rs), std(gmid1_rs), std(ghigh1_rs)];

disp('RESULTS PART 2A - Welfare gains of removing stochastic seasonal components (eta=1)')
disp(Results)
disp('row 1: Means. row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

% Matrix with the mean results from removing both stochastic and deterministic component:
Results = [mean(glow1_s_sr), mean(gmid1_s_sr), mean(ghigh1_s_sr); std(glow1_s_sr), std(gmid1_s_sr), std(ghigh1_s_sr)];
       
disp(' RESULTS PART 2A: Welfare gains of removing both seasonality components (eta=1)')
disp(Results)
disp('row 1: Means. row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

% Graph of the distribution of welfare gains of removing the seasonal stochastic component
figure 
hold on
histogram(glow1_rs,'FaceColor', 'r');
hold on
histogram(gmid1_rs,'FaceColor', 'g');
hold on
histogram(ghigh1_rs,'FaceColor', 'b');
xlabel('Individual')
ylabel('Nº of households')
legend('Low seasonality','Medium seasonality','High seasonality')
title({'Welfare gains of removing stochastic seasonal component'})
print('Q1_Part2_A1','-dpng')

% Graph of the distribution of welfare gains of removing both seasonal components
figure 
hold on
histogram(glow1_s_sr,'FaceColor', 'r');
hold on
histogram(gmid1_s_sr,'FaceColor', 'g');
hold on
histogram(ghigh1_s_sr,'FaceColor', 'b');
xlabel('Individual')
ylabel('Nº of households')
legend('Low seasonality ','Medium seasonality ','High seasonality ')
title({'Welfare gains of removing both seasonal components'})
print('Q1_Part2_A2','-dpng')

%%%%%
%% PART 2B: WELFARE GAINS REMOVING NONSEASONAL RISK  %%

% Welfare gains removing non-seasonal consumption risk (eta = 1)
glow1_ind_2 = zeros(N,1);
gmid1_ind_2 = zeros(N,1);
ghigh1_ind_2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(Betas(i,:) .* log(Clow_smid_sr_r(i,:)*(1+gl))) - transpose(Betas(i,:) .* log(Clow_smid_sr(i,:))))));
    glow1_ind_2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(Betas(i,:) .* log(Cmid_smid_sr_r(i,:)*(1+gm))) - transpose(Betas(i,:) .* log(Cmid_smid_sr(i,:))))));
    gmid1_ind_2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(Betas(i,:) .* log(Chigh_smid_sr_r(i,:)*(1+gh))) - transpose(Betas(i,:) .* log(Chigh_smid_sr(i,:))))));
    ghigh1_ind_2(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results
Results = [mean(glow1_ind_2), mean(gmid1_ind_2), mean(ghigh1_ind_2); std(glow1_ind_2), std(gmid1_ind_2), std(ghigh1_ind_2)];

disp(' RESULTS PART 2B - Welfare gains of removing nonseasonal consumption risk (eta=1)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality.')
disp(' ')
disp(' ')

% Graph to compare distribution of welfare gains of removing nonseasonal consumption risk
figure
hold on
histogram(glow1_ind_2,'FaceColor', 'r');
xlabel('Individual')
ylabel('Nº of households')
legend('eta=1')
title({'Welfare gains of removing nonseasonal consumption risk'})
print('Q1_Part2_B','-dpng')


%% QUESTION 1, PART 2.D. 
% Re-do for ETA = 2 and ETA = 4

% Welfare gains removing seasonal component (eta = 2)
glow2_s2 = zeros(N,1);
gmid2_s2 = zeros(N,1);
ghigh2_s2 = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2)) ))));
glow2_s2(i,1) = fminbnd(funl,-2,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_2) / (1-eta_2))- transpose (Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2)) ))) );
gmid2_s2(i,1) = fminbnd(funm,-2,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2)) )) ));
ghigh2_s2(i,1) = fminbnd(funh,-2,5);
end

% Welfare gains removing seasonal component (eta = 4)
glow4_s2 = zeros(N,1);
gmid4_s2 = zeros(N,1);
ghigh4_s2 = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4)) ))));
glow4_s2(i,1) = fminbnd(funl,-2,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4)) ) )) );
gmid4_s2(i,1) = fminbnd(funm,-2,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4)) ))));
ghigh4_s2(i,1) = fminbnd(funh,-2,5);
end

% Results:
Results = [mean(glow2_s2), mean(gmid2_s2), mean(ghigh2_s2); ...
    mean(glow4_s2), mean(gmid4_s2), mean(ghigh4_s2)];
disp(' RESULTS PART 1.D. Mean welfare gains of removing seasonality (eta=2 and 4)')
disp(Results)
disp('Row 1: eta=2. Row 2: eta=4')
disp('Low, mid, and high seasonality')
disp(' ')
disp(' ')



% Welfare gains removing stochastic seasonal component (eta = 2)
glow2_sr = zeros(N,1); 
gmid2_sr = zeros(N,1);
ghigh2_sr = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_2) / (1-eta_2)) -  transpose(Betas(i,:) .* ((C_smid_sr_r(i,:)).^(1-eta_2) / (1-eta_2))))));
glow2_sr(i,1) = fminbnd(funl,-3,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_smid_sr_r(i,:)).^(1-eta_2) / (1-eta_2))))));
gmid2_sr(i,1) = fminbnd(funm,-3,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_2) / (1-eta_2))- transpose(Betas(i,:) .* ((C_smid_sr_r(i,:)).^(1-eta_2) / (1-eta_2)) ))));
ghigh2_sr(i,1) = fminbnd(funh,-3,5);
end


% Welfare gains removing stochastic seasonal component (eta = 4)
glow4_sr = zeros(N,1); 
gmid4_sr = zeros(N,1);
ghigh4_sr = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_smid_sr_r(i,:)).^(1-eta_4) / (1-eta_4))))));
glow4_sr(i,1) = fminbnd(funl,-3,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_smid_sr_r(i,:)).^(1-eta_4) / (1-eta_4))))));
gmid4_sr(i,1) = fminbnd(funm,-3,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_smid_sr_r(i,:)).^(1-eta_4) / (1-eta_4))))));
ghigh4_sr(i,1) = fminbnd(funh,-3,5);
end

% Results removing stochastic component (eta=2)
Results = [mean(glow2_sr), mean(gmid2_sr), mean(ghigh2_sr); std(glow2_sr), std(gmid2_sr), std(ghigh2_sr)];
disp(' RESULTS PART 2.D. Welfare gains of removing stochastic seasonal components (eta=2)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

% Results removing stochastic component (eta=4)
Results = [mean(glow4_sr), mean(gmid4_sr), mean(ghigh4_sr); std(glow4_sr), std(gmid4_sr), std(ghigh4_sr)];
disp(' RESULTS PART 2.D. removing stochastic seasonal components (eta=4)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')
  


% Welfare gains removing both seasonal components (eta = 2)
glow2_s_sr = zeros(N,1); 
gmid2_s_sr = zeros(N,1);
ghigh2_s_sr = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2)) )) ));
glow2_s_sr(i,1) = fminbnd(funl,-3,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2)) )) ));
gmid2_s_sr(i,1) = fminbnd(funm,-3,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_2) / (1-eta_2)) )) ));
ghigh2_s_sr(i,1) = fminbnd(funh,-3,5);
end

% Welfare gains removing both seasonal components (eta = 4)
glow4_s_sr = zeros(N,1); 
gmid4_s_sr = zeros(N,1);
ghigh4_s_sr = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4))))));
glow4_s_sr(i,1) = fminbnd(funl,-3,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4))))));
gmid4_s_sr(i,1) = fminbnd(funm,-3,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((C_r(i,:)).^(1-eta_4) / (1-eta_4))))));
ghigh4_s_sr(i,1) = fminbnd(funh,-3,5);
end

% Results removing both stochastic and deterministic component (eta=2):
Results = [mean(glow2_s_sr), mean(gmid2_s_sr), mean(ghigh2_s_sr); std(glow2_s_sr), std(gmid2_s_sr), std(ghigh2_s_sr)];
disp(' RESULTS PART 2.D. Welfare gains of removing both seasonality components (eta=2)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

% Results removing both stochastic and deterministic component (eta=4):
Results = [mean(glow4_s_sr), mean(gmid4_s_sr), mean(ghigh4_s_sr); std(glow4_s_sr), std(gmid4_s_sr), std(ghigh4_s_sr)];
disp(' RESULTS PART 2.D. Welfare gains of removing both seasonality components (eta=4)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')



% Welfare gains removing non-seasonal consumption risk (eta = 2)
glow2_r_q2 = zeros(N,1);
gmid2_r_q2 = zeros(N,1);
ghigh2_r_q2 = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((Clow_smid_sr(i,:)).^(1-eta_2) / (1-eta_2)) ))));
glow2_r_q2(i,1) = fminbnd(funl,-3,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((Cmid_smid_sr(i,:)).^(1-eta_2) / (1-eta_2)) ))));
gmid2_r_q2(i,1) = fminbnd(funm,-3,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_2) / (1-eta_2)) - transpose(Betas(i,:) .* ((Chigh_smid_sr(i,:)).^(1-eta_2) / (1-eta_2))))));
ghigh2_r_q2(i,1) = fminbnd(funh,-3,5);
end


% Welfare gains removing non-seasonal consumption risk (eta = 4)
glow4_r_q2 = zeros(N,1);
gmid4_r_q2 = zeros(N,1);
ghigh4_r_q2 = zeros(N,1);
for i = 1:N
funl = @(gl) abs(transpose(sum( transpose(Betas(i,:) .* ((Clow_smid_sr_r(i,:)*(1+gl))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((Clow_smid_sr(i,:)).^(1-eta_4) / (1-eta_4)) ))));
glow4_r_q2(i,1) = fminbnd(funl,-3,5);

funm = @(gm) abs(transpose(sum( transpose(Betas(i,:) .* ((Cmid_smid_sr_r(i,:)*(1+gm))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((Cmid_smid_sr(i,:)).^(1-eta_4) / (1-eta_4)) ))));
gmid4_r_q2(i,1) = fminbnd(funm,-3,5);

funh = @(gh) abs(transpose(sum( transpose(Betas(i,:) .* ((Chigh_smid_sr_r(i,:)*(1+gh))).^(1-eta_4) / (1-eta_4)) - transpose(Betas(i,:) .* ((Chigh_smid_sr(i,:)).^(1-eta_4) / (1-eta_4)) ))));
ghigh4_r_q2(i,1) = fminbnd(funh,-3,5);
end



% Results
Results = [mean(glow2_r_q2), mean(gmid2_r_q2), mean(ghigh2_r_q2); std(glow2_r_q2), std(gmid2_r_q2), std(ghigh2_r_q2)];

disp(' RESULTS PART 2.D. removing stochastic  consumption risk (eta=2)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

% Results
Results = [mean(glow4_r_q2), mean(gmid4_r_q2), mean(ghigh4_r_q2); std(glow4_r_q2), std(gmid4_r_q2), std(ghigh4_r_q2)];

disp(' RESULTS PART 2.D. removing stochastic consumption risk (eta=4)')
disp(Results)
disp('Row 1: Means. Row 2: sd')
disp('Low, Mid and High seasonality')
disp(' ')
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%


