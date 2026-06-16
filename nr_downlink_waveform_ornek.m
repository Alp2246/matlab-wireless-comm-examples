%% nr_downlink_waveform_ornek.m
% 5G Toolbox: Tek kullanıcılı aşağı bağlantı (DL) NR dalga şekli — nrWaveformGenerator
% MathWorks dokümantasyonundaki yapılandırmanın kısaltılmış hali (daha az alt çerçeve)
%
% Gerekli: 5G Toolbox

clear; clc; close all;

assert(~isempty(which('nrWaveformGenerator')), ...
    'nrWaveformGenerator bulunamadı — 5G Toolbox yüklü mü?');

%% Taşıyıcı ve BWP
carrier = nrSCSCarrierConfig('NSizeGrid', 100);
bwp     = nrWavegenBWPConfig('NStartBWP', carrier.NStartGrid + 10);

%% SS burst, CORESET, PDCCH, arama uzayı
ssb = nrWavegenSSBurstConfig('BlockPattern', 'Case A');

pdcch = nrWavegenPDCCHConfig('AggregationLevel', 2, 'AllocatedCandidate', 4);

coreset = nrCORESETConfig;
coreset.FrequencyResources = [1 1 1 1];
coreset.Duration = 3;

ss = nrSearchSpaceConfig;
ss.NumCandidates = [8 4 0 0 0];

%% PDSCH + DM-RS + PT-RS
pdsch = nrWavegenPDSCHConfig( ...
    'Modulation', '16QAM', ...
    'TargetCodeRate', 658/1024, ...
    'EnablePTRS', true);

dmrs = nrPDSCHDMRSConfig('DMRSTypeAPosition', 3);
pdsch.DMRS = dmrs;
ptrs = nrPDSCHPTRSConfig('TimeDensity', 2);
pdsch.PTRS = ptrs;

%% CSI-RS
csirs = nrWavegenCSIRSConfig( ...
    'RowNumber', 4, ...
    'RBOffset', 10, ...
    'NumRB', 10, ...
    'SymbolLocations', 5);

%% DL taşıyıcı (kısa süre: hızlı deneme için az alt çerçeve)
cfgDL = nrDLCarrierConfig( ...
    'FrequencyRange', 'FR1', ...
    'ChannelBandwidth', 40, ...
    'NumSubframes', 4, ...
    'SCSCarriers', {carrier}, ...
    'BandwidthParts', {bwp}, ...
    'SSBurst', ssb, ...
    'CORESET', {coreset}, ...
    'SearchSpaces', {ss}, ...
    'PDCCH', {pdcch}, ...
    'PDSCH', {pdsch}, ...
    'CSIRS', {csirs});

[waveform, info] = nrWaveformGenerator(cfgDL);

%% Görselleştirme
figure('Name', '5G NR DL — zaman genliği', 'Color', 'w');
plot(abs(waveform), 'LineWidth', 0.8);
xlabel('Örnek'); ylabel('|x(n)|');
title(sprintf('NR DL dalga şekli (|%d| örnek, %.0f MHz BW)', ...
    numel(waveform), cfgDL.ChannelBandwidth));
grid on;

figure('Name', '5G NR DL — bilgi özeti', 'Color', 'w');
axis off;
text(0.05, 0.9, sprintf('NumSubframes: %d', cfgDL.NumSubframes), 'FontSize', 11);
text(0.05, 0.75, sprintf('SCS: %d kHz', carrier.SubcarrierSpacing), 'FontSize', 11);
if isfield(info, 'NumSamples')
    nSamp = info.NumSamples;
else
    nSamp = numel(waveform);
end
text(0.05, 0.6, sprintf('Örnek sayısı: %d', nSamp), 'FontSize', 11);
text(0.05, 0.45, 'info yapısında ızgara / kanal ayrıntıları vardır.', 'FontSize', 11);
text(0.05, 0.25, 'Komut: openvar(''info'') veya disp(info)', 'FontSize', 10);

fprintf('5G NR aşağı bağlantı dalga şekli üretildi.\n');
fprintf('Örnek sayısı: %d — NumSubframes artırılarak daha uzun dalga şekli alınır.\n', ...
    numel(waveform));
