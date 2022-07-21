% MIT License
% 
% Copyright (c) 2019 Yury Bondarenko
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.



function [less_ugly] = prettyjson(ugly)
% Makes JSON strings (relatively) pretty
% Probably inefficient

% Mostly meant for structures with simple strings and arrays;  
% gets confused and !!mangles!! JSON when strings contain [ ] { or }. 

    MAX_ARRAY_WIDTH = 80;
    TAB = '    ';
    
    ugly = strrep(ugly, '{', sprintf('{\n')); 
    ugly = strrep(ugly, '}', sprintf('\n}')); 
    ugly = strrep(ugly, ',"', sprintf(', \n"'));
    ugly = strrep(ugly, ',{', sprintf(', \n{'));

    indent = 0;
    lines = splitlines(ugly);

    for i = 1:length(lines)
        line = lines{i};
        next_indent = 0;

        % Count brackets
        open_brackets = length(strfind(line, '['));
        close_brackets = length(strfind(line, ']'));

        open_braces = length(strfind(line, '{'));
        close_braces = length(strfind(line, '}'));

        if close_brackets > open_brackets || close_braces > open_braces
            indent = indent - 1;
        end

        if open_brackets > close_brackets
            line = strrep(line, '[', sprintf('[\n'));
            next_indent = 1;
        elseif open_brackets < close_brackets
            line = strrep(line, ']', sprintf('\n]'));
            next_indent = -1;
        elseif open_brackets == close_brackets && length(line) > MAX_ARRAY_WIDTH
            first_close_bracket = strfind(line, ']');
            if first_close_bracket > MAX_ARRAY_WIDTH % Just a long array -> each element on a new line
                line = strrep(line, '[', sprintf('[\n%s', TAB)); 
                line = strrep(line, ']', sprintf('\n]')); 
                line = strrep(line, ',', sprintf(', \n%s', TAB)); % Add indents!
            else % Nested array, probably 2d, first level is not too wide -> each sub-array on a new line
                line = strrep(line, '[[', sprintf('[\n%s[', TAB)); 
                line = strrep(line, '],', sprintf('], \n%s', TAB)); % Add indents!
                line = strrep(line, ']]', sprintf(']\n]'));
            end
        end

        sublines = splitlines(line);
        for j = 1:length(sublines)
            if j > 1   % todo: dumb to do this check at every line...
                sublines{j} = sprintf('%s%s', repmat(TAB, 1, indent+next_indent), sublines{j});
            else
                sublines{j} = sprintf('%s%s', repmat(TAB, 1, indent), sublines{j});     
            end
        end

        if open_brackets > close_brackets || open_braces > close_braces 
            indent = indent + 1;
        end
        indent = indent + next_indent;
        lines{i} = strjoin(sublines, newline); 

    end

    less_ugly = strjoin(lines, newline);
end