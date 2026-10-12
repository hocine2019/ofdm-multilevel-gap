# Adaptive bit and power loading for OFDM with a multi-level SNR gap

MATLAB code accompanying the paper *Adaptive Bit and Power Loading for OFDM
Systems with Multi-Level SNR Gap*, by H. Ait-Saadi, N. Amirouche and
F. Zoubiri (Laboratoire DIC, University of Blida 1, Algeria).

Most discrete bit-loading algorithms assume a single SNR gap, independent of
the constellation carried by each sub-channel. That assumption holds for
square M-QAM but not for M-PSK, whose gap grows with the constellation order.
This code implements a loading algorithm in which the gap is indexed on the
number of bits allocated, together with the constant-gap baselines it is
compared against.

## Requirements

MATLAB R2018a or later, with the Communications Toolbox (`qammod`, `pskmod`).
No other dependency.

## Contents

| File | Role |
| --- | --- |
| `plot_allocation.m` | bit allocation on one channel realization, proposed scheme against a constant gap |
| `plot_allocation_bmax.m` | the same realization at two constellation ceilings and two target rates |
| `config_params.m` | every system, channel and algorithm parameter; the only place to edit |
| `revlib.m` | function library: constellations, reference gap, allocators, error-rate evaluation |
| `data/h_finale.mat` | 1000 UWB CM1 channel impulse responses (Saleh–Valenzuela, residential LOS) |

## Running

From this directory:

```matlab
>> plot_allocation
>> plot_allocation_bmax
```

Each script prints a short summary and draws one figure. The channel
realization is selected by the `REALIZATION` constant at the top of each file.

## Parameters

All of them live in `config_params.m`. The defaults are those of the paper:

| | |
| --- | --- |
| Sub-channels | `N = 128`, spacing 4.125 MHz over a 528 MHz band |
| Target rate | `Bt = 358` bits per OFDM symbol |
| Constellation ceiling | `bmax = 6` (BPSK, QPSK, 8PSK, 16QAM, 32QAM, 64QAM) |
| Target symbol error rate | `1e-6` per sub-channel |
| Per-sub-channel power | −35.14 dBm, from the FCC −41.3 dBm/MHz emission limit |
| Noise PSD | −114 dBm/MHz |

Raising `bmax` to 8 adds 128QAM and 256QAM; the modulation table in
`config_params.m` is declared up to that point.

## Algorithms in `revlib.m`

| Handle | Scheme |
| --- | --- |
| `alloc_proposed` | two-stage loading under the multi-level gap table |
| `alloc_constant` | the same procedure with a single gap value, the constant-gap baseline |
| `alloc_greedy_fill` | greedy bit filling under a constant gap |
| `alloc_greedy_remove` | greedy bit removal under a constant gap |
| `alloc_papandreou` | the efficient discrete loading of Papandreou and Antonakopoulos |
| `alloc_hh` | Hughes-Hartogs loading, exhaustive one bit at a time |
| `alloc_uniform` | uniform loading, lower reference |
| `achieved_ser` | symbol error rate actually obtained, from the power allocated |

Every allocator shares the interface `[b, Pk, ops] = alloc_xxx(g, P)`, where
`g` is the 1×N gain-to-noise vector, `P` the configuration struct, `b` the
integer bit allocation, `Pk` the allocated power in watts, and `ops` a struct
of operation counters.

## Reference gap

`revlib.ref_gap(SER, M, family)` returns the SNR gap of a constellation from
its geometry rather than from a family-specific formula:

```
Gamma = 2 * [Qinv(SER/Nv)]^2 / (dmin^2 * (M-1))
```

with `dmin` the minimum distance of the constellation normalised to unit
average energy and `Nv` its mean number of nearest neighbours. This reduces to
the classical expressions for M-PSK and square M-QAM, and also covers cross
constellations such as 32QAM, for which the square M-QAM expression is not
valid.

## Reproducibility

`config_params.m` fixes the random seed (`P.seed`) and every numerical
parameter. No value is hard-coded anywhere else.

## Citing

If this code is useful to you, please cite the paper. The reference will be
added here once the article is published.

## License

See `LICENSE`.
