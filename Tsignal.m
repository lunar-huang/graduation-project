function X= Tsignal(L,K)
% LΪ�źų��ȣ�KΪϡ���

Index_K=randperm(L);
X=zeros(L,1);
X=X-1;
%�����Ա�Ϊ˫���ԣ�0��-1��1��1��
X(Index_K(1:K))=1;