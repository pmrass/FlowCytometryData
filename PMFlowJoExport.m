classdef PMFlowJoExport
    %PMFLOWJOEXPORT gives access to data exported with FloJo;
    %   parses csv files exported from flow-jo and enables user to retrieve content;
    
    properties (Access = private)
        File
        
   
     
    end
    
    methods % initialize
        
        function obj = PMFlowJoExport(varargin)
            %PMFLOWJOEXPORT create instance of object
            % takes 2 arguments: 
            % 1: string of folder-name with data source; 2;
            % 2: string of file-name with source data;
            % creating this object also leads to replacing of original file with most recent duplicate (if there are duplicates) and then deletion of all duplicates;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 2
                    obj.File =       PMFile(varargin{1}, varargin{2});
                    obj.File =       obj.File.replaceFileByOldestDuplicateTaggedWith('-');
                otherwise
                    error('Wrong number of arguments.')
            end
        end
        
        
        
    end
    
    methods % getters
        
        function Data = getSpreadSheetOfData(obj)
            % GETSPREADSHEETOFDATA returns numerical data in matrix form;
            % removes row and column titles:
            % each row contains data for a different sample (e.g., lung from mouse 1, etc.);
            % each column contains data for a different parameter (e.g. percentage of CD69+ t cells, etc.);
              Data =     obj.getDataInMatrixSpreadSheet;
        end
        
         function Summary = getSummary(obj)
            Summary = obj.getSummaryInternal;  
         end
        
     
        function SpecimenNames = getSpecimenNames(obj)
            SpecimenNames =  obj.getSpecimenTitles;
        end
        
        function obj = showSummary(obj)
            
            fprintf('\n*** This PMFlowJoExport object can read and parse data stored in a single FloJo file:\n')
            fprintf('The object is currently linked to the following file:\n')
            obj.File = obj.File.showSummary;
            fprintf('\nParsing of the data in this file shows the following content:\n')
            cellfun(@(x) fprintf('File %s\n', x), obj.getSummaryInternal)
            
          
        end
        
    end

    methods (Access = private) % GETTERS: NUMBER OF SPECIMENS;

          function number = getNumberOfSpecimens(obj)
            titles =    obj.getSpecimenTitles;
            number =    length(titles);
        end
        
        function titles = getSpecimenTitles(obj)
            parsed =        obj.convertFileContentIntoCellMatrix(obj.File.getContent);
            titles =        parsed(:, 1);
        end

    end

    methods (Access = private) % READ DATA FROM FILE

        function data = getDataInMatrixSpreadSheet(obj)
            data =      cellfun(@(x) str2double(x), obj.getDataInCellSpreadsheet);
        end
        
        function CellSpreadsheetWithoutRowTitles = getDataInCellSpreadsheet(obj)
            CellSpreadsheetWithSampleColumn =       obj.convertFileContentIntoCellMatrix(obj.File.getContent);
            CellSpreadsheetWithoutRowTitles =       CellSpreadsheetWithSampleColumn(:, 2 : end - 1); % remove first (sample) column and last (empty) column;
        end
        
        function parsed = convertFileContentIntoCellMatrix(obj, RawData)
            CellVectorForEachFile =                     (strsplit(RawData,'\n'))';
            CellVectorForEachFile_TitlesRemoved =       CellVectorForEachFile(2: end-3,:); 
            CellVectorForEachFile_TitlesRemoved =       cellfun(@(x) obj.removeCommasInFileName(x), CellVectorForEachFile_TitlesRemoved,'UniformOutput', false);
            currentResult=                              cellfun(@(x) strsplit(x,','), CellVectorForEachFile_TitlesRemoved, 'UniformOutput', false);
            parsed =                                    vertcat(currentResult{:});
        end
        
        function [string] = removeCommasInFileName(obj, string)
            % not totally sure what this is doing; remove?
            apostrophe = find(string == '"');
            if length(apostrophe) == 2
                substring = string(apostrophe(1):apostrophe(2));
                substring(substring==',') = '_';
                string(apostrophe(1):apostrophe(2)) = [substring(2:end-1), '  '];
            end
        end
        
    end
    
    methods  (Access = private)
        
        %% get data-codes:
         function number = getNumberOfDataTypes(obj)
             Data =     obj.getDataInMatrixSpreadSheet;
             number =   size(Data, 2);
         end
        
     
       
      
        
        %% get  summary;
        function Summary = getSummaryInternal(obj)
            Summary =  obj.getResultSummary;
        end
        
        
        function Summary = getResultSummary(obj)
            MyTitles =          obj.getSpecimenTitles;
            MyData =            obj.getDataInMatrixSpreadSheet;
            mySpreadSheet =     PMSpreadSheet(MyTitles, MyData);
            Summary =           mySpreadSheet.getFormattedSpreadSheet;

        end
        
      
    end
    
end

