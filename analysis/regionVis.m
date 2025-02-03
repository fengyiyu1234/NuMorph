%% reigon-wise heatmap - %change and p-val of density, coronal section

downsample_factor = 0.1;
home_path = fileparts(which('NM_config'));
annotation_path = fullfile(home_path,'data','annotation_data');
load(fullfile(annotation_path,'annotationData.mat'),'annotationVolume')
I_annotation = permute_orientation(annotationVolume,'sla','srp');
[nrows,ncols,nslices] = size(I_annotation);
nslices = nslices * downsample_factor;
I_annotation = imresize3(I_annotation,[nrows,ncols,nslices],'Method','nearest');

budam = flip(buda(198),1);
BuRd = flip(brewermap(198,'RdBu'),1);

%% plot

load('D:\annotated_cells\stats.mat');
ids = df_stats.id;
classes=["yellow_neuron","yellow_glia","green_neuron","green_glia","red_neuron","red_glia"]; % swapped color
for z = [48,68,88,108]
    ap = (54-(1320*downsample_factor-z))/10;
    vis = I_annotation(:,:,z);
    boundaries = zeros(size(vis),'logical');
    density_map_pchange = cell(1,length(classes));
    density_map_padj = cell(1,length(classes));

    for c = 1:6

        density_header_pchange = "PChange_" + classes(c) + "_Densities";
        density_header_padj = "p_adj_" + classes(c) + "_Densities";
        mask = vis>0;

        % density_pchange

        density_map_pchange{1,c} = zeros(size(vis));
        % for i = 2:length(ids)
        for i = [4:555,557:561,1106:1113,1192:1200]
            if (df_stats.(density_header_pchange)(i) ~= inf) && (~isnan(df_stats.(density_header_pchange)(i)))
                density_map_pchange{1,c}(vis==i-1)=df_stats.(density_header_pchange)(i);
            end
        end

        % plot figure

        figure()
        set(gcf,'color','w');
        h1 = imagesc(single(min(density_map_pchange{c},100)));
        hold on;
        h1.CDataMapping = 'scaled';
        cmin = -100; cmax_1 = 100;
        colormap([[1,1,1];BuRd;[0.2,0.2,0.2]])
        h1.CData(~mask) = cmin-2;
        caxis([cmin-2 cmax_1+2])

        % Overlay boundaries
        hold on
        boundaries = boundarymask(vis)*(cmax_1+1);
        h2 = imagesc(boundaries);
        set(h2,'AlphaData',boundaries)
        hold off
        axis image
        axis off
        % cb1 = colorbar;
        % set(cb1, 'ylim', [-100 100], 'ticks',[-100,0,100])

        fname = strcat(num2str(z),'-',num2str(ap,'%.2f'),'-',density_header_pchange,'.png');
        % print(gcf,fname,'-dpng','-r300'); 
        export_fig(gca,fname,'-transparent','-r300');

        % density_padj

        density_map_padj{1,c} = zeros(size(vis));
        % for i = 2:length(ids)
        for i = [4:555,557:561,1106:1113,1192:1200]
            if (df_stats.(density_header_padj)(i) <= 0.05) && (df_stats.(density_header_padj)(i) ~= inf) && (~isnan(df_stats.(density_header_padj)(i)))
                density_map_padj{1,c}(vis==i-1)=-log10(df_stats.(density_header_padj)(i));
            end
        end

        figure()
        set(gcf,'color','w');
        h1 = imagesc(single(density_map_padj{1,c}));
        hold on;
        h1.CDataMapping = 'scaled';
        cmin = 0; cmax_1 = 5;
        colormap([[1,1,1];budam;[0.2,0.2,0.2]])
        caxis([cmin cmax_1+1])

        % Overlay boundaries
        hold on
        boundaries = boundarymask(vis)*(cmax_1+1);
        h2 = imagesc(boundaries);
        set(h2,'AlphaData',boundaries)
        hold off
        axis image
        axis off
        % cb2 = colorbar;
        % set(cb2, 'ylim', [1.3 5], 'ticks',[1.3,5])

        fname = strcat(num2str(z),'-',num2str(ap,'%.2f'),'-',density_header_padj,'.png');
        % print(gcf,fname,'-dpng','-r300'); 
        export_fig(gca,fname,'-transparent','-r300');

    end
end
close all