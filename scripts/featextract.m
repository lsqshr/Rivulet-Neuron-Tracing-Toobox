function feats = featextract(imgpath, gtpath, saveprefix, sigma)
% Extract hession features from 1 subject
	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
	addpath(fullfile(pathstr, '..', 'util'));
    addpath(fullfile(pathstr, '..', 'lib', 'dir2'));
    addpath(fullfile(pathstr, '..', 'lib', 'frangi_filter_version2a'));
	addpath(fullfile(pathstr, '..', '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));

	[~, filename, ~] = fileparts(imgpath);
	I = single(load_v3d_raw_img_file(imgpath));
    if ndims(I) > 3
        I = I(:, :, :, 1);
    end
    [l1, l2, l3] = eigextract(I, sigma);  
    
	options.BlackWhite = false;
    options.FrangiScaleRange = [1 10];
    vess = FrangiFilter3D(I, options);
    [kriss] = VessFilters(l1, l2, l3);

    m = max(l3(:));
    l1reverse = -l1 + m;
    l2reverse = -l2 + m;
    l3reverse = -l3 + m;
    fa= (0.5)^0.5 * (((l1reverse-l2reverse).^2 + ...
    	              (l2reverse-l3reverse).^2 + ...
    	              (l3reverse-l1reverse).^2).^0.5) ./ ...
				    ((l1reverse.^2 + l2reverse.^2 + l3reverse.^2).^0.5);
    
    gt = [];

    if numel(gtpath) ~= 0
        gttree = load_v3d_swc_file(gtpath);
        gt = binarysphere(I, gttree);
    end
				    
    if numel(saveprefix) > 0
        save(fullfile(saveprefix, [filename, '.mat']), 'l1', 'l2', 'l3', 'I', 'fa', 'vess', 'kriss', 'gt'); 
    end

    feats.l1 = l1;
    feats.l2 = l2;
    feats.l3 = l3;
    feats.I = I;
    feats.fa = fa;
    feats.vess = vess;
    feats.kriss = kriss;
    feats.gt = gt;
end