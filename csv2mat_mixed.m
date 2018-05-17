function [data] = csv2mat_mixed(filename,observations,N,stringpos)
%[data] = csv2mat_mixed(filename,observations,N,stringpos)
% CSV2MAT_MIXED reads in the data from the CSV file FILENAME and formats
% it as a structure named DATA with elements that are the header names in
% the CSV file FILENAME. 
%
% Different than in CSV2MAT_NUMERIC the number of variables, N, and the
% number of observations per variable, OBSERVATIONS, has to be specified
% along with a vector, STRINGPOS, of the positions of the variables in the
% CSV file FILENAME that contain string (not numeric) elements. The
% advantage compared to CSV2MAT_NUMERIC is that also string variables can
% be imported. However, if the data set doesn't include string variables,
% CSV2MAT_NUMERIC should be preferred since it only requires the filename
% as input.
%
% FILENAME should have the ending '.csv' if that is part of the actual 
% file name, but can have an arbitrary ending. FILENAME is a string and 
% must be in single quotes.
%
% Missing observations are recorded as NaN.
%
% Written for CSV files that are output from STATA using the
% "OUTSHEET" command with the option "COMMA" specified.
%
% ========================================================================
%                    Background Information
% ------------------------------------------------------------------------
%  Function to import mixed (numeric and string) data from csv file.
%  This code is a modification of the function csv2mat_numeric 
%  by Solomon Hsiang (http://www.solomonhsiang.com/computing/matlab-code)
%
%    Stephanie Lackner                   Version 1.0
%    www.columbia.edu/~sl3382            May 8, 2014
%    sl3382@columbia.edu           
% ========================================================================

num_string=length(stringpos);
%creating the string command to read in N variables per line
line = [];
pos=1;
if num_string>0
    for j=1:num_string
        for i=pos:stringpos(j)-1
            line = [line ' %f'];
        end
        %line = [line ' %s'];
        % Temporary replacement because of quotation marks
        line = [line ' %q'];
        pos=stringpos(j)+1;
    end
    for i=pos:N
        line = [line ' %f'];
    end
else
    for i = 1:N
        line = [line ' %f'];
    end
end

%opening file and reading the names and data
fid = fopen(filename);
names = textscan(fid,'%s',N,'delimiter',',');
dataraw = textscan(fid, line, observations, 'delimiter',',');
vars = names{1};
fclose(fid);


%checking to make sure that observations in the last line are not omitted
%if they are, it is because there was a missing value, so add NaN
for i = 1:N 
    if length(dataraw{i})<observations
        dataraw{i} = [dataraw{i}; nan];
    end
end
    
    
%formatting output into a single structure
line = ['data = struct('];
for i = 1:N
    if isnumeric(dataraw{i})
        line = [line 'vars{' num2str(i) '}, dataraw{' num2str(i) '},'];
    else
        line = [line 'vars{' num2str(i) '}, {dataraw{' num2str(i) '}},'];
    end
end
line = [line(1:end-1) ');'];

eval(line);



disp(' ')
disp('==========================================')
disp('IMPORTED VARIABLES')
disp(' ')
disp(vars)
disp('==========================================')


return