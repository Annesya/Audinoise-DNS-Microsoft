load('NameSet');
% Clean Speech
Final_Clean_name = NameSet.Final_Clean_name;
Final_Clean_loc = NameSet.Final_Clean_loc;

% Noise
Final_Noise_name = NameSet.Final_Noise_name;
Final_Noise_loc = NameSet.Final_Noise_loc;

%RIR
Final_RIR_name = NameSet.Final_RIR_name;
Final_RIR_loc = NameSet.Final_RIR_loc;
Sim_RIR_loc = NameSet.Sim_RIR_loc;
Sim_RIR_room = NameSet.Sim_RIR_room;
Sim_RIR_name = NameSet.Sim_RIR_name;

count = 800;
for i=1:count
    fprintf(['Count is = ',num2str(i),'\n']);
    done = 0;
        clnN = randi([1 height(Final_Clean_name)],1);
        clean_aud = table2array(Final_Clean_name(clnN,1));
        clean_loc = table2array(Final_Clean_loc(clnN,1));
    
        noiseN = randi([1 height(Final_Noise_name)],1);
        noise_aud = table2array(Final_Noise_name(noiseN,1));
        noise_loc = table2array(Final_Noise_loc(noiseN,1));
        choice = randi([1 2],1);
%         choice = 2;
        if choice == 1
            chk = 0;
            while(chk~=1)
                rowN1 = randi([1 height(Final_RIR_name)],1);
                rir_aud = table2array(Final_RIR_name(rowN1,1));
                rir_loc = table2array(Final_RIR_loc(rowN1,1));
                if ((rir_aud~="noise_list")&&(rir_aud~="rir_list")&&(rir_aud~="copyname.txt"))
                    chk = 1;
                end
            end
            addpath(string(rir_loc));
            [rir,f_rir]=audioread(rir_aud);
        else
            while(done~=1)
                rowN2 = randi([1 height(Sim_RIR_loc)],1);
                rir_loc = (string(table2array(Sim_RIR_loc(rowN2,1)))+"\"+string(table2array(Sim_RIR_room(rowN2,1)))+"\");
                rir_aud = table2array(Sim_RIR_name(rowN2,1));           
                fn1 = fullfile(string(table2array(Sim_RIR_loc(rowN2,1))),string(table2array(Sim_RIR_room(rowN2,1))));
                if exist(fn1,'dir')~= 0
                    fn2 = fullfile(string(rir_loc),rir_aud);                    
                    if exist(fn2,'file')~=0
                        addpath(string(rir_loc));
                        [rir,f_rir]=audioread(rir_aud);
                        done = 1;
                    end
                end
            end
        end
    % Clean
        addpath(string(clean_loc));
        [speech,f_speech]= audioread(clean_aud);
    % Noise
        addpath(string(noise_loc));
        [noise,f_noise] = audioread(noise_aud);
        
    noisySpeech(:,i) = noisySpeechGeneration(speech,f_speech,noise,f_noise,rir,f_rir);
end
