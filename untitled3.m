clear all;
clc;

%% simulation phantom
% h = full(sprandn(1024, 128, 0.3));
% Xcenter = 512;
% Ycenter = 64;
% r = 23;
% for yy = Ycenter-r : Ycenter+r
%     xmin = floor(Xcenter - 8*(r^2 - (yy - Ycenter)^2)^0.5);
%     xmax = ceil(Xcenter + 8*(r^2 - (yy - Ycenter)^2)^0.5);
%     h(xmin:xmax, yy) = 0.2*full(sprandn(xmax - xmin + 1, 1, 0.3));
% end
% % figure; imagesc(envelope(h)); colormap gray; axis square
% LL = 1024; %total RF data length
% M = 128; % total number of channels
% h = h(1:LL, 1:M);
% L_s = 30;
% t = [0:L_s - 1]';
% s = gaussmf(t, [5 4]).*gaussmf(t, [4 5]).*cos(2*pi*t/4);
% N_conv = LL+L_s-1;
% rf1 = zeros(N_conv, M);
% for jj = 1:M
%     rf1(:, jj) = conv(h(1:LL, jj), s); % convolved signal
% end
% 
% rf11 = rf1(1:LL,:);

%% load dataset
% load('dataset/17-19-23_cyst');
% load synthetic_image_sprandn_1024
load khalid_carotid

%% normalize the rf data
rf1 = rf1/max(max(rf1));

%% initialize necessary variables
Lt = 784;   %total RF data length
B = 2;      %no of blocks
M  = 128;    % total number of channels
Lb = Lt/B;   %RF data block length
iter = 1000;

%% initialize constraint constants
beta_spar = 0;
beta = 0.2;
xi = 1;
gamma = 2;
delta = 10^-10;
eSNR = 10;

%% segmenting total data and channel
X = zeros(2*Lb-1,M,B);
h_hat = zeros(Lb,M,B);
h_hat(:,:,1) = [ones(1,M); zeros(Lb-1,M)]/sqrt(M);%h(1:Lb,1:M);%

% load synthetic_image

H_hat = fft(h_hat,2*Lb-1);
h_cmp = zeros(B*Lb,M);
h_cmp(1:Lb,:) = h_hat(:,:,1);

h_est = zeros(B*Lb,M);

for i = 1:B
    X(:,:,i) = fft(rf1((i-1)*Lb+1:i*Lb,1:M),2*Lb-1);
    %         H_hat(:,:,i) = X(:,:,i);
    %         h_hat(:,:,i) = rf1((i-1)*Lb+1:i*Lb,1:M);
end


Xc = conj(X);

%% creating truncation matrix
% d1 = [zeros(Lb-1,Lb) eye(Lb-1);...
%     zeros(1,2*Lb-1)];
% d2 = [eye(Lb) zeros(Lb,Lb-1)];
% F = dftmtx(Lb);
% F2 = dftmtx(2*Lb-1);
% iF2 = F2'/(2*Lb-1);
% A2 = F*d2*iF2;
% A2H = A2';
%
% A1 = F*d1*iF2;
% A1H = A1';

%% initializing stochastic process to take horizontal partitioning
stochastic_channel_no = 16;
run_no = 250;
index = 1;
J = zeros(1,B*(M/stochastic_channel_no)*iter);
miu = zeros(1,B*(M/stochastic_channel_no)*iter);
NPM1 = zeros(1,B*(M/stochastic_channel_no)*iter);
NPM2 = zeros(1,B*(M/stochastic_channel_no)*iter);

for block = 1:B
    %%
    err = zeros(Lb,stochastic_channel_no*(stochastic_channel_no -1)/2);
    
    seg = calculate_segment(block);
    [seg_h, indx] = sort(seg(:,2));
    seg = [seg(indx,1) seg_h];
    l = size(seg,1);
    %         tstart = tic;
    
    for jj = 1:run_no
        
        take = randomize(1,M,stochastic_channel_no);
        slot = M/stochastic_channel_no;
        
        for run = 1:slot
            run
            jj
            block
            
            
            channel_to_take = take(run,:);
            grad_prev = zeros(2*Lb-1, stochastic_channel_no,block);
            
            for ii = 1:iter
                
%                 ii
                err1 = zeros(2*Lb-1,stochastic_channel_no*(stochastic_channel_no -1)/2);
                err2 = zeros(2*Lb-1,stochastic_channel_no*(stochastic_channel_no -1)/2);
                
                for er = 1:l
                    summ = seg(er,1) + seg(er,2) ;
                    
                    if summ == block
                        err1 = err1 + error_calc(X(:,channel_to_take,seg(er,1)),H_hat(:,channel_to_take,seg(er,2)));
                    else
                        err2 = err2 + error_calc(X(:,channel_to_take,seg(er,1)),H_hat(:,channel_to_take,seg(er,2)));
                    end
                end
                
                err1 = ifft(err1,2*Lb-1);
                err1 = [err1(Lb+1:2*Lb-1,:);zeros(1,stochastic_channel_no*(stochastic_channel_no -1)/2)];
                
                err2 = ifft(err2,2*Lb-1);
                err2 = err2(1:Lb,:);
                
                err = err1 + err2;
                if block ~= 1
                    err_1 = [zeros(Lb,stochastic_channel_no*(stochastic_channel_no -1)/2);...
                        err(1:Lb-1,:); zeros(1,stochastic_channel_no*(stochastic_channel_no -1)/2)];
                    err_1 = fft(err_1,2*Lb-1);
                end
                
                err_2 = [err(1:Lb,:);...
                    zeros(Lb-1,stochastic_channel_no*(stochastic_channel_no -1)/2)];
                err_2 = fft(err_2,2*Lb-1);
                
                J(index) = sum(sum(abs(err).^2)) + beta_spar*norm(h_hat(:,:,block), 1);
                
                clear grad_f;
                clear grad_h;
                grad_f = zeros(2*Lb-1, stochastic_channel_no);
                grad_h = zeros(2*Lb-1, stochastic_channel_no,block);
                for k = 1:stochastic_channel_no
                    for i = 1:stochastic_channel_no
                        if ( i < k )
                            col = (2*stochastic_channel_no-i)*(i-1)/2 + (k-i);
                            
                            grad_f(:, k) = grad_f(:, k) +  Xc(:,channel_to_take(i),1).*err_2(:,col);
                            for block_h = 1:block-1
                                grad_h(:, k,block_h) = grad_h(:, k,block_h) +  Xc(:,channel_to_take(i),block-block_h).*err_1(:,col)...
                                    + Xc(:,channel_to_take(i),block-block_h+1).*err_2(:,col);
                            end
                        else
                            if (i > k)
                                col = (2*stochastic_channel_no-k)*(k-1)/2 + (i-k);
                                grad_f(:, k) = grad_f(:, k) - Xc(:,channel_to_take(i),1).*err_2(:,col);
                                for block_h = 1:block-1
                                    grad_h(:, k,block_h) = grad_h(:, k,block_h) -  Xc(:,channel_to_take(i),block-block_h).*err_1(:,col)...
                                        - Xc(:,channel_to_take(i),block-block_h+1).*err_2(:,col);
                                end
                            end
                        end
                    end
                end
                
                grad_h(:, :,block) = grad_f;
                
                grad_total = [];
                tmp_hat = [];
                for i = 1:block
                    tmp_hat = [tmp_hat; H_hat(:,channel_to_take,i)];
                    
                    
                    if i == block
                        H_sign = fft(sign(h_hat(:,channel_to_take,i)),2*Lb-1);
                        grad_h(:,:,i) = grad_h(:,:,i) + beta_spar*H_sign;
                    end
                    
                    
                    
                    grad_h(:,:,i) = beta*grad_prev(:,:,i) + (1-beta)*grad_h(:,:,i);
                    grad_total = [grad_total; grad_h(:,:,i)];
                    
                end
                grad_f = grad_h(:, :,block);
                grad_prev = grad_h;
                
                psi = xi*exp(-gamma*10^(-eSNR/10)/(J(index)^(eSNR/40)+delta));
                miu(index) = psi*real((tmp_hat(:)'*grad_total(:))/(norm(grad_total(:)))^2 + 1e-6);
                
                H_hat(:,channel_to_take,block) = H_hat(:,channel_to_take,block) - miu(index)*grad_f;
                
                
                
                h_tmp = real(ifft(H_hat(:,channel_to_take,block)));
                h_hat(:,channel_to_take,block) = h_tmp(1:Lb,:);
                
                h_tmp = [];
                for i = 1:block
                    h_tmp = [h_tmp; h_hat(:,:,i)];
                    h_cmp((i-1)*Lb+1:i*Lb,:) = h_tmp((i-1)*Lb+1:i*Lb,:);
                    
                end
                h_tmp = fft(h_tmp,2*Lb*block - 1);
                h_tmp = h_tmp/norm(h_tmp);
                
                h_tmp = real(ifft(h_tmp));
                
                for i = 1:block
                    h_hat(:,:,i) = h_tmp((i-1)*Lb+1:i*Lb,:);
                end
                
                H_hat = fft(h_hat,2*Lb-1);
%                 NPM1(index) = NPM(h((block-1)*Lb+1:block*Lb,1:M),h_hat(:,:,block));
%                 NPM2(index) = NPM(h(1:block*Lb,1:M),h_cmp(1:block*Lb,:));
                %
                %                                 clf;
                %                                 drawnow;
                %                                 plot(NPM1(1:index));
                % %                 plot(h_hat(1:Lb,channel_to_take(1),2));
                %
                %                                 pause(.01);
                
                index = index + 1;
            end
            %                         toc(tstart);
%             clf;
%             drawnow;
%             plot(NPM1(1:index-1));
%             pause(.01);
        end
%                 if mod(jj,10) == 0
%                     clf;
%                     drawnow;
%                     plot(NPM2(1:index-1));
%                     pause(.01);
%                 end
    end
    %     plot(NPM1);
    h_est((block-1)*Lb+1:block*Lb,:) = h_hat(:,:,block);
end
% save('synthetic_image','h_hat','NPM1','NPM2');
% save('cyst_image','h_hat','h_est');