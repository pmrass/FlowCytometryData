classdef PMFlowJoGroupIndices
    %PMFLOWJOGROUPINDICES retrieves group-index information from a linked text file;
    %   the source file contains information about rows location for different groups for different source files;
    % the text file contains to parts separated by a colon:
    % first part: group-names separated by commas, the last name is followed by a colon instead (e.g.  "AMD, -, S, S+AMD, S+12, S+12+AMD:");
    % second part: 1 to multiple infos about file-code and group-rows, separated by commas;
    % e.g. "20210423_Day6,      	 NaN,         	  6,            		5,            	,         	4,           		3"
    % the very last entry is not followed by comma;;
    % if there are multiple indices per group add multiple numbers not separated by ;
    
    properties (Access = private)
        FolderName
        FileName
        FileCodes
        
        MyFileObject
        
       
        
    end
    
    properties (Access = private) % data read and parsed from file:
        
        
        
        GroupNames
        ExperimentCodeStrings
        GroupRowNumbersForAllExperiments
        
        SelectedGroupRowNumbers
        
    end
    
    methods % INITIALIZATION

        function obj = PMFlowJoGroupIndices(varargin)
            %PMFLOWJOGROUPINDICES Construct an instance of this class
            %   takes 3 arguments:
            % 1: folder name
            % 2: file name
            % 3: PMFlowJoFileIDCodes
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 3
                    obj.FolderName =            varargin{1};
                    obj.FileName =              varargin{2};
                    obj.FileCodes =             varargin{3};
                    obj.MyFileObject =          PMFile(obj.FolderName, obj.FileName);
                    
                
                    obj =                       obj.setPropertiesFromFile;
                    
                otherwise
                    error('Wrong input.')
                
            end
        end
        
        function obj = set.ExperimentCodeStrings(obj, Value)
            assert(iscellstr(Value) && isvector(Value), 'Wrong input.')
           obj.ExperimentCodeStrings = Value; 
        end
        
        function obj = set.FolderName(obj, Value)
            assert(ischar(Value), 'Wrong input.')
            obj.FolderName = Value;
            
        end
        
        function obj = set.FileName(obj, Value)
           assert(ischar(Value), 'Wrong input.')
            obj.FileName = Value;
            
        end
        
        function obj = set.FileCodes(obj, Value)
            assert(isscalar(Value) && isa(Value, 'PMFlowJoFileIDCodes'), 'Wrong input.')
            obj.FileCodes = Value;
            
        end
     
    end
    
    methods % SUMMARY:
        
        function obj = showSummary(obj)
             
              text = getSummary(obj);
              cellfun(@(x) fprintf('%s\n', x), text);
         
         end
         
        function text = getSummary(obj)
             
              
                
                text{1} = sprintf('\n**** This PMFlowJoGroupIndices object takes general group-information from the file %s in folder %s.\n', obj.FileName, obj.FolderName);
                text = [text; sprintf('It contains information about the following groups:\n')];
                text = [text;cellfun(@(x) sprintf('%s\n', x), obj.GroupNames, 'UniformOutput', false)];

                text = [text;   sprintf('The file spreadsheet has %i rows and %i columns.\n', length(obj.ExperimentCodeStrings), size(obj.GroupRowNumbersForAllExperiments, 2))];
                for index = 1 : length(obj.ExperimentCodeStrings)
                    CurrentCodeString = obj.ExperimentCodeStrings{index};
                    text = [text;sprintf('\nGroup definitiations for the file-code string "%s":\n', CurrentCodeString)];
                    for groupIndex = 1 : length(obj.GroupNames)
                       text = [text;sprintf('Group %s: ', obj.GroupNames{groupIndex})];
                       CurrentRows =    obj.GroupRowNumbersForAllExperiments{index, groupIndex};
                      text = [text; arrayfun(@(x) sprintf('%i, ', x), CurrentRows, 'UniformOutput', false)];
                        text = [text; newline];
                    end


                end

                text = [text; sprintf('\nIt selectes the data from this list using the following file-codes:\n') ];
                text = [text;   obj.FileCodes.getSummary('ActiveKey')];

         end
           
    end
    
    methods % GETTERS
        
        function GroupNames =       getGroupNames(obj)
            % GETGROUPNAMES returns cell-string with names of groups;
            GroupNames = obj.GroupNames; 
            
        end
              
        function mergedRows =       getGroupRows(obj)
            % GETGROUPROWS returns a cell-array that contains group-row information;
            % each cell contains data for a specific file code:
            % this contains a nother cell array, with one cell for each group: this contains a numerical vector for the rows in each group;
           mergedRows = obj.SelectedGroupRowNumbers;
           
          %          cellfun(@(x) assert(isvector(x) && isnumeric(x), 'Group rows must be a vector of numerical cells.'), mergedRows)
        end
        
        function number =           getNumberOfGroups(obj)
            number =    length(obj.getGroupNames);
         end
        
         function codes = getFileCodes(obj)
             codes = obj.FileCodes;
         end
    end
    
    methods (Access = private) % SETTERS FOR FILE-DERIVED DATA
        
        function obj = setPropertiesFromFile(obj)
            
            RawData =                               obj.readDataFromFile;
            
            obj.GroupNames =                            obj.parseTextIntoGroupNames(RawData{1});
            
            SpreadSheet =                               obj.parseTextIntoSpreadSheet(RawData{2});
            obj.ExperimentCodeStrings =                 SpreadSheet(:,1);
            obj.GroupRowNumbersForAllExperiments =      SpreadSheet(:, 2 : end);

            obj.SelectedGroupRowNumbers =               obj.getSelectedRowNumbers;

        end
        
      
        
              
    end
    
    methods (Access = private) % GETTERS PARSING RAW DATA
        
         function GroupNames =      parseTextIntoGroupNames(obj, GroupNameString)

            GroupNames =            (strsplit(GroupNameString, ','))'; 
            GroupNames =            cellfun(@(x) strtrim(x), GroupNames, 'UniformOutput', false);

            empty =                 cellfun(@(x) isempty(x), GroupNames);
            GroupNames(empty) =     [];
          end
        
        function spreadSheet =      parseTextIntoSpreadSheet(obj, groupRowsText)

            splitText =             (strsplit(groupRowsText, ','))';
            splitText =             cellfun(@(x) strtrim(x), splitText, 'UniformOutput', false);
            empty =                 cellfun(@(x) isempty(x), splitText);
            splitText(empty) =      [];

            NumberOfColumns =         length(splitText) / (obj.getNumberOfGroups + 1);
            
            try 
               assert( PMNumbers(NumberOfColumns).isIntegerScalar == true)
            catch
                  error( 'There is a mismatch in the number of rows and columns in the input file.')
            end
          

            spreadSheet =                   transpose(reshape(splitText, [(obj.getNumberOfGroups + 1), NumberOfColumns]));

            spreadSheet =                   obj.trimspreadSheet(spreadSheet);




        end

        function spreadSheet =      trimspreadSheet(obj, spreadSheet)
            spreadSheet(:, 1)=               cellfun(@(x) strtrim(x), spreadSheet(:, 1), 'UniformOutput', false);
            spreadSheet(:, 2:end) =         cellfun(@(x) (obj.splitNumberString(x))', spreadSheet(:, 2:end), 'UniformOutput', false);
         %   Empty =                         cellfun(@(x) isempty(x), spreadSheet(:, 2:end));
       %     spreadSheet(Empty, 2:end) =      {NaN};

        end

        function out =              splitNumberString(~, cell)
            out = strsplit(cell, ' ');
            out = cellfun(@(x) str2double(x), out);
           % out(isnan(out)) = [];
        end

        function mergedRows =             getSelectedRowNumbers(obj)
               
            FileCodesPerGroup =                  obj.FileCodes.getFileCodesPerGroup; % cell array:
            
            rowsForSeparateFileCodes =          cellfun(@(x) obj.getGroupRowsForFileCodes(x), FileCodesPerGroup, 'UniformOutput', false);
            
            mergedRows =                        cellfun(@(x) PMFlowJoExports().mergeGroupRows(x), rowsForSeparateFileCodes, 'UniformOutput', false);
            assert(isvector(mergedRows), 'Wrong content.')
            mergedRows =                        mergedRows(:);
            assert(isvector(mergedRows) && iscell(mergedRows), 'Group rows must be a vector of numerical cells.')
            
            
            
        end
             
        
    end

    methods (Access = private) % GETTER FROM FILE
        
         function rawData =    readDataFromFile(obj)
                rawData =     fileread([obj.FolderName '/' obj.FileName]);
                rawData =     strsplit(rawData, ':');
                try
                    assert(length(rawData) == 2, 'Group file has invalid format.')
                catch
                   error('Something went wrong.') 
                end
                
                
         end
        
    end
    
    methods (Access = private) % group rows
        
        function GroupRows =        getGroupRowsForFileCodes(obj, String)
            GroupRows = cellfun(@(x) obj.getGroupRowsForFileCode(x), String, 'UniformOutput', false);
        end

        function GroupRows =        getGroupRowsForFileCode(obj, String)
              MatchingRow =             obj.getRowIndexForExperimentCode(String);
              GroupRows =               obj.GroupRowNumbersForAllExperiments(MatchingRow, :);
        end
        
        function MatchingRow = getRowIndexForExperimentCode(obj, String)
            
              MatchingRow =           cellfun(@(x) contains(String, x), obj.ExperimentCodeStrings);
              if sum(MatchingRow) < 1
                  
                  fprintf('There was a problem with the following PMFlowJoGroupIndices object:\n')
                  obj.showSummary;
                  fprintf('The object has these keys available:.\n')
                  obj.printExperimentCodeStrings;
                  error('But the key "%s" was requested.', String)

              elseif sum(MatchingRow) > 1
                  obj.printExperimentCodeStrings;
                  error('The search string %s did match multiple target strings.', String)

              end
              
        end

        function obj =              printExperimentCodeStrings(obj)
            fprintf('PMFlowJoDataSource object is linked to the following experiment-code strings:\n');
            cellfun(@(x) fprintf('%s\n', x), obj.ExperimentCodeStrings, 'UniformOutput', false);
        end

    end
    
    
    
end

