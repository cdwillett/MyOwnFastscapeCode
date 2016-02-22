


















% # START WITH BASE-LEVELS / PITS 
% # (Where receiver[ij] = ij)
% 
% baseLevels = receiver[receiver == indexVector]
% stack = np.empty(nn,int)
% i = 0
% def add_to_stack(ij):
%     global i
%     stack[i] = ij
%     i = i+1
%     for k in donor[0:ndon[ij],ij]:
%               add_to_stack(k)
% abc = 0
% 
% for ij in baseLevels:
%     add_to_stack(ij)