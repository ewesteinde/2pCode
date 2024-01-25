dbstop if error

[MenoData, nMenoData] = Group_Meno_notMeno(rootDir);

 activityVSbehaviour_PFL3Summary(MenoData ,1,'ghjg');
% 
 activityVSbehaviour_PFL3Summary(nMenoData ,0,'ghjg');

save(fullfile('Z:\2photon_data\SummaryAnalyses','PFL2MenoSumDFF.mat'),'MenoData');
save(fullfile('Z:\2photon_data\SummaryAnalyses','PFL2notMenoSumDFF.mat'),'nMenoData');