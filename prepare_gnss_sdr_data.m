%% prepare_gnss_sdr_data.m
% JKS ham GPS örneğini (indirdiyseniz) int8 akışına çevirir; SoftGNSS initSettings bu dosyayı kullanır.
%
% MATLAB Geçerli Klasör: Matlab_Kodları (bu dosyanın olduğu yer).

clearvars -except settings
clc;

rootRecords = fullfile(fileparts(mfilename('fullpath')), 'GNSS_signal_records');
srcName     = 'gps.samples.1bit.I.fs5456.if4092.bin';
dstName     = 'gps_jks_int8.bin';
srcPath     = fullfile(rootRecords, srcName);
dstPath     = fullfile(rootRecords, dstName);

if exist(rootRecords, 'dir') ~= 7
    error('Klasor yok: %s', rootRecords);
end

if exist(srcPath, 'file') ~= 2
    error(['Ham dosya yok: %s\n' ...
        'İndir: http://www.jks.com/gps/gps.samples.1bit.I.fs5456.if4092.bin'], srcPath);
end

addpath(rootRecords);
fprintf('Dönüştürülüyor (birkaç dakika sürebilir, ~450 MB int8 çıktı)...\n');
unpack_jks_1bit_to_int8(srcPath, dstPath);

fprintf('\nSonraki adım:\n');
fprintf('  cd(''%s'')\n', fullfile(fileparts(mfilename('fullpath')), 'GNSS_SDR-master'));
fprintf('  init\n');
