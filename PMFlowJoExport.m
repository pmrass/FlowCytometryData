classdef PMFlowJoExport
    %PMFLOWJOEXPORT gives access to data exported with FloJo;
    %   parses csv files exported from flow-jo and enables user to retrieve content;
    
    properties (Access = private)
        File
        
        SpecimenFilters % should this be removed?
        StainingFilter % should this be removed?
        
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
              Data =     obj.getDataInMatrixSpreadSheet;
        end
        
         function Summary = getSummary(obj)
            Summary = obj.getSummaryInternal;  
         end
        
        function obj = setSpecimenFilters(obj, varargin)
            assert(length(varargin) == 1, 'Wrong argument number')
            obj.SpecimenFilters =   varargin{1};
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
    
    methods  (Access = private)
        
        %% get data-codes:
         function number = getNumberOfDataTypes(obj)
             Data =     obj.getDataInMatrixSpreadSheet;
             number =   size(Data, 2);
         end
        
        %% get data:
        function data = getDataInMatrixSpreadSheet(obj)
            data =      cellfun(@(x) str2double(x), obj.getDataInCellSpreadsheet);
        end
        
        function CellSpreadsheetWithoutRowTitles = getDataInCellSpreadsheet(obj)
            CellSpreadsheetWithRowTitles =          obj.convertFileContentIntoCellMatrix;
            CellSpreadsheetWithoutRowTitles =      CellSpreadsheetWithRowTitles(:, 2:end - 1);
        end
        
        
        function parsed = convertFileContentIntoCellMatrix(obj)
            CellVectorForEachFile =                 (strsplit(obj.File.getContent,'\n'))';
            CellVectorForEachFile_TitlesRemoved =    CellVectorForEachFile(2: end-3,:); 
            CellVectorForEachFile_TitlesRemoved =    cellfun(@(x) obj.removeCommasInFileName(x), CellVectorForEachFile_TitlesRemoved,'UniformOutput', false);
            currentResult=                          cellfun(@(x) strsplit(x,','), CellVectorForEachFile_TitlesRemoved, 'UniformOutput', false);
            parsed =                                vertcat(currentResult{:});
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
        
  
        %% get number of specimens:
        function number = getNumberOfSpecimens(obj)
            titles =    obj.getSpecimenTitles;
            number =    length(titles);
        end
        
        function titles = getSpecimenTitles(obj)
            parsed =        obj.convertFileContentIntoCellMatrix;
            titles =        parsed(:, 1);
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
        
        
        %% statistics: this could become its own statistics class;
        % statistics part was moved to PMGroupStatisticsList;
         
    end
    
end

