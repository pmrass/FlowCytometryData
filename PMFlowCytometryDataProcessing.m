classdef PMFlowCytometryDataProcessing
    %PMFLOWCYTOMETRYDATAPROCESSING Summary of this class goes here
    %   this is pretty messy, split into smaller parts and replace;
    
    properties (Access = private)
        
        SourceFiles
        FlowJoExports
        
        ExportFiles
        ExportFilenamesPrefix
        
 
        CallingFunction
        
        TimeUnit =                             'days'
        SpecimenTimeCodes
        SpecimenTypeCodes   =                  cell(0,1);
        SpecimenCounts_Million
        SpecimenCounts_CellType
        ColumnTitles
        
    end
    
    methods
        
        function obj = PMFlowCytometryDataProcessing(varargin)
            %PMFLOWCYTOMETRYDATAPROCESSING Construct an instance of this class
            %   Detailed explanation goes here
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                    obj.CallingFunction = varargin{1};
                otherwise
                    error('Wrong number of arguments')  
            end
        end
        
        
        %% set file description
        function obj = setFileDescription(obj, SourceFolderName, SourceFileNames, ExportFolderName, ExportFilenamesPrefix)
            
            obj.SourceFiles =                 PMFileManagement(SourceFolderName, SourceFileNames);
            obj.ExportFiles =                 PMFileManagement(ExportFolderName);
            obj.ExportFilenamesPrefix =       ExportFilenamesPrefix;
            obj =                             obj.setFlowJoExports;
        end
            
         function obj = set.ExportFilenamesPrefix(obj, Value)
            assert(ischar(Value), 'Wrong input type')
            obj.ExportFilenamesPrefix = Value;
         end
        
        %% set specimen description:
        function obj = setSpecimenDescription(obj, TimeUnit, TimeCodes, TypeCodes, AbsoluteCounts, TypeForAbsoluteCounts, ColumnTitles)
           
            if isempty(AbsoluteCounts)
               AbsoluteCounts = nan(length(TimeCodes), 1);
            end
            
            Lengths =   unique([length(TimeCodes); length(TypeCodes); length(AbsoluteCounts)]);
            assert(length(Lengths)==1, 'Dimensions of specimen description do not match')
            
            obj.TimeUnit =                  TimeUnit;
            obj.SpecimenTimeCodes =         TimeCodes;
            obj.SpecimenTypeCodes   =       TypeCodes;
            obj.SpecimenCounts_Million =    AbsoluteCounts;
            obj.SpecimenCounts_CellType =   TypeForAbsoluteCounts;
            obj.ColumnTitles =              ColumnTitles;
             
            
            obj.FlowJoExports =         arrayfun(@(x) x.setDataCodes(ColumnTitles), obj.FlowJoExports);
        
            
        end
        
        function obj = set.TimeUnit(obj, Value)
            assert(ischar(Value), 'Wrong input type')
            obj.TimeUnit = Value;
        end
        
        function obj = set.SpecimenTimeCodes(obj, Value)
            assert(isnumeric(Value) && isvector(Value), 'Wrong input type')
            obj.SpecimenTimeCodes = Value;
        end
        
        function obj = set.SpecimenTypeCodes(obj, Value)
            assert(iscellstr(Value) && isvector(Value), 'Wrong input type')
            obj.SpecimenTypeCodes = Value;
        end
        
        function obj = set.SpecimenCounts_Million(obj, Value)
            assert(isnumeric(Value) && isvector(Value), 'Wrong input type')
            obj.SpecimenCounts_Million = Value;
        end
        
        function obj = set.SpecimenCounts_CellType(obj, Value)
            assert(ischar(Value), 'Wrong input type')
            obj.SpecimenCounts_CellType = Value;
        end
         
        function obj = set.ColumnTitles(obj, Value)
            assert(iscellstr(Value) && isvector(Value), 'Wrong input type')
            obj.ColumnTitles = Value;
        end
       
     
        
        %% write summary into file;
        function obj = writeSummaryIntoFile(obj)
            exportSummaryFile = PMFile(obj.SourceFiles.getMainFolder, '/FlowDataSummary.text');
            exportSummaryFile.writeCellString(obj.getSummary)
            
        end
        
        function Summary = getSummary(obj) 
                SummaryText =       arrayfun(@(x) x.getSummary, obj.FlowJoExports, 'UniformOutput', false);
                Summary =           vertcat(SummaryText{:});
        end

        function obj = changeDataForValues(obj, Values)
            
            assert(iscell(Values) && isvector(Values), 'Wrong input type')
            for Index=1:length(Values)
                obj =   obj.changeDataForValue(Values{Index});
            end
            

        end
        
           function obj = changeDataForValue(obj, Value)
             
             %% currently not supported: 
             % when faulty data are in flow jo file: overwrite actualy data;
             % this needs to be incorporated somewhere else
            assert(iscell(Value) && length(Value) == 3, 'Wrong input type')
            Row = Value{1};
            assert(isnumeric(Row) && isscalar(Row) && Row<size(obj.getSpreadSheetData,1), 'Invalid argument')
            Column = Value{2};
            assert(ischar(Column), 'Wrong argument type')
            MyValue = Value{3};
            assert(isnumeric(MyValue) && isscalar(MyValue), 'Wrong input type')
            
             mySpreadSheet =  obj.getSpreadSheetData;
            
            mySpreadSheet(Row, obj.getColumnFor(Column)) = MyValue;
           end
         
           
           %% export into time-lapse object
            function obj = exportIntoTimeLapseObjects(obj, Value)
                assert(iscellstr(Value), 'Wrong input type.')
                cellfun(@(x) obj.exportIntoTimeLapseObject(x), Value);
            end

     
    end
    
    methods (Access = private)
        
        function obj = setFlowJoExports(obj)
            obj.FlowJoExports =      cellfun(@(x) PMFlowJoExport(obj.SourceFiles.getMainFolder, x), obj.SourceFiles.getSelectedFileNames);                                                                                                                                                                                                                            
           
        
        end
        
      
         
         
        
          
            
           function specimenTitles = getSpecimenTitles(obj)
               mySpecimenTitles =          arrayfun(@(x) x.getSpecimenNames, obj.FlowJoExports, 'UniformOutput', false);
               specimenTitles =     vertcat(mySpecimenTitles{:}); 
           end
           
            function DataSpreadsheet = getSpreadSheetData(obj)
                 collectedResults =          arrayfun(@(x)x.getSpreadSheetOfData, obj.FlowJoExports, 'UniformOutput', false);
                DataSpreadsheet =       vertcat(collectedResults{:}); 
            end
            
                 
            %% export into time-lapse object:
              
              function exportIntoTimeLapseObject(obj, Code)
                TimCourseData =                              PMTimeCourseDataContainer();
                TimCourseData.DataSources =                  obj.SourceFiles.getSelectedPaths;
                TimCourseData.DataProcessingIdentifier =     [obj.CallingFunction, ': ', '@exportIntoTimeLapseObject'];
                TimCourseData.TimeUnit =                     obj.TimeUnit;
                TimCourseData.RawData =                      obj.splitDataByGroupAndTime(obj.retrieveValuesFor(Code));
                
                TimCourseData.Parameter =                    Code;
                ExportFileNameComplete =                     [obj.SourceFiles.getMainFolder '/'  obj.ExportFilenamesPrefix  Code, '.mat'];
                save(ExportFileNameComplete, 'TimCourseData')
              end
            
                  
            function splitData = splitDataByGroupAndTime(obj, OneDimensionalData)
               
                ExportRow =             0;
                AllTimePoints =         obj.getUniqueTimePoints;
                splitData =             cell(obj.getNumberOfUniqueSpecimenTypes * obj.getNumberOfUniqueTimePoints,1);
                for GroupIndex= 1:obj.getNumberOfUniqueSpecimenTypes
                    SpecimenType =   obj.getUniqueSpecimenTypes{GroupIndex};
                    
                    for TimeIndex=1:obj.getNumberOfUniqueTimePoints
                        CurrentTimePoint =         AllTimePoints(TimeIndex);
                        
                        AndFilter =                 min([obj.SpecimenTimeCodes == CurrentTimePoint, strcmp(SpecimenType, obj.SpecimenTypeCodes)], [], 2);
                        MyCollectedData =           OneDimensionalData(AndFilter);
                        ExportRow =                 ExportRow + 1;
                        splitData{ExportRow,1} =    SpecimenType;
                        splitData{ExportRow,2} =    CurrentTimePoint;
                        splitData{ExportRow,3} =    MyCollectedData;
                    end
                    
                end 
            end
            
            function timeCodes = getUniqueTimePoints(obj)
                timeCodes =         unique(obj.SpecimenTimeCodes);
            end
            
            function number = getNumberOfUniqueSpecimenTypes(obj)
                number =         length(obj.getUniqueSpecimenTypes);
            end
            
            function specimenTypes = getUniqueSpecimenTypes(obj)
                specimenTypes =      unique(obj.SpecimenTypeCodes);
            end
            
            function number = getNumberOfUniqueTimePoints(obj)
                number = length(obj.getUniqueTimePoints);
            end
             
            function Value = retrieveValuesFor(obj, Code)
                split = strsplit(Code, '_');
                Value = obj.(['get' split{1} 'sFor'])(split{2});
            end
            
            function Values = getTotalNumbersFor(obj, Code)
                Values =  obj.getNumbersFor(Code) ./ obj.getReferenceValues .* obj.SpecimenCounts_Million;
            end
            
            function Values = getNumbersFor(obj, Code)
                mySpreadSheet =  obj.getSpreadSheetData;
                Values = mySpreadSheet(:, obj.getColumnFor(Code));
            end
            
            function Value = getReferenceValues(obj)
                Value =     obj.getNumbersFor( obj.SpecimenCounts_CellType);
            end
            
            function Values = getPercentagesFor(obj, Code)
                 split =        strsplit(Code, '%');
                 FirstValues =          obj.getNumbersFor(split{1});
                 SecondCodes =          strsplit(split{2}, '+');
                 SecondValues =         arrayfun(@(x) obj.getNumbersFor(x), SecondCodes, 'UniformOutput', false);
                 SecondValues =         sum(cell2mat(SecondValues), 2);
                 Values =               FirstValues  ./ SecondValues * 100;   
                 assert(~isempty(Values), 'No values retrieved')
            end
            
      
            
        
        function column = getColumnFor(obj, Value)
            column = find(strcmp(Value, obj.ColumnTitles));
        end
        
       
        
        
    end
    
end

