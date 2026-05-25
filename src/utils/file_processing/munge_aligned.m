function path_table_series = munge_aligned(config)
%From alignment step

% Remove unnecessary fields
fields_to_remove = {'folder','date','isdir','bytes','datenum'};

% Get directory contents: debug
%paths_sub = dir(fullfile(config.output_directory,'aligned'));
paths_sub = dir(fullfile(config.output_directory, 'aligned', '**', '*.tif'));

% Check .tif in current folder: debug
%paths_sub = paths_sub(arrayfun(@(x) contains(x.name,'.tif'),paths_sub));
paths_sub = paths_sub(~startsWith({paths_sub.name}, '._'));

if isempty(paths_sub)
    path_table_series = [];
    return
end

if isequal(config.hierarchy_input, "true")
    % Hierarchy mode: aligned files are written as
    %   aligned/{marker}/{y_pos}/{y_pos}_{x_pos}/{y_pos}_{x_pos}_{z_pos}.tif
    % y_pos/x_pos values are the reference channel's raw coordinates
    % (already jitter-corrected), so they are consistent across channels.

    n = length(paths_sub);
    file        = cell(n, 1);
    markers     = strings(n, 1);
    channel_num = zeros(n, 1);
    y_pos       = zeros(n, 1);
    x_pos       = zeros(n, 1);
    z_pos       = zeros(n, 1);

    for k = 1:n
        file{k} = fullfile(paths_sub(k).folder, paths_sub(k).name);

        % Extract marker from folder: .../aligned/{marker}/{y_pos}/{y_pos_x_pos}/
        y_x_folder  = paths_sub(k).folder;
        y_folder    = fileparts(y_x_folder);
        marker_folder = fileparts(y_folder);
        [~, marker_name] = fileparts(marker_folder);
        markers(k) = string(marker_name);

        % Extract raw coordinates from filename: {y_pos}_{x_pos}_{z_pos}.tif
        tok = regexp(paths_sub(k).name, '^(\d+)_(\d+)_(\d+)\.tif$', 'tokens', 'once');
        if ~isempty(tok)
            y_pos(k) = str2double(tok{1});
            x_pos(k) = str2double(tok{2});
            z_pos(k) = str2double(tok{3});
        end

        % Map marker name to channel index
        ch_idx = find(config.markers == markers(k), 1);
        if ~isempty(ch_idx)
            channel_num(k) = ch_idx;
        end
    end

    % Normalize to tile indices using the same logic as munge_raw.
    % Step is computed from original (non-flipped) coordinate values.
    tmp_y = unique(y_pos);
    step_y = (length(tmp_y) > 1) * (max(tmp_y) - min(tmp_y)) / max(length(tmp_y) - 1, 1) + ...
             (length(tmp_y) == 1) * 1;

    tmp_x = unique(x_pos);
    step_x = (length(tmp_x) > 1) * (max(tmp_x) - min(tmp_x)) / max(length(tmp_x) - 1, 1) + ...
             (length(tmp_x) == 1) * 1;

    tmp_z = unique(z_pos);
    step_z = (length(tmp_z) > 1) * (max(tmp_z) - min(tmp_z)) / max(length(tmp_z) - 1, 1) + ...
             (length(tmp_z) == 1) * 1;

    % Apply axis direction flips before normalization (matches munge_raw)
    y_vals = y_pos;
    x_vals = x_pos;
    if isequal(config.y_top2bottom, "false")
        y_vals = -y_vals;
    end
    if isequal(config.x_left2right, "false")
        x_vals = -x_vals;
    end

    y_idx = round((y_vals - min(y_vals)) / step_y) + 1;
    x_idx = round((x_vals - min(x_vals)) / step_x) + 1;
    z_idx = round((z_pos  - min(z_pos))  / step_z) + 1;

    sample_id_col = repmat(string(config.sample_id), n, 1);

    path_table_series = table(file, sample_id_col, markers, channel_num, ...
        y_idx, x_idx, z_idx, y_pos, x_pos, z_pos, ...
        'VariableNames', {'file', 'sample_id', 'markers', 'channel_num', ...
                          'y', 'x', 'z', 'y_pos', 'x_pos', 'z_pos'});

else
    % Non-hierarchy mode: flat aligned directory.
    % Fix: use each file's own folder (not paths_sub(1).folder).
    C = arrayfun(@(x) fullfile(x.folder, x.name), paths_sub, 'UniformOutput', false);
    [paths_sub.file] = C{:};

    paths_sub = rmfield(paths_sub, fields_to_remove);

    % Generate table components
    components = arrayfun(@(s) strsplit(s.name, {char(config.sample_id), '_', '.'}), paths_sub, 'UniformOutput', false);
    components = vertcat(components{:});

    assert(size(components,1) > 0, "Could not recognize any aligned files by filename structure")
    assert(length(unique(components(:,1))) == 1, "Multiple sample ids found in image path")

    %Take image information
    for i = 1:length(paths_sub)
        paths_sub(i).sample_id = string(config.sample_id);
        paths_sub(i).markers = string(components{i,4});
    end

    positions = cellfun(@(s) str2double(s), components(:,[6,5,2]), 'UniformOutput', false);
    channel_num = cellfun(@(s) str2double(s(2)), components(:,3), 'UniformOutput', false);
    [paths_sub.channel_num] = channel_num{:,1};

    [paths_sub.y] = positions{:,2};
    [paths_sub.x] = positions{:,1};
    [paths_sub.z] = positions{:,3};

    path_table_series = struct2table(rmfield(paths_sub, {'name'}));

end

end
