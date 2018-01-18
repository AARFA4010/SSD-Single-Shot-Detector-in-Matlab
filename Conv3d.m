%% 
%-----------------Conv3d-----------------
%��  �ߣ��
%��  ˾��BJTU
%��  �ܣ�3ά�����
%��  �룺
%       in_array    -----> �����ά���飨dim = 3����
%       kernels     -----> ����ˣ�dim = 4����
%       bias        -----> ƫ�á�
%       stride      -----> ������
%       padding     -----> �����������
%       dilation    -----> ��������;��롣
%��  ����
%       out_array   -----> �����ά���飨dim = 3����
%��  ע��Matlab 2016a��
%----------------------------------------

%%

function out_array = Conv3d(in_array, kernels, bias, stride, padding, dilation)

    % �������ά��    
    in_dims = ndims(in_array);
    if(in_dims == 3)
        [height, width, depth] = size(in_array);
    else
        error('��������ά��С��3ά�������������ݡ�');
    end
    
    if(ndims(kernels) < 4)
        error('��������ά��С��4ά�������������ݡ�')
    else
        [k_height, k_width, k_depth, k_num] = size(kernels);
        n_kwidth = (k_width - 1) * dilation + 1;
        n_kheight = (k_height - 1) * dilation + 1;
    end
    
    % ���bias��Ŀ�Ƿ�����������һ��
    if(k_num ~= length(bias))
        error('bias��Ŀ���������鲻һ�£������������ݡ�');
    end
          
    % ���    
    n_height = height + 2 * padding;
    n_width = width + 2 * padding;
    pad_in_array = zeros(n_height, n_width, depth);    
    pad_in_array(1 + padding: padding + width, 1 + padding: padding + height, :)...
        = in_array;
    
    % ȷ�������С
    o_height = floor((n_height - n_kheight) / stride + 1);
    o_width = floor((n_width - n_kwidth) / stride + 1);
    out_array = zeros(o_height, o_width, k_num);
    
    % im2col
    cidx = n_width * n_height * (0: k_depth - 1)'; 
    ridx = 1: o_height;
    t = cidx(:, ones(o_height, 1)) + 1 + stride * (ridx(ones(k_depth, 1), :) - 1);
    tt = zeros(k_height * k_depth, o_height);
    rows = 1: k_depth;
    for c = 0: k_height - 1
        tt(c * k_depth + rows, :) = t + c * dilation;
    end
    ttt = zeros(k_height * k_width * k_depth, o_height);
    rows = 1: k_height * k_depth;
    for a = 0: k_width - 1
        ttt(a * k_height * k_depth + rows, :) = tt + n_height * dilation * a;
    end
    tttt = zeros(k_height * k_width * k_depth, o_height * o_width);
    cols = 1: o_height;
    for b = 0: o_width - 1,
        tttt(:, b * o_height + cols) = ttt + stride * n_height * b;
    end
    in_array_ = pad_in_array(tttt);
    ker = reshape(permute(kernels, [4, 3, 1, 2]), k_num, []);
    out_array_ = ker * in_array_;
    out_array = permute(reshape(out_array_, k_num, o_height, o_width), [2, 3, 1]);
    
%     % ���ڻ���
%     for k = 1: k_num
%       ker = kernel(:,:,:,k);
%       for i = 1 : stride: n_height - window_size + 1
%         for j = 1 : stride: n_width - window_size + 1
% 
%             % ��ȡͼ���
%             block = pad_in_array(i: i + window_size - 1, ...
%                 j: j + window_size - 1, :);
%             out_array(1 + (i - 1) / stride, 1 + (j - 1) / stride, k) = ...
%               block .* ker;
%         end
%       end
%     end

    % ���ƫ��
    for k = 1: k_num
        out_array(:, :, k) = out_array(:, :, k) + bias(k);
    end
end
    
    