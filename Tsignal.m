function X= Tsignal(L,K)
% L为信号长度，K为稀疏度

Index_K=randperm(L);
X=zeros(L,1);
X=X-1;
%单极性变为双极性（0到-1；1到1）
X(Index_K(1:K))=1;