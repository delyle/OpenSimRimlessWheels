function updateHeader(fname,newHeader,replaceHeader)
% based on code by Walter Roberson at https://uk.mathworks.com/matlabcentral/answers/62986-how-to-change-a-specific-line-in-a-text-file
% newHeader must be a string array
if nargin < 3
    replaceHeader = false;
end

S = readlines(fname);
if replaceHeader
    iHeaderEnd = find(strcmp(S,"endheader"),1);
    S(1:iHeaderEnd-1) = [];
    if ischar(replaceHeader) && strcmpi(replaceHeader,'delete')
        % delete the header completely
        S(1) = []; 
    end
end

S = [newHeader;S];
[fid, msg] = fopen(fname, 'w');
if fid < 1 
    error('could not write output file because "%s"', msg);
end
fwrite(fid, strjoin(S, '\n'));
fclose(fid);
