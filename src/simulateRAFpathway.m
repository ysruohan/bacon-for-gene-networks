%% rafnet = [1 0 0 0 0 0 0 0 0 0 0; % PIP3
%% 	  1 0 1 0 0 0 0 0 0 0 0; % PIP2
%% 	  1 0 0 0 0 0 0 0 0 0 0; % PLCG
%% 	  0 1 1 0 0 0 0 0 0 0 0;
%% 	  0 0 0 1 0 0 0 0 0 0 0;
%% 	  0 0 0 1 0 0 0 0 0 0 0;
%% 	  0 0 0 1 0 0 0 0 0 0 0;
%% 	  0 0 0 1 0 0 0 0 0 0 0;
%% 	  0 0 0 1 0 0 0 0 0 0 0;
%% 	  0 0 0 0 0 0 0 0 0 0 0;
%% 	  0 0 0 0 0 0 0 0 0 0 0 ]

rafnet = zeros(11);

rafnet( [1:3 11] ,1) = 1;
rafnet(3:4,2) = 1;
rafnet(4,3) = 1;
rafnet(5:9,4) = 1;
rafnet(8,7) = 1;
rafnet(10,8) = 1;
rafnet( [5:8 10:11] ,9) = 1;
rafnet(11,10) = 1;

%% %% model parameters used in Grzegorcyzk & Husmeier
%% autocorstrength = 0.25;
%% snr = 10;
%% 
%% %% more parameters
%% nclus = 11;
%% numreps = 3;
%% genesperclus = 3;
%% timepoints = 21;

%% clusternumbers = nclus;


rafnet10 = blkdiag(rafnet,rafnet,rafnet,
		   rafnet,rafnet,rafnet,
		   rafnet,rafnet,rafnet,
		   rafnet);
rafnet100 = blkdiag(rafnet10,rafnet10,rafnet10,
		    rafnet10,rafnet10,rafnet10,
		    rafnet10,rafnet10,rafnet10,
		    rafnet10);

if numRAFpathways==1
  rafnetMULTI = rafnet;
elseif numRAFpathways==10
    rafnetMULTI = rafnet10;
elseif numRAFpathways==100
    rafnetMULTI = rafnet100;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
simSmat = rafnetMULTI .* ((rand(nclus)*1.5+0.5).*sign(rand(nclus)-0.5));
simSmat(1,1) = (1-autocorstrength^2)^0.5;

Sconst = 0; %10*normrnd(0,1,nclus,1);
%%time0 = ones(nclus,1); 
time0 = normrnd(0,1,nclus,1);

simF = time0;
for i = 2:timepoints
    simF = [ simF simSmat*simF(:,i-1)+Sconst ];
end

%% simF = simF + normrnd(0,0.0001,size(simF));
%%simF = simF + simF .* normrnd(0,1/snr,size(simF));

%% for i = 1:size(simF,1)
%%   ab = simF(i,:) - mean(simF(i,:));
%%   ac = ab ./ std(ab);
%%   simF(i,:) = ac;
%% end

simMship = zeros(nclus,nclus*genesperclus);
for i = 1:nclus
    simMship(i,(i-1)*genesperclus+(1:3)) = 1;
end

% simMU = [];
% for i = 1:size(simF,1)
%     simMU = [ simMU repmat(simF(i,:)', 1 ,genesperclus) ];
% end

simMU = simF'*simMship;
%%simMU = simMU + normrnd( 0, 0.1, size(simMU) );

% D = [];
% for i = 1:size(simF,1)
%     D = [ D repmat(simF(i,:)',numreps,genesperclus) ];
% end
D = repmat( simMU, numreps, 1 );
D = D + normrnd( 0, 1/snr, size(D) );
