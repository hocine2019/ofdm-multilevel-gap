function P = config_params()
%CONFIG_PARAMS  
%
%   OUTPUT
%     P : struct with fields
%         .N, .Bt, .bmax          system / loading parameters
%         .SER_target             per-subcarrier target symbol error rate
%         .Pbar, .Pnoise          power constraint and noise power (W)
%         .levels                 1xL struct array describing each level
%         .Gap_l, .Gap_l_dB       reference SNR gap per level
%         .Gap_const, ...         constant gap used by the baseline
%         .n_real, .seed          Monte-Carlo settings
%         .chan_file, .fft_size   channel data
%
%   Author : H. Ait-Saadi et al. -- Revision 2026
%   Requires: MATLAB R2018a+ and Communications Toolbox (qammod).

%% ---- System and loading -------------------------------------------------
P.N    = 128;          % number of OFDM sub-channels
P.Bt   = 358;          % target rate, bits per OFDM symbol
P.bmax = 8;            % maximum bits per sub-channel

%% ---- Error-rate constraint ---------------------------------------------
% The imposed constraint is a per-subcarrier SYMBOL error rate.

P.SER_target = 1e-6;

% Optional constant-BER mode. If P.ber_mode is true, the target SER of

P.ber_mode   = false;
P.BER_target = 1e-6;

%% ---- Power constraints (FCC, IEEE 802.15.3a) ---------------------------
Pbar_dBm   = -35.14;                  % max transmit power per sub-channel
N0_dBm_MHz = -114;                    % noise power spectral density
Bsub_MHz   = 4.125;                   % sub-channel spacing

P.Pbar   = 10^((Pbar_dBm - 30)/10);                       % W
P.Pnoise = 10^((N0_dBm_MHz + 10*log10(Bsub_MHz) - 30)/10);% W
P.Pbar_dBm    = Pbar_dBm;
P.Ptot_max_dBm = Pbar_dBm + 10*log10(P.N);   % total power budget

%% ---- Modulation levels -------------------------------------------------
% Level l carries l bits. Levels 1-3 are M-PSK (constant envelope, useful
% under non-linear amplification); levels 4-6 are M-QAM, which offers a
% markedly smaller gap for M >= 16. Justifies reviewer comment R1-C6.
% The table is declared up to 8 bits so that a denser constellation set
% can be selected by raising P.bmax alone; only the first P.bmax entries
% are used. Levels 7 and 8 are the cross 128QAM and the square 256QAM.
% NOTE. P.bmax = 6 is the setting of the reported campaign. Raising it to
% 8 changes L_max, the decomposition (c,d), the operation counts and the
% saturation limit N*bmax, so every result must be regenerated.
names  = {'BPSK','QPSK','8PSK','16QAM','32QAM','64QAM','128QAM','256QAM'};
family = {'psk' ,'psk' ,'psk' ,'qam'  ,'qam'  ,'qam'  ,'qam'   ,'qam'   };

L = P.bmax;
if L > numel(names)
    error(['config_params: P.bmax = %d exceeds the %d constellations ' ...
           'declared in the modulation table.'], L, numel(names));
end
P.levels = struct('bits',{},'M',{},'name',{},'family',{});
for l = 1:L
    P.levels(l).bits   = l;
    P.levels(l).M      = 2^l;
    P.levels(l).name   = names{l};
    P.levels(l).family = family{l};
end

%% ---- Reference SNR gap per level ---------------------------------------
% Computed from the constellation itself (see revlib/ref_gap), so that
% square QAM, cross QAM (32QAM) and M-PSK are all handled consistently.

lib = revlib();
P.Gap_l = zeros(1,L);
for l = 1:L
    if P.ber_mode
        ser_l = l * P.BER_target;      % Gray mapping, high SNR
    else
        ser_l = P.SER_target;
    end
    P.Gap_l(l) = lib.ref_gap(ser_l, P.levels(l).M, P.levels(l).family);
end
P.Gap_l_dB = 10*log10(P.Gap_l);

%% ---- Constant-gap baseline ---------------------------------------------
% The baseline uses one single gap for every level, taken as the M-QAM
% value. This is the assumption made by all constant-gap algorithms.
P.Gap_const    = P.Gap_l(4);           % 16QAM gap
P.Gap_const_dB = 10*log10(P.Gap_const);

%% ---- Channel -----------------------------------------------------------
P.chan_file = 'h_finale.mat';   % variable h : (taps x realizations)
P.fft_size  = 256;              % FFT length used to obtain H from h
P.n_real    = 1000;             % Monte-Carlo realizations 
P.seed      = 20260808;         % fixed seed for reproducibility

%% ---- Output ------------------------------------------------------------
P.outdir = fullfile(pwd, 'results');
if ~exist(P.outdir, 'dir'); mkdir(P.outdir); end

end
