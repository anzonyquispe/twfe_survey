function cell2vars(cellvar, datavec)
% PURPOSE: Convert the cell's columns' to variables in matlab workspace
% -----------------------------------------------------------------------------
% SYNTAX: 
%         (1) cell2vars(cellvar)
%         (2) cell2vars(cellvar, newvarname)
% -----------------------------------------------------------------------------
% OUTPUT: 
%       (1) each column of the cell is been transform to a variable in matlab
%       workspace
% -----------------------------------------------------------------------
% INPUT: 
%       (1) cellvar: NxM --->a cell containing M columns. Each column include
% a head and its body.
%        (2) newvarname: 1xM ---> M string as new head for the column.
%       NB: no string can be include in the file.

% -----------------------------------------------------------------------
% LIBRARY: 
% -----------------------------------------------------------------------
% SEE ALSO: vars2cell,  
% -----------------------------------------------------------------------
% REFERENCE: assigni, eval
% -----------------------------------------------------------------------
% written by:
%  Lin Renwen
%  <linrenwen@gmail.com>

% Version 1.0 [2012-6-27 20:29:25]

%=============================================
% EXAMPLE:
% INPUT:
% > A = {'name','grade'; 1,56;  2,78; NaN,90};
% > cell2vars(A);
% > name
% name =
%      1
%      2
%    NaN
% 
% > grade
% grade =
%     56
%     78
%     90
% %  END OF EXAMPLE
%=============================================


%%
header = cellvar(1,:);
data = cellvar(2:end,:);
% [ndata__, headertext__] = xlsread(sourcefile__, sheetname__);
% M_M.colheaders = headertext__;
% M_M.data = ndata__;
% 
% varList = M_M.colheaders;

 for ii = 1:max(size(header))
    tmp = header{1,ii};
    s1 = ['exist(''',tmp,''', ''var'');'];
    tf = evalin('caller', s1);
    if tf == 1
        error('Error in cell2var: The var ''%s'' has already exist\n', tmp);
    end
    
    if iscellstr(data(:,ii))
        assignin('caller', tmp, datavec(:,ii));
    else
        assignin('caller', tmp, cell2mat(data(:,ii)));
    end
    
    
 end
     
     
end