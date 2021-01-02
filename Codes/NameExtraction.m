% Final_Clean = table2array(DatasetAnnotation);
% Final_Clean_name = Final_Clean(:,1);
% Final_Clean_loc = Final_Clean(:,2);
% Final_Noise = table2array(DatasetAnnotationS1);
% Final_Noise_name = Final_Noise(:,1);
% Final_Noise_loc = Final_Noise(:,2);
% Final_RIR = table2array(DatasetAnnotationS2);
% Final_RIR_name = Final_RIR(:,1);
% Final_RIR_loc = Final_RIR(:,2);
% RIR = table2array(DatasetAnnotationS3);
% RIR_loc = RIR(:,2);

Final_Clean = (DatasetAnnotation);
Final_Clean_name = Final_Clean(:,1);
Final_Clean_loc = Final_Clean(:,2);
Final_Noise = (DatasetAnnotationS1);
Final_Noise_name = Final_Noise(:,1);
Final_Noise_loc = Final_Noise(:,2);
Final_RIR = (DatasetAnnotationS2);
Final_RIR_name = Final_RIR(:,1);
Final_RIR_loc = Final_RIR(:,2);
RIR = (DatasetAnnotationS3);
RIR_loc = RIR(:,2);

NameSet = [];
NameSet.Final_Clean_name = Final_Clean_name;
NameSet.Final_Clean_loc = Final_Clean_loc;
NameSet.Final_Noise_name = Final_Noise_name;
NameSet.Final_Noise_loc = Final_Noise_loc;
NameSet.Final_RIR_name = Final_RIR_name;
NameSet.Final_RIR_loc = Final_RIR_loc;
NameSet.RIR_loc = RIR_loc;
%%
Final_Clean = (FinalAnnotation);
Final_Clean_name = Final_Clean(:,1);
Final_Clean_loc = Final_Clean(:,2);
Final_Noise = (FinalAnnotationS1);
Final_Noise_name = Final_Noise(:,1);
Final_Noise_loc = Final_Noise(:,2);
Final_RIR = (FinalAnnotationS2);
Final_RIR_name = Final_RIR(:,1);
Final_RIR_loc = Final_RIR(:,2);
RIR = (FinalAnnotationS3);
Sim_RIR_name = RIR(:,3);
Sim_RIR_loc = RIR(:,1);
Sim_RIR_room = RIR(:,2);
NameSet = [];
NameSet.Final_Clean_name = Final_Clean_name;
NameSet.Final_Clean_loc = Final_Clean_loc;
NameSet.Final_Noise_name = Final_Noise_name;
NameSet.Final_Noise_loc = Final_Noise_loc;
NameSet.Final_RIR_name = Final_RIR_name;
NameSet.Final_RIR_loc = Final_RIR_loc;
NameSet.Sim_RIR_name = Sim_RIR_name;
NameSet.Sim_RIR_loc = Sim_RIR_loc;
NameSet.Sim_RIR_room = Sim_RIR_room;

%% Evaluation Set
devset = FinalAnnotationS4;
DevSet = [];
DevSet.name = devset(:,1);
DevSet.loc = devset(:,2);
save('DevSet','DevSet')