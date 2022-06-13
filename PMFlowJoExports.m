classdef PMFlowJoExports
    %PMFLOWJOEXPORTS main goal is to pool a vector of PMFlowJoExport
    %objects into a single merged PMFlowJoExport object
    
    properties (Access = private)
        FlowJoExportList =                  PMFlowJoExport.empty(0,1);
        MatchMeansOfDifferentExperiments =  true;
    end
    
    methods % initialization
        
         function obj = PMFlowJoExports(varargin)
            %PMFLOWJOEXPORTS Construct an instance of this class
            %   takes one argument: vector of PMFlowJoExport objects:
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                    obj.FlowJoExportList = varargin{1};
                    
                otherwise
                    error('Wrong input.')
            end
        end
        
        function obj = set.FlowJoExportList(obj,Value)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(isa(Value, 'PMFlowJoExport') && isvector(Value), 'Wrong input.')
            obj.FlowJoExportList = Value;
        end
        
        
        function obj = set.MatchMeansOfDifferentExperiments(obj, Value) 
             assert(islogical(Value) && isscalar(Value), 'Invalid input.')
            obj.MatchMeansOfDifferentExperiments = Value;
        end
        
        
    end
    
    methods % GETTERS CLASS-FUNCTION
        
        function mergedRows = mergeGroupRows(obj, Value)
            mergedRows = obj.mergeGroupRowLists(Value);
        end
        
        function SingleCell = mergeCellList(obj, CellList)
            AllEqual =  min(cellfun(@(x) isequal(CellList{1}, x), CellList));
            assert(AllEqual, 'There are inconsitencies that prevent merging of the different files.')
            SingleCell= CellList{1};
        end
        
    end
    
    methods % SUMMARY
        
         function obj = showSummary(obj)
            fprintf('\n*** This PMFlowJoExports object can read and parse data stored %i FloJo files:\n', obj.getNumberOfFiles)
            
            fprintf('\nThe PMFlowJoExports has two options to merge the contents of different files:\n')
            fprintf('Option 1: concatentate the data "as-is"\n')
            fprintf('Option 2: Calculate the mean of all data in the first file and then force the means of each other file to this same mean. After that: concatenate.\n')
            if obj.MatchMeansOfDifferentExperiments
                fprintf('This oject has the "match means option" ON.\n')
            else
                fprintf('This oject has the "match means option" OFF.\n')
            end
            
            fprintf('\nHere is a list of the PMFlowJoExport objects that is created from these files:\n')
            arrayfun(@(x) x.showSummary, obj.FlowJoExportList) 
            
            fprintf('\nHere are the data after merging the different files:\n')
            
            Summary = obj.getResultSummary;
            cellfun(@(x) fprintf('%s\n', x), Summary)
         end
       
    end
    
    methods % GETTERS
        
        function data =         getSpreadsheetOfData(obj)
            % GETSPREADSHEETOFDATA getSpreadsheetOfData returns a numerical matrix after vertical conctenation of the spreadsheets from the single PMFlowJoExport objects;
            data =      obj.getSpreadsheetOfDataInternal;            
         end
       
        function final =        getSpecimenNames(obj)
                names = arrayfun(@(x) x.getSpecimenNames, obj.FlowJoExportList, 'UniformOutput', false);
                final  = vertcat(names{:});
           end
        
        function number =       getNumberOfFiles(obj)
            number = size(obj.FlowJoExportList, 1);
        end

    end
    
    methods % SETTERS
        
         function obj = setMatchMeansOfDifferentExperiments(obj, Value)
             obj.MatchMeansOfDifferentExperiments = Value;
         end
        
         
        
    end

    methods (Access = private)
           
        function Summary = getResultSummary(obj)
            MyTitles =          obj.getSpecimenNames;
            MyData =            obj.getSpreadsheetOfDataInternal;
            mySpreadSheet =     PMSpreadSheet(MyTitles, MyData);
            Summary =           mySpreadSheet.getFormattedSpreadSheet;

        end

        function NumericalDataMatrix = getSpreadsheetOfDataInternal(obj)
            

                DataSpreadsheetsForEachFile =    arrayfun(@(x) x.getSpreadSheetOfData, obj.FlowJoExportList, 'UniformOutput', false);                              
                assert(isvector(DataSpreadsheetsForEachFile), 'Can only process a vector list of data')
            
                if obj.MatchMeansOfDifferentExperiments
                    DataSpreadsheetsForEachFile =   obj.matchMeansForSpreadsheets(DataSpreadsheetsForEachFile);
                end
                
                DataSpreadsheetsForEachFile =       DataSpreadsheetsForEachFile(:);
                NumericalDataMatrix =                       vertcat(DataSpreadsheetsForEachFile{:}); 
            
        end
         
    end
    
    methods (Access = private)% match means between different experiment; this could be moved out for a more general class for ;
        
         function DataSpreadsheetsForEachFile = matchMeansForSpreadsheets(obj, DataSpreadsheetsForEachFile)
                MeansOfAllDataInFirstExperiment =       mean(DataSpreadsheetsForEachFile{1}, 1);
                DataSpreadsheetsForEachFile =           cellfun(@(x) obj.matchMeans(MeansOfAllDataInFirstExperiment, x), DataSpreadsheetsForEachFile, 'UniformOutput', false);
        end
        
       
        
        function CurrentDataForTransform = matchMeans(~, MeansOfAllDataInFirstFile, DataOfCurrentFile)

            MeansOfAllDataInCurrentFile =    mean(DataOfCurrentFile, 1);

            CurrentDataForTransform =   DataOfCurrentFile;
            
            NumberOfParameters = length(MeansOfAllDataInCurrentFile);
            
            for ParameterIndex = 1 : NumberOfParameters
                CurrentDataForTransform(:, ParameterIndex) = CurrentDataForTransform(:, ParameterIndex) / MeansOfAllDataInCurrentFile(ParameterIndex) * MeansOfAllDataInFirstFile(ParameterIndex);
            end

        end
        
    end
    
    methods (Access = private) % manipulating group identity
        % this is simply for "merging" the group-identities (indices) for multiple files:
        % this involves outside input and is rather general, maybe move to more general class?;
        
        function CompleteMergeForGroups =       mergeGroupRowLists(obj, CellWithGroupRows)

        CellWithGroupRowsAdjust =     obj.adjustGroupRowsForSeriesInCell(CellWithGroupRows);

        Spreadsheet =                   vertcat(CellWithGroupRowsAdjust{:});
        CompleteMergeForGroups =        obj.finalizeMergeOfGroupRows(Spreadsheet);

        if ~iscell(CompleteMergeForGroups)
            disp('test')
        else
            CompleteMergeForGroups = cellfun(@(x) obj.removeNaN(x), CompleteMergeForGroups, 'UniformOutput', false);
        end


        end

        function SpreadsheetWithGroupRows =     finalizeMergeOfGroupRows(obj, SpreadsheetWithGroupRows)

        for sampleIndex = 2 : size(SpreadsheetWithGroupRows, 1)
            for groupIndex = 1 : size(SpreadsheetWithGroupRows,2)
                MergeFromPreviousRound =        SpreadsheetWithGroupRows{1, groupIndex};
                ToAddInThisRound =              SpreadsheetWithGroupRows{sampleIndex, groupIndex};
                SpreadsheetWithGroupRows{1, groupIndex} =    vertcat(MergeFromPreviousRound, ToAddInThisRound); 
            end
        end
        SpreadsheetWithGroupRows(2:end,: ) = [];
        SpreadsheetWithGroupRows = SpreadsheetWithGroupRows';

        end

        function CellWithGroupRows =            adjustGroupRowsForSeriesInCell(obj, CellWithGroupRows)

          for index = 2: length(CellWithGroupRows)
                PreviousMaxValue = obj.getMaximumRowOf(CellWithGroupRows{index - 1});
                for groupIndex = 1: length(CellWithGroupRows{index})
                    CellWithGroupRows{index}{groupIndex} =  CellWithGroupRows{index}{groupIndex} + PreviousMaxValue;
                end
          end

        end

        function PreviousMaxValue =             getMaximumRowOf(obj, Cell)
        PreviousMaxValue = max(cellfun(@(x) max(x), Cell));
        end

        function Group =                    removeNaN(~, Group)
            Group(isnan(Group)) = [];

        end

        
        
        
    end
    
end

