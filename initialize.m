warning('off','all')
%clear classes
clear
clc
path_datasets = 'datasets/';
path_tr_indices = 'indices/';
path_init_pool = 'initial_pool/';
dataset = {[path_datasets 'ringnorm.mat'];[path_datasets 'autos.mat'];[path_datasets 'hardware.mat'];[path_datasets 'sport.mat'];[path_datasets '3vs5.mat'];[path_datasets '4vs9.mat']};
names = {'ringnorm';'autos';'hardware';'sport';'3vs5';'4vs9'};
dataset_names = {'ringnorm.mat';'autos.mat';'hardware.mat';'sport.mat';'3vs5.mat';'4vs9.mat'};
random_indices = {[path_tr_indices 'indices-ringnorm.mat'];[path_tr_indices 'indices-autos.mat'];[path_tr_indices 'indices-hardware.mat'];[path_tr_indices 'indices-sport.mat'];[path_tr_indices 'indices-3vs5.mat'];[path_tr_indices 'indices-4vs9.mat']};
init_pool = {[path_init_pool 'ringnorm_init.mat'];[path_init_pool 'autos_init.mat'];[path_init_pool 'hardware_init.mat'];[path_init_pool 'sport_init.mat'];[path_init_pool '3vs5_init.mat'];[path_init_pool '4vs9_init.mat']};
name_dir = 'RESULTS';
mkdir(name_dir);
for d=1:size(names,1)
        name = names{d};
        disp(name);
        
        run('dataset_experimenter');
        cd(name_dir);
        save(name, 'accuracy', 'accuracy_dbalevs', 'accuracy_uncertainty', 'accuracy_random', 'accuracy_topleverage', 'accuracy_nearopt', 'time_dbalevs', 'time_nearopt', 'time_random', 'time_uncertainty', 'time_topleverage', 'time_topleverage_compute');
        cd ..;

        
end
warning('on','all')
