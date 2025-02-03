%% reigon-wise visualization

downsample_factor = 0.1;
load(fullfile('annotationData.mat'),'annotationVolume')
I_annotation = permute_orientation(annotationVolume,'sla','spl'); % sagittal
[nrows,ncols,nslices] = size(I_annotation);
nslices = nslices * downsample_factor;
I_annotation = imresize3(I_annotation,[nrows,ncols,nslices],'Method','nearest');

df_template = readtable('structure_template.csv');

% colorbar blue-red
budam = flip(buda(198),1);
BuRd = flip(brewermap(198,'RdBu'),1);


%% plot on 2D

df_quint = readtable('A0247-cfos_RefAtlasRegions.csv'); % data

for z = [10, 20, 30, 40]
    vis = I_annotation(:,:,z);
    % boundaries = zeros(size(vis),'logical');
    mask = vis>0;

    % density (percentage)
    
    density_header = 'Load';
    density_map = zeros(size(vis));
    % for i = 2:length(df_template.id)
    for i = [4:555,557:561,1106:1113,1192:1200] % regions of interest
        if (df_quint.(density_header)(i+1) ~= inf) && (~isnan(df_quint.(density_header)(i+1)))
            density_map(vis==i-1) = df_quint.(density_header)(i+1);
        end
    end

    % plot figure

    figure()
    set(gcf,'color','w');
    h1 = imagesc(single(min(density_map,100)));
    hold on;
    h1.CDataMapping = 'scaled';
    cmin = 0; cmax = 1;
    colormap([[1,1,1];BuRd;[0.2,0.2,0.2]])
    % h1.CData(~mask) = cmin-2;
    % caxis([cmin-2 cmax+2])

    % Overlay boundaries
    hold on
    boundaries = boundarymask(vis)*(cmax+0.01);
    h2 = imagesc(boundaries);
    set(h2,'AlphaData',boundaries)
    hold off
    axis image
    axis off
    cb1 = colorbar;
    % set(cb1, 'ylim', [cmin cmax], 'ticks',[cmin,0,cmax])

end
