clear; clc; close all;

REALIZATION = 311;

P   = config_params();
lib = revlib();

S = load(find_channel(P.chan_file));
Hf = abs(fft(S.h(:,REALIZATION), P.fft_size))/sqrt(P.fft_size);
g  = (Hf(1:P.N).').^2 / P.Pnoise;

[bp, Pp] = lib.alloc_proposed(g, P);
[bc, Pc] = lib.alloc_constant(g, P);

fprintf('bits   : %d / %d\n', sum(bp), sum(bc));
fprintf('active : %d / %d\n', sum(bp>0), sum(bc>0));
fprintf('power  : %.3f / %.3f dBm\n', ...
        10*log10(sum(Pp))+30, 10*log10(sum(Pc))+30);

k = 1:P.N;
figure('Color','w','Position',[100 100 900 500]);

subplot(2,1,1);
plot(k, 10*log10(g), 'k-', 'LineWidth', 1.1);
ylabel('g_k  (dB)'); xlim([1 P.N]); grid on; box on;
title(sprintf('Gain-to-noise ratio, realization %d', REALIZATION));

subplot(2,1,2);
stairs(k, bp, 'k-',  'LineWidth', 1.3); hold on;
stairs(k, bc, '--', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.1); hold off;
xlabel('Sub-channel index k'); ylabel('Bits b_k');
xlim([1 P.N]); ylim([-0.3 P.bmax+0.3]); yticks(0:P.bmax);
legend('Proposed (multi-level gap)','Constant gap', ...
       'Location','northeast'); grid on; box on;
title('Bit allocation');

function f = find_channel(name)
cand = { fullfile('data',name), name };
for i = 1:numel(cand)
    if exist(cand{i},'file'); f = cand{i}; return; end
end
error('Channel file ''%s'' not found.', name);
end
