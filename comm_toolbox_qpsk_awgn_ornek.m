%% comm_toolbox_qpsk_awgn_ornek.m
% Communications Toolbox: QPSK + comm.AWGNChannel + comm.ErrorRate
% BER vs Eb/N0 (sistem nesneleriyle)
%
% Gerekli: Communications Toolbox

clear; clc; close all;

assert(~isempty(which('pskmod')) && ~isempty(which('comm.AWGNChannel')), ...
    'pskmod veya comm.AWGNChannel yok — Communications Toolbox yüklü mü?');

rng(2025);

%% Nesneler (QPSK: pskmod/pskdemod; kanal: comm.AWGNChannel)
errorRate = comm.ErrorRate;
M         = 4;   % QPSK

numFrames   = 2000;
frameLength = 1000;          % bit (QPSK -> 500 sembol)
EbNo_dB     = 0:2:14;
ber_sim     = nan(size(EbNo_dB));

for k = 1:length(EbNo_dB)
    errorRate.reset;
    awgnChannel = comm.AWGNChannel('EbNo', EbNo_dB(k), 'BitsPerSymbol', 2);

    for f = 1:numFrames
        bitsIn = randi([0 1], frameLength, 1);
        symTx  = pskmod(bitsIn, M, InputType='bit');
        symRx  = awgnChannel(symTx);
        bitsOut = pskdemod(symRx, M, OutputType='bit');
        errStat = errorRate(bitsIn, bitsOut);
    end
    ber_sim(k) = errStat(1);
end

% Gray eşlemeli QPSK için BER, BPSK ile aynı kapalı form (yaklaşık)
EbNo_lin   = 10.^(EbNo_dB/10);
ber_theory = 0.5 * erfc(sqrt(EbNo_lin));

%% Grafik
figure('Name', 'Communications Toolbox — QPSK AWGN', 'Color', 'w');
semilogy(EbNo_dB, max(ber_sim, 1e-6), 's-', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on;
semilogy(EbNo_dB, ber_theory, 'k--', 'LineWidth', 1.2);
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('BER');
title('QPSK — pskmod / comm.AWGNChannel / pskdemod');
legend('Simülasyon', 'Teorik (Gray QPSK)', 'Location', 'southwest');
ylim([1e-5 1]);

%% Tek SNR değerinde takımyıldız (görsel)
Eb0 = 12;
awgn0 = comm.AWGNChannel('EbNo', Eb0, 'BitsPerSymbol', 2);
bits0 = randi([0 1], 3000, 1);
sym0  = awgn0(pskmod(bits0, M, InputType='bit'));
figure('Name', 'QPSK takımyıldızı (örnek)', 'Color', 'w');
plot(real(sym0), imag(sym0), '.', 'MarkerSize', 8);
grid on; axis equal;
xlabel('I'); ylabel('Q');
title(sprintf('Alınan QPSK (E_b/N_0 = %d dB)', Eb0));

fprintf('Communications Toolbox QPSK örneği tamamlandı.\n');
