%% wlan_nonht_waveform_ornek.m
% WLAN Toolbox: 802.11 Non-HT (legacy) PHY — wlanWaveformGenerator
% wlanWaveformGenerator + AWGN + spektrum / zaman grafiği
%
% Gerekli: WLAN Toolbox

clear; clc; close all;

assert(~isempty(which('wlanWaveformGenerator')), ...
    'wlanWaveformGenerator bulunamadı — WLAN Toolbox yüklü mü?');

rng(7);

%% PHY yapılandırması
cfg = wlanNonHTConfig;
cfg.ChannelBandwidth = 'CBW20';   % 20 MHz
cfg.MCS = 3;                      % Modülasyon / kodlama şeması
cfg.PSDULength = 512;             % PSDU bayt (payload)

numBits = cfg.PSDULength * 8;
psduBits = randi([0 1], numBits, 1);

%% Gönderim dalga şekli
tx = wlanWaveformGenerator(psduBits, cfg);

%% Örnekleme hızı (Hz)
fs = wlanSampleRate(cfg);

%% AWGN (SNR dB, sinyal gücü normalize yaklaşımı)
snrDb = 20;
rx = awgn(tx, snrDb, 'measured');

%% Grafikler
figure('Name', 'WLAN — zaman genliği', 'Color', 'w');
t = (0:length(rx)-1) / fs;
plot(t * 1e6, abs(rx), 'b');
xlabel('Zaman (\mus)'); ylabel('|s(t)|');
title('802.11 Non-HT — alınan sinyal zarfı (AWGN sonrası)');
grid on;

figure('Name', 'WLAN — spektrum', 'Color', 'w');
nfft = 2^nextpow2(min(8192, length(rx)));
win = hamming(min(length(rx), nfft));
segment = rx(1:min(length(rx), nfft));
[pxx, f] = periodogram(segment, win, nfft, fs, 'centered');
plot(f/1e6, 10*log10(pxx + eps), 'LineWidth', 1);
xlabel('Frekans (MHz)'); ylabel('Güç spektral yoğunluğu (dB/Hz)');
title('Alınan işaret — periodogram (ortalanmış)');
grid on;

fprintf('WLAN Non-HT dalga şekli üretildi. Örnek sayısı: %d, f_s = %.3f MHz\n', ...
    length(tx), fs/1e6);
fprintf('cfg.MCS veya ChannelBandwidth değiştirip tekrar çalıştırabilirsiniz.\n');
