function export_all_results()
%EXPORT_ALL_RESULTS Tum demoları calistirir, acik figurleri results/ altina kaydeder.

root = fileparts(mfilename('fullpath'));
jobs = {
    'wireless_bpsk_awgn_ornek',      'bpsk_ber_awgn'
    'comm_toolbox_qpsk_awgn_ornek',  'qpsk_ber_awgn'
    'wlan_nonht_waveform_ornek',     'wlan_nonht'
    'nr_downlink_waveform_ornek',    'nr_downlink'
};

for k = 1:size(jobs, 1)
    try
        run_demo_and_save(root, jobs{k, 1}, jobs{k, 2});
    catch ME
        fprintf('ATLANDI %s: %s\n', jobs{k, 1}, ME.message);
    end
end

fprintf('\nWireless export bitti: %s\n', fullfile(root, 'results'));
end

function run_demo_and_save(root, scriptName, tag)
cd(root);
addpath(root);
close all;
run_demo_isolated(fullfile(root, [scriptName '.m']));
save_open_figures(root, tag);
end

function run_demo_isolated(scriptPath)
run(scriptPath);
end

function save_open_figures(root, tag)
figs = findall(0, 'Type', 'figure');
figs = flipud(figs);
for fi = 1:numel(figs)
    if numel(figs) == 1
        name = tag;
    else
        name = sprintf('%s_fig%d', tag, fi);
    end
    save_github_figure(figs(fi), name);
end
end
