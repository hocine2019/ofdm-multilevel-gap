clear; clc; close all;

REALIZATION = 311;
BMAX = [6 8];
BT   = [358 544];

P0  = config_params();
lib = revlib();

S = load(find_channel(P0.chan_file));
Hf = abs(fft(S.h(:,REALIZATION), P0.fft_size))/sqrt(P0.fft_size);
g  = (Hf(1:P0.N).').^2 / P0.Pnoise;

b = cell(numel(BT), numel(BMAX));
for it = 1:numel(BT)
    for ib = 1:numel(BMAX)
        P = set_bmax(P0, BMAX(ib));
        P.Bt = BT(it);
        b{it,ib} = lib.alloc_proposed(g, P);
        fprintf('Bt=%d bmax=%d : %d bits, %d active\n', ...
                BT(it), BMAX(ib), sum(b{it,ib}), sum(b{it,ib}>0));
    end
end

k  = 1:P0.N;
bc = max(BMAX);
figure('Color','w','Position',[100 100 900 750]);

subplot(3,1,1);
plot(k, 10*log10(g), 'k-', 'LineWidth', 1.1);
ylabel('g_k  (dB)'); xlim([1 P0.N]); grid on; box on;
title(sprintf('Gain-to-noise ratio, realization %d', REALIZATION));

for it = 1:numel(BT)
    subplot(3,1,it+1);
    stairs(k, b{it,1}, 'k-', 'LineWidth', 1.3); hold on;
    stairs(k, b{it,2}, '--', 'Color', [0.58 0.58 0.58], 'LineWidth', 1.1);
    yline(BMAX(1), ':k'); yline(BMAX(2), ':', 'Color', [0.58 0.58 0.58]);
    hold off;
    ylabel('Bits b_k'); xlim([1 P0.N]);
    ylim([-0.4 bc+0.6]); yticks(0:bc);
    legend(sprintf('b_{max} = %d', BMAX(1)), ...
           sprintf('b_{max} = %d', BMAX(2)), ...
           'Location','northeast'); grid on; box on;
    title(sprintf('Bit allocation, B_t = %d', BT(it)));
    if it == numel(BT); xlabel('Sub-channel index k'); end
end

function P = set_bmax(P0, bmax)
P = P0;
P.bmax     = bmax;
P.levels   = P0.levels(1:bmax);
P.Gap_l    = P0.Gap_l(1:bmax);
P.Gap_l_dB = P0.Gap_l_dB(1:bmax);
end

function f = find_channel(name)
cand = { fullfile('data',name), name };
for i = 1:numel(cand)
    if exist(cand{i},'file'); f = cand{i}; return; end
end
error('Channel file ''%s'' not found.', name);
end
