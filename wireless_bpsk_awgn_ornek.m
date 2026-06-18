%% wireless_bpsk_awgn_ornek.m
% Kablosuz dijital iletişim: BPSK modülasyonu + AWGN kanal + BER eğrisi
% Gerekli: yalnızca temel MATLAB (Communications Toolbox şart değil)
%
% MATLAB'de çalıştırmak için: Bu dosyayı açıp F5 veya "Run" ile çalıştırın.

clear; clc; close all;

%% Parametreler
numBits      = 5e5;              % Her SNR noktasında simüle edilecek bit sayısı
EbNo_dB      = 0:2:12;           % Eb/N0 (dB) — bit başına sinyal/gürültü oranı
useRayleigh  = false;            % true yapın: düz sönümlemeli (flat) Rayleigh kanalı

rng(42);                         % Tekrarlanabilir sonuçlar

%% Eb/N0 döngüsü
ber_sim = zeros(size(EbNo_dB));

for k = 1:length(EbNo_dB)
    EbNo_lin = 10^(EbNo_dB(k)/10);

    % BPSK: bit 0 -> -1, bit 1 -> +1 (sembol enerjisi Eb = 1)
    bitsTx = randi([0 1], numBits, 1);
    symTx  = 2*bitsTx - 1;

    if useRayleigh
        % Yavaş sönümleme: her blok için sabit h (basit flat Rayleigh)
        h = (randn + 1j*randn) / sqrt(2);   % E[|h|^2] = 1
        symFaded = h * symTx;
        sigma = sqrt(1 / (2*EbNo_lin));     % AWGN, Eb=1
        noise = sigma * (randn(size(symFaded)) + 1j*randn(size(symFaded)));
        symRx = symFaded + noise;
        % Tam kanal bilgisi (CSI): eşitleme
        symEq = real(symRx / h);
    else
        % Sadece AWGN (Addictive White Gaussian Noise)
        sigma = sqrt(1 / (2*EbNo_lin));
        noise = sigma * randn(size(symTx));
        symEq = symTx + noise;
    end

    bitsRx = double(symEq >= 0);
    ber_sim(k) = mean(bitsRx ~= bitsTx);
end

%% Teorik BPSK BER (AWGN, koherent alım) — Rayleigh kapalıyken simülasyonla örtüşür
ber_theory = 0.5 * erfc(sqrt(10.^(EbNo_dB/10)));

%% Grafik
figure('Name', 'Kablosuz BPSK — BER vs Eb/N0', 'Color', 'w');
semilogy(EbNo_dB, max(ber_sim, 1e-6), 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
if ~useRayleigh
    semilogy(EbNo_dB, ber_theory, 'k--', 'LineWidth', 1.2);
end
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Bit hata oranı (BER)');
if useRayleigh
    baslik = 'AWGN + Rayleigh (teorik çizgi gösterilmedi)';
else
    baslik = 'Sadece AWGN';
end
title(sprintf('BPSK — %s', baslik));
if useRayleigh
    legend('Simülasyon', 'Location', 'southwest');
else
    legend('Simülasyon', 'Teorik (AWGN)', 'Location', 'southwest');
end
ylim([1e-5 1]);

if exist('save_github_figure', 'file') == 2
    save_github_figure(gcf, 'bpsk_ber_awgn');
end

fprintf('BPSK + AWGN örneği tamamlandı.\n');
fprintf('useRayleigh = true yaparak düz Rayleigh kanalını da deneyebilirsiniz.\n');

%% --- Communications Toolbox varsa (isteğe bağlı) ---
% Aşağıdaki satırlar toolbox yüklüyse benzer sonucu sistem nesneleriyle verir:
%
%   mod = comm.BPSKModulator;
%   dem = comm.BPSKDemodulator;
%   ch  = comm.AWGNChannel('EbNo', 8, 'BitsPerSymbol', 1);
%   x   = mod(bitsTx);
%   y   = ch(x);
%   b   = dem(y);
