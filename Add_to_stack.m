function Add_to_stack(ij)
   % this is a recursive function (a function that calls itself).
   % Go through list of donors and then the donors of the donors. Start
   % with a node along the boundary or a local minima
   
   global ndon donor stack nstack 
   %color
   
   nstack=nstack+1;
   stack(nstack)=ij;
   
   if ndon(ij)~=0; %if there are donors to a node then proceed
       for kk=1:ndon(ij)%find their donors
           Add_to_stack(donor(ij,kk)); % find the donors of each donor
       end
   end
end


