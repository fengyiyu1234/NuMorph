# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NuMorph is a MATLAB-based pipeline for processing and analyzing multi-channel light-sheet microscopy images of cleared tissue (primarily mouse brain). It handles channel alignment, intensity adjustment, stitching, atlas registration, cell detection, and statistical analysis.

## Running the Pipeline

This is a pure MATLAB project with no build step. Run from the MATLAB command window:

```matlab
% Single sample
sample = 'TSC_10';
[config, path_table] = NM_config('process', sample);
[config, path_table] = perform_channel_alignment(config, path_table, 'True');

% Batch processing
NM_batch  % iterates over samples defined in NM_samples.m

% Full single-sample run
NM_run
```

Stages passed to `NM_config`: `'process'`, `'analyze'`, `'evaluate'`.

## Architecture

The pipeline has three stages, each driven by a config template:

| Stage | Entry Point | Template | Purpose |
|---|---|---|---|
| Process | `NM_process.m` | `NMp_template.m` | Channel alignment, intensity correction, stitching |
| Analyze | `NM_analyze.m` | `NMa_template.m` | Resampling, atlas registration, cell detection/classification |
| Evaluate | `analysis/regionAnaly.m` | `NMe_template.m` | Regional/voxel-wise statistics and visualization |

**Configuration flow:** `NM_config.m` loads the appropriate template + sample metadata from `NM_samples.m`, validates parameters, and saves to `data/tmp/NM_variables.mat`. All pipeline functions receive the `config` struct.

**Path table system:** `path_to_table(config)` scans image directories and produces a table mapping each `.tif` file to its channel and grid (x,y,z) position. Coordinates are clustered with spatial tolerance to handle stage jitter. The path table is passed through all processing functions.

### Key source directories

- `src/pipelines/` — orchestration scripts (`NM_process.m`, `perform_channel_alignment.m`, `perform_intensity_adjustment.m`)
- `src/preprocessing/` — 85+ image processing functions (alignment, stitching, shading correction, blending)
- `src/utils/` — utility functions (path handling, Elastix/Conda setup, Imaris export)
- `src/external/elastix/` — Elastix binary + melastix MATLAB wrapper
- `analysis/` — post-registration quantification (`regionAnaly.m`, `voxelAnaly.m`, `VisQuint/`)

### User-facing configuration files (edit these for each experiment)

- **`templates/NM_samples.m`** — per-sample metadata: image/output directories, group labels, channel names, regex patterns for position parsing, resolution, orientation
- **`templates/NMp_template.m`** — ~100 processing parameters: alignment method (`'translation'`/`'elastix'`), intensity adjustment flags, stitching settings
- **`templates/NMa_template.m`** — analysis parameters: resampling resolution, atlas selection, cell detection method (`'3dunet'`/`'hessian'`), classification approach
- **`templates/NMe_template.m`** — evaluation parameters: brain structures to compare, cell-type classes, output directory

### Channel alignment

Two methods controlled by `align_method` in `NMp_template.m`:
- **`'translation'`** — phase correlation (`calculate_phase_correlation.m`), fast, rigid
- **`'elastix'`** — B-spline non-rigid registration via `elastix_channel_alignment.m`; requires Elastix binary in `src/external/elastix/` and correct path in `NM_config.m`

### External dependencies

- **Elastix** — binary at `src/external/elastix/`; paths set in `NM_config.m` via `add_elastix_to_path.m`
- **Conda/Python** — optional, needed only for 3D U-Net cell detection; default path `C:\Users\IMARIS\Anaconda3`, configured via `add_conda_to_path.m`
- **VLFeat** — bundled in `src/external/`, used for SIFT-based stitching refinement

### Data directories (git-ignored, must be provided locally)

- `data/atlas/` — reference atlas `.nii` files
- `data/annotation_data/` — brain region annotation `.mat` files
- `data/tmp/` — runtime variables (`NM_variables.mat`)
- `annotations/structure_template.csv` — brain region ID mapping (committed)

## Important conventions

- Processing functions take `(config, path_table)` and return the same, possibly modified.
- `config` is a struct; fields correspond directly to template parameter names.
- The path table has columns: `file` (full path), `channel`, `x`, `y`, `z` (grid indices).
- Elastix parameter files live in `data/elastix_parameter_files/` and are referenced by name in `NMp_template.m`.
- Large image files (`.tif`, `.nii`, `.h5`) and `test/`, `results/`, `patches/`, `extras/` directories are git-ignored.
