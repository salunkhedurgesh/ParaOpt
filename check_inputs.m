function [entity] = check_inputs(entity, entity_name, itstype, filler)

itstype = string(itstype);
if nargin < 4
    filler = 0;
end

if filler == 1
    if itstype == "posinteger"
        if ~isa(entity, 'numeric')
            fprintf(2, '!!error: number of %s must be a positive integer: check file ''my_input.m''\n ', entity_name);
            error('input error')
        elseif mod(entity, 1) ~= 0
            entity = floor(entity);
            fprintf('[\bDecimal entered when integer expected, %s changed to  = %d \nRecheck values in my_input.m ]\b\n ', entity_name, entity);
        elseif entity < 1
            fprintf(2, 'positive integer expected for %s\n', entity_name)
            error('input error')
        end
    end
    
    if itstype == "string"
        if ~isstring(entity)
            fprintf(2, '!!error: %s is not a string, check ''my_input.m'' \n', entity_name);
            error('input error');
        end
    end
    
    if itstype == "vector"
        if ~isvector(entity) || ~isa(entity, 'double')
            fprintf(2, '!!error: the %s should be a 1x2 row vector, ''check my_input.m'' \n', entity_name)
            error('input error')
        end
    end
    
    if itstype == "matrix"
        if ~ismatrix(entity) || ~isa(entity, 'double')
            fprintf(2, '!!error: the %s should be a n x 2 matrix, ''check my_input.m'' \n', entity_name)
            error('input error')
        end
    end
    
    if itstype == "numbool"
        if entity ~= 1 && entity ~= 0
            fprintf(2, '!!error: the %s should be a numeric boolean (0 or 1), ''check my_input.m'' \n', entity_name)
            error('input error')
        end
    end
    
elseif filler == 0
    if itstype == "posinteger"
        if ~isa(entity, 'numeric')
            fprintf(2, '!!error: number of %s must be a positive integer \n ', entity_name);
            error('input error')
        elseif mod(entity, 1) ~= 0
            entity = floor(entity);
            fprintf('[\bDecimal entered when integer expected, %s changed to  = %d ]\b\n ', entity_name, entity);
        elseif entity < 1
            fprintf(2, 'positive integer expected for %s\n', entity_name)
            error('input error')
        end
    end
    
    if itstype == "string"
        if ~isstring(entity)
            fprintf(2, '!!error: %s is not a string \n', entity_name);
            error('input error');
        end
    end
    
    if itstype == "vector"
        if ~isvector(entity) || ~isa(entity, 'double')
            fprintf(2, '!!error: the %s should be a 1x2 row vector \n', entity_name)
            error('input error')
        end
    end
    
    if itstype == "matrix"
        if ~ismatrix(entity) || ~isa(entity, 'double')
            fprintf(2, '!!error: the %s should be a n x 2 matrix \n', entity_name)
            error('input error')
        end
    end
    
    if itstype == "numbool"
        if entity ~= 1 && entity ~= 0
            fprintf(2, '!!error: the %s should be a numeric boolean (0 or 1) \n', entity_name)
            error('input error')
        end
    end
    
end



end